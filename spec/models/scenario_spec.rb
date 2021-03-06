require 'spec_helper'

describe Scenario do
  before { @scenario = Scenario.new }
  subject { @scenario }

  describe "#default" do
    subject { Scenario.default }
    its(:area_code) { should == 'nl'}
    its(:user_values) { should == {} }
    its(:end_year) { should == 2040 }
    its(:start_year) { should == Atlas::Dataset.find(:nl).analysis_year }

    describe "#years" do
      its(:years) { should == 29 }
    end
  end

  describe "user supplied parameters" do
    it "should not allow a bad area code" do
      s = Scenario.new(:area_code => '{}')
      expect(s).to_not be_valid
      expect(s.errors[:area_code])
    end

    it "should not allow a bad year format" do
      s = Scenario.new(:end_year => 'abc')
      expect(s).to_not be_valid
      expect(s.errors[:end_year])
    end
  end

  describe "#user_values" do
    context ":user_values = YAMLized object (when coming from db)" do
      before {@scenario = Scenario.new(:user_values => {:foo => :bar})}
      it "should unyaml,overwrite and return :user_values" do
        @scenario.user_values.should == {:foo => :bar}
        @scenario.user_values[:foo].should == :bar
      end

    end
    context ":user_values = nil" do
      before {@scenario = Scenario.new(:user_values => {})}
      its(:user_values) { should == {} }
    end
    context ":user_values = obj" do
      before {@scenario = Scenario.new(:user_values => {})}
      its(:user_values) { should == {} }
    end
  end

  describe '#input_value' do
    let(:input) { Input.new(key: 'my-input', start_value: 99.0) }

    before { Input.stub(:all).and_return([input]) }
    before { Rails.cache.clear }

    context 'with a user value present' do
      let(:scenario) do
        FactoryGirl.create(:scenario, {
          user_values:     { 'my-input' => 20.0 },
          balanced_values: { 'my-input' => 50.0 }
        })
      end

      it 'returns the user value' do
        scenario.input_value(input).should eql(20.0)
      end
    end

    context 'with a balanced value present' do
      let(:scenario) do
        FactoryGirl.create(:scenario, balanced_values: { 'my-input' => 50.0 })
      end

      it 'returns the balanced value' do
        scenario.input_value(input).should eql(50.0)
      end
    end

    context 'with no user or balanced value' do
      let(:scenario) { FactoryGirl.create(:scenario) }

      it "returns the input's default value" do
        scenario.input_value(input).should eql(99.0)
      end
    end

    context 'given nil' do
      it 'raises an error' do
        expect { FactoryGirl.create(:scenario).input_value(nil) }.
          to raise_error(/nil is not an input/)
      end
    end
  end

  describe "#used_groups_add_up?" do
    before do
      @scenario = Scenario.default
      Input.stub(:inputs_grouped).and_return({
        'share_group' => [
          mock_model(Input, :id => 1, :key => 'element_1', :share_group => 'share_group'),
          mock_model(Input, :id => 2, :key => 'element_2', :share_group => 'share_group'),
          mock_model(Input, :id => 3, :key => 'element_3', :share_group => 'share_group')
        ],
        'share_group_unused' => [
          mock_model(Input, :id => 5, :key => 'element_5', :share_group => 'share_group_unused'),
          mock_model(Input, :id => 6, :key => 'element_6', :share_group => 'share_group_unused'),
        ]
      })
    end
    subject { @scenario }

    describe "#used_groups" do
      context "no user_values" do
        its(:used_groups) { should be_empty }
      end
      context "with 1 user_values" do
        before { @scenario.user_values = {1 => 2}}
        its(:used_groups) { should_not be_empty }
      end
    end

    describe "#used_groups_add_up?" do
      context "no user_values" do
        its(:used_groups_add_up?) { should be_true }
      end

      context "user_values but without groups" do
        before { @scenario.user_values = {10 => 2}}
        its(:used_groups_add_up?) { should be_true }
      end

      context "user_values that don't add up to 100" do
        before { @scenario.user_values = {1 => 50}}
        its(:used_groups_add_up?) { should be_false }
        its(:used_groups_not_adding_up) { should have(1).items }
      end

      context "user_values that add up to 100" do
        before { @scenario.user_values = {1 => 50, 2 => 30, 3 => 20}}
        its(:used_groups_add_up?) { should be_true }
      end

      context "with balanced values which add up to 100" do
        before do
          @scenario.user_values     = { 1 => 50}
          @scenario.balanced_values = { 2 => 20, 3 => 30 }
        end

        its(:used_groups_add_up?) { should be_true }
      end

      context "with balanced values which do not add up to 100" do
        before do
          @scenario.user_values     = { 1 => 40 }
          @scenario.balanced_values = { 2 => 20, 3 => 30 }
        end

        its(:used_groups_add_up?)       { should be_false }
        its(:used_groups_not_adding_up) { should have(1).items }
      end

      context "with only balanced values which add up to 100" do
        before do
          @scenario.user_values     = {}
          @scenario.balanced_values = { 1 => 50, 2 => 20, 3 => 30 }
        end

        its(:used_groups_add_up?) { should be_true }
      end

    end
  end

  describe 'with a preset scenario' do
    let(:preset) do
      FactoryGirl.create(:scenario, {
        id:              99999, # Avoid a collision with a preset ID
        user_values:     { 'one' => 1 },
        balanced_values: { 'two' => 2 }
      })
    end

    let(:scenario) do
      Scenario.new(scenario_id: preset.id)
    end

    it 'should copy the user values' do
      scenario.user_values.should eql(preset.user_values)
    end

    it 'should copy the balanced values' do
      scenario.balanced_values.should eql(preset.balanced_values)
    end
  end

  describe 'dup' do
    let(:scenario) do
      Scenario.create!(
        title:           'Test',
        use_fce:         true,
        end_year:        2030,
        area_code:       'nl',
        user_values:     { 1 => 2, 3 => 4 },
        balanced_values: { 5 => 6 }
      )
    end

    let(:dup) { scenario.dup }

    it 'clones the end year' do
      dup.end_year.should eql(2030)
    end

    it 'clones the area' do
      dup.area_code.should eql('nl')
    end

    it 'clones the user values' do
      dup.user_values.should eql(scenario.user_values)
    end

    it 'clones balanced values' do
      dup.balanced_values.should eql(scenario.balanced_values)
    end

    it 'clones the FCE status' do
      dup.use_fce.should be_true
    end

    it 'does not clone the scenario ID' do
      dup.id.should be_nil
    end

    it 'does not clone inputs_present' do
      dup.inputs_present.should_not equal(scenario.inputs_present)
    end

    it 'does not clone inputs_before' do
      dup.inputs_before.should_not equal(scenario.inputs_before)
    end

    it 'does not clone inputs_future' do
      dup.inputs_future.should_not equal(scenario.inputs_future)
    end
  end
end
