module Etsource
  class Inputs
    def initialize(etsource)
      @etsource = etsource
    end

    def import!
      # Do not delete inputs because input ids are important and referenced by et-model
      import
    end

    def export
      base_dir = "#{@etsource.base_dir}/inputs"

      FileUtils.mkdir_p(base_dir)
      Input.find_each do |input|
        attrs = input.attributes
        attrs.delete('created_at')
        attrs.delete('updated_at')
        File.open("#{base_dir}/#{input.key}.yml", 'w') do |f|
          f << YAML::dump(attrs)
        end
      end
    end

    def import
      base_dir = "#{@etsource.base_dir}/inputs"

      Dir.glob("#{base_dir}/**/*.yml").each do |f|
        attributes = YAML::load_file(f)
        begin
          input = Input.find(attributes.delete('id'))
          input.update_attributes(attributes)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.debug "*** ETSource::Inputs#import: Input not found"
        end
      end
    end
  end
end