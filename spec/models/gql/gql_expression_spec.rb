require 'spec_helper'

module Gql

  describe "Full GQL" do
    before do
      @gql = Qernel::GraphParser.gql_stubbed("lft(100) == s(1.0) ==> rgt()")
      @gql.present_graph.year = 2010
      @gql.future_graph.year = 2040
    end

    it "should return GRAPH(year)" do
      @gql.query("GRAPH(year)").present_value.should == 2010
      @gql.query("GRAPH(year)").future_value.should == 2040
    end

    it "should return present graph when running QUERY_PRESENT(GRAPH(year))" do
      Gquery.stub!('get').with('graph_year').and_return(Gquery.new(:key => 'graph_year', :query => "GRAPH(year)"))
      @gql.query("Q(graph_year)").present_value.should == 2010
      @gql.query("Q(graph_year)").future_value.should == 2040
      @gql.query("QUERY_PRESENT(graph_year)").present_value.should == 2010
      @gql.query("QUERY_PRESENT(graph_year)").future_value.should  == 2010
      @gql.query("QUERY_FUTURE(graph_year)").present_value.should  == 2040
      @gql.query("QUERY_FUTURE(graph_year)").future_value.should   == 2040
    end
 end

  describe "Tests with one graph" do # No GQL needed
    before do
      @query_interface = QueryInterface.new(nil)
      Current.instance.stub_chain(:gql, :calculated?).and_return(true)
    end

    describe "traversing" do
      before do
        @graph = Qernel::GraphParser.new("
        lft(100) == c(1.0) ==> rgt
        mid(100) == s(1.0) ==> rgt
      ").build
        Current.instance.stub_chain(:gql, :calculated?).and_return(true)
        @q = QueryInterface.new(@graph)
      end
    
      describe "VALUE" do
        it "should return uniq converter" do
          @q.query("VALUE(lft,lft,mid,mid,rgt)").should have(3).items
        end
      end
    
      pending "BUG: LINKS" do
        @q.query("OUTPUT_LINKS(V(lft))").length.should == 0
      end
    
      it "LINKS" do
        @q.query("INPUT_LINKS(V(lft))").length.should == 1
        @q.query("INPUT_LINKS(V(lft);constant)").length.should == 1
        @q.query("INPUT_LINKS(V(lft);is_share)").length.should == 0
        @q.query("INPUT_LINKS(V(lft,mid);is_share)").length.should == 1
        @q.query("INPUT_LINKS(V(lft,mid))").length.should == 2
        @q.query("OUTPUT_LINKS(V(rgt))").length.should == 2
      end
    
      it "LINK(lft, rgt)" do
        @q.query("LINK(lft,rgt)").should be_constant
        @q.query("LINK(rgt,lft)").should == @q.query("LINK(lft,rgt)")
      end
    end

    describe "constants" do
      before { @query = "SUM(BILLIONS)"; @result = 10.0**9 }
      specify { @query_interface.check(@query).should be_true }
      specify { @query_interface.query(@query).should be_near(@result) }
    end
    
    def self.query_should_be_close(query, result, optional_title = nil)
      title = optional_title || "#{query} is ~= #{result}"
    
      describe optional_title do
        specify { @query_interface.check(query).should be_true }
        specify { @query_interface.query(query).should be_near(result) }
      end
    end
    
    def self.query_should_eql(query, result, optional_title = nil)
      title = optional_title || "#{query} is ~= #{result}"
    
      describe optional_title do
        specify { @query_interface.check(query).should be_true }
        specify { @query_interface.query(query).should eql(result) }
      end
    end


    describe "arithmetic operations" do
      describe "SUM" do
        query_should_be_close("SUM(-1)", -1.0, "negative number")
        query_should_be_close "SUM(1)", 1.0
        query_should_be_close "SUM(1,2)", 3.0
        query_should_be_close "SUM(SUM(1))", 1.0, 'nested SUM'
        query_should_be_close "SUM(1,SUM(1))", 2.0, 'value and nested SUM'
      end
    
      describe "PRODUCT" do
        query_should_be_close "PRODUCT(2,3)", 6.0
      end
    
      describe "NEG" do
        query_should_be_close "NEG(1)", -1.0
        query_should_be_close "NEG(-1)", 1.0
      end
    
      describe "SQRT" do
        query_should_eql "SQRT(4)", [2.0]
        query_should_eql "SQRT(4,9)", [2.0,3.0]
      end
    
      describe "NORMCDF" do
        query_should_be_close "NORMCDF(-0.2, 0, 1)", 0.42072
        query_should_be_close "NORMCDF(0.2,  0,  1)", 0.57926
        query_should_be_close "NORMCDF(8, 10,  2)", 0.15866
        query_should_be_close "NORMCDF(500,450, 50)",  0.84134
        query_should_be_close "NORMCDF(200,450, 50)",  0.00003 
        query_should_be_close "NORMCDF(19.9, 22.9, 1)",  0.0013499
        query_should_be_close "NORMCDF(0, 0, 1)",  0.5
        #query_should_be_close "NORMCDF(0.5, 0, 0)", nil
      end
    end
  

    describe "AREA" do
      before {@query_interface.stub!(:area).with('foo').and_return(5.0)}
      query_should_be_close "AREA(foo)", 5.0
    end

    describe "GRAPH" do
      before {@query_interface.stub!(:graph_query).with('foo').and_return(5.0)}
      query_should_be_close "GRAPH(foo)", 5.0
    end

    describe "QUERY" do
      describe "subqueries" do
        before {@query_interface.stub!(:subquery).with('foo').and_return(5.0)}
        query_should_be_close "QUERY(foo)", 5.0
      end
    end

    describe "QUERY_PRESENT" do
      pending "QUERY_PRESENT( foo ) should return the result of gquery 'foo' of present graph" 
    end

    describe "INVALID_TO_ZERO" do
      describe "basic values" do
        before { @query = "INVALID_TO_ZERO(1,DIVIDE(0,0))"; }
        subject { @query_interface.query(@query) }
        its(:first) { should be_near(1.0) }
        its(:last)  { should be_near(0.0) }
      end

      describe "between VALUE" do
        before { @query = "INVALID_TO_ZERO(V(1,DIVIDE(0,0)))"; }
        subject { @query_interface.query(@query) }
        its(:first) { should be_near(1.0) }
        its(:last)  { should be_near(0.0) }
      end
    end

    describe "converters" do
      before do
        # We cannot mock easily Converters using mock('Converter', :demand => 1)
        # Because Array#flatten calls to_ary on every object within an array - and we
        # use flatten a lot in GQL queries. I haven't found a way to easily do that with a mock. (sb)
        @c1 = Qernel::Converter.new(id: 1, key: 'foo')
        @c2 = Qernel::Converter.new(id: 2, key: 'bar')
        @c3 = Qernel::Converter.new(id: 3, key: 'baz')

        @c1.stub!(:demand).and_return(1.0)
        @c2.stub!(:demand).and_return(2.0)
        @c3.stub!(:demand).and_return(3.0)
        @c1.query.stub!(:demand).and_return(1.0)
        @c2.query.stub!(:demand).and_return(2.0)
        @c3.query.stub!(:demand).and_return(3.0)

        @query_interface.stub!(:converters).and_return([@c1,@c2,@c3])
        @query_interface.stub!(:group_converters).with(['foo']).and_return([@c1,@c2])
        @query_interface.stub!(:group_converters).with(['bar']).and_return([@c2,@c3])
      end

      describe "GROUP" do
        before { @query = "GROUP(foo)"; @result = [@c1,@c2] }
        specify { @query_interface.check(@query).should be_true }
        specify { @query_interface.query(@query).should eql(@result) }
      end

      describe "INTERSECTION" do
        before { @query = "INTERSECTION(GROUP(foo),GROUP(bar))"; @result = [@c2] }
        specify { @query_interface.check(@query).should be_true }
        specify { @query_interface.query(@query).should eql(@result) }
      end

      describe "VALUE" do
        describe "multiple converters" do
          before { @query = "SUM(VALUE(ca,cb,cd;demand))"; @result = 6.0 }
          specify { @query_interface.check(@query).should be_true }
          specify { @query_interface.query(@query).should be_near(@result) }
        end
        describe "ignores duplicates" do
          before { @query = "SUM(VALUE(ca,ca,cb,cb,cd;demand))"; @result = 6.0 }
          specify { @query_interface.check(@query).should be_true }
          specify { @query_interface.query(@query).should be_near(@result) }
        end
        describe "with group" do
          before { @query = "SUM(VALUE(GROUP(foo);demand))"; @result = 3.0 }
          specify { @query_interface.check(@query).should be_true }
          specify { @query_interface.query(@query).should be_near(@result) }
        end
      end

      describe "IF" do
        query_should_be_close "IF(LESS(1,3),50,100)", 50.0, 'is true'
        query_should_be_close "IF(LESS(3,1),50,100)", 100.0, 'is false'
        query_should_be_close "IF(LESS(1,3),IF(LESS(3,1),50,10),100)", 10.0, 'nested IFs'

        describe "invalid queries" do
          describe "condition is not a boolean" do
            before { @query = "IF(5,50,100)" }
            specify do
              lambda {
                @query_interface.query(@query)
              }.should raise_exception
            end
          end
          describe "condition is not a boolean" do
            before { @query = "IF(LESS(1,5),50)" }
            specify do
              lambda {
                @query_interface.query(@query)
              }.should raise_exception
            end
          end
        end
      end

      describe "IS_NUMBER" do
        query_should_eql "IS_NUMBER(1)", true
        query_should_eql "IS_NUMBER(BILLIONS)", true
        query_should_eql "IS_NUMBER(LESS(1,3))", false
        query_should_eql "IS_NUMBER(NIL())", false
      end

      describe "IS_NIL" do
        query_should_eql "IS_NIL(NIL())", true
        query_should_eql "IS_NIL(1)", false
      end

      describe "RESCUE" do
        query_should_be_close "RESCUE(AVG(NIL());5)", 5.0
        query_should_be_close "RESCUE(AVG(NIL()))", 0.0, "withouth param rescues with default 0.0"
      end

      describe "FOR_COUNTRIES" do
        describe "for de" do
          before { Current.scenario.country = 'de' }
          query_should_be_close "FOR_COUNTRIES(5;nl;en;de)", 5.0
        end
        describe "for nl" do
          before { Current.scenario.country = 'nl' }
          query_should_be_close "FOR_COUNTRIES(5;nl;en;de)", 5.0
        end
        describe "for country not in the list" do
          before { Current.scenario.country = 'ch' }
          query_should_eql "FOR_COUNTRIES(5;nl;en;de)", nil
        end
      end
    end

    describe "goals" do
      before :each do
        # I'd  like to have a simpler way to get an empty graph to work on
        # TODO: cleanup
        @graph = Qernel::GraphParser.new("
          lft(100) == c(1.0) ==> rgt
          mid(100) == s(1.0) ==> rgt
        ").build
        Current.instance.stub_chain(:gql, :calculated?).and_return(true)
        @q = QueryInterface.new(@graph)        
      end
      
      describe "updating goals with GQL" do
        it "should be a valid query" do
          @q.check("UPDATE(GOAL(foo),user_value,123)").should be_true
        end
        
        it "should update the goal object" do
          @q.query "UPDATE(GOAL(foo),user_value,123)"
          @graph.goal(:foo).user_value.should == 123
        end
      end
    end
  end
end