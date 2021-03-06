module Api
  module V3
    class ScenariosController < BaseController
      respond_to :json

      before_filter :find_scenario, :only => [:update, :sandbox]
      before_filter :find_preset_or_scenario, :only => [:show, :dashboard]

      # GET /api/v3/scenarios/:id
      #
      # Returns the scenario details in JSON format. If the scenario is missing
      # the action returns an empty hash and a 404 status code
      #
      def show
        render json: ScenarioPresenter.new(self, @scenario, params)
      end

      # GET /api/v3/scenarios/:id1,:id2,:id3,...,:id20/batch
      #
      # Returns the scenarios' details in JSON format. If any of the scenarios
      # is missing, they're not returned.
      #
      def batch
        ids = params[:id].split(',')

        @scenarios = ids.map do |id|
          scenario = Preset.get(id).try(:to_scenario) || Scenario.find_by_id(id)
          scenario ? ScenarioPresenter.new(self, scenario, params) : nil
        end.compact

        render json: @scenarios
      end

      def dashboard
        presenter = nil

        Scenario.transaction do
          presenter = ScenarioDashboardPresenter.new(self, @scenario, params)
        end

        if presenter.errors.any?
          render json: { errors: presenter.errors }, status: 422
        else
          render json: presenter
        end
      end

      # GET /api/v3/scenarios/templates
      #
      # Returns an array of the scenarions with the `in_start_menu`
      # attribute set to true. The ETM uses it on its scenario selection
      # page.
      #
      def templates
        render json: Preset.all.map { |ps| PresetPresenter.new(self, ps) }
      end

      # POST /api/v3/scenarios
      #
      # Creates a new scenario. This action is used when a user on the ETM
      # saves a scenario, too: in that case a copy of the scenario is saved.
      #
      def create
        # Weird ActiveResource bug: the user values attribute is nested inside
        # another user_values hash. Used when generating a scenario with the
        # average values of other scenarios.
        inputs = params[:scenario][:user_values]["user_values"] rescue nil
        if inputs
          params[:scenario][:user_values] = inputs
        end

        attrs = Scenario.default_attributes.merge(scenario_attributes || {})

        if attrs.key?(:scenario_id) || attrs.key?(:preset_scenario_id)
          # If user_values is assigned after the preset ID, we would wipe out
          # the preset user values.
          attrs.delete(:user_values)
        end

        @scenario = Scenario.new(attrs)

        if @scenario.save
          # With HTTP 201 nginx doesn't set content-length or chunked encoding
          # headers
          render json: ScenarioPresenter.new(self, @scenario, params)
        else
          render json: { errors: @scenario.errors }, status: 422
        end
      end

      # PUT-PATCH /api/v3/scenarios/:id
      #
      # This is the main scenario interaction method
      #
      # Parameters:
      #
      # - gqueries: array of gquery keys
      # - scenario: scenario attributes
      # - reset: boolean (default: false)
      #
      # Example request parameters:
      #
      # {
      #   scenario: {
      #     user_values: {
      #       123: 1.34
      #     }
      #   },
      #   gqueries: ['gquery_a', 'gquery_b']
      # }
      #
      # Response:
      # {
      #   scenario: { ... },
      #   gqueries: {
      #     gquery_key: {
      #       unit: 'foo',
      #       present: 123,
      #       future: 456
      #     },
      #     gquery_other: {
      #       errors: [ 'bad gquery!' ]
      #     }
      #   }
      # }
      #
      def update
        updater_attrs = params.merge(scenario: scenario_attributes)
        updater       = ScenarioUpdater.new(@scenario, updater_attrs)
        presenter     = nil

        Scenario.transaction do
          updater.apply
          presenter = ScenarioUpdatePresenter.new(self, updater, params)

          raise ActiveRecord::Rollback if presenter.errors.any?
        end

        if presenter.errors.any?
          render json: { errors: presenter.errors }, status: 422
        else
          render json: presenter
        end
      end

      # GET /api/v3/scenarios/:id/sandbox
      #
      # Returns the gql details in JSON format. If the scenario is missing
      # the action returns an empty hash and a 404 status code.
      #
      def sandbox
        if params[:gql].present?
          @query = params[:gql].gsub(/\s/,'')
        else
          render :json => {:errors => 'No gql'}, :status => 500 and return
        end

        begin
          gql = @scenario.gql(prepare: true)
          result = gql.query(@query)
        rescue Exception => e
          render :json => {:errors => [e.to_s]}, :status => 500 and return
        end

        json =
          if result.respond_to?(:present_year)
            { present_year:  result.present_year,
              present_value: result.present_value,
              future_year:   result.future_year,
              future_value:  result.future_value }
          else
            { result: result }
          end

        render json: json
      end

      private

      def find_preset_or_scenario
        @scenario = Preset.get(params[:id]).try(:to_scenario) ||
                    Scenario.find_by_id(params[:id])
        render :json => {:errors => ["Scenario not found"]}, :status => 404 and return unless @scenario
      end

      def find_scenario
        @scenario = Scenario.find params[:id]
      rescue ActiveRecord::RecordNotFound
        render :json => {:errors => ["Scenario not found"]}, :status => 404 and return
      end

      # Internal: Cleaned up attributes for creating and updating scenarios.
      #
      # Returns a hash.
      def scenario_attributes
        (params[:scenario] || {}).slice(
          :author, :title, :description, :user_values, :end_year, :area_code,
          :country, :region, :preset_scenario_id, :use_fce, :protected,
          :scenario_id, :source, :user_values
        )
      end

    end
  end
end
