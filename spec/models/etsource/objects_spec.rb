require 'spec_helper'

describe Etsource do
  it 'imports fixtures/../query_starting_with_minus.gql' do
    @import = Etsource::Gqueries.new(Etsource::Base.instance)
    @import.from_file('spec/fixtures/etsource/gqueries/query_starting_with_minus.gql').query.should == "- 1.0"
  end

  describe "fixtures/../gquery.txt" do
    before do
      @import = Etsource::Gqueries.new(Etsource::Base.instance)
      @txt = File.read('spec/fixtures/etsource/gqueries/category/gquery.txt')
      @gq = Gquery.new(:key => 'gquery', :unit => 'kg', :query => 'SUM(1,1)', :deprecated_key => "foo_bar")
    end

    it "should import correctly" do
      gq = @import.from_file('spec/fixtures/etsource/gqueries/category/gquery.txt')
      gq.key.should   == @gq.key
      gq.unit.should  == @gq.unit
      gq.query.should == @gq.query
      gq.deprecated_key.should == @gq.deprecated_key
    end
  end

  describe "fixtures/../gquery2.txt" do
    before do
      @import = Etsource::Gqueries.new(Etsource::Base.instance)
      @txt = File.read('spec/fixtures/etsource/gqueries/category/gquery2.txt')
      @gq = Gquery.new(:key => 'gquery2', :unit => 'kg', :query => "SUM(\n  SUM(1,2)\n)", :deprecated_key => nil,
        :description => "It has a comment and no deprecated_key"
      )
    end

    it "should import correctly" do
      gq = @import.from_file('spec/fixtures/etsource/gqueries/category/gquery2.txt')
      gq.key.should   == @gq.key
      gq.unit.should  == @gq.unit
      gq.query.should == @gq.query
      gq.deprecated_key.should == @gq.deprecated_key
      gq.description.should == @gq.description
    end
  end

end
