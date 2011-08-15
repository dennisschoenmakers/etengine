##
# Default Query implementation of Gquery.
# Can be extended by other caching algorithms. (see GqueryCache)
#
# Usage:
# query = Gql::Gquery.new()
# query.query_graph(future_graph, "Q ( electricity_production ) ")
# Or:
# query.query("Q ( electricity_production ) ")
#
module Gql::QueryInterface::Base

  ##
  #
  #
  # @param query [String] An (unescaped) gquery
  # @param graph [Qernel::Graph] The Qernel::Graph to be queried
  # @return result
  #
  def query_graph(query, graph = nil)
    self.graph = graph unless graph.nil?
    self.query(query)
#  rescue Exception => e
#    raise Gql::GqlError.new("Gql::QueryInterface.query_graph exception for query: #{query}. #{e}")
  end

  def scope
    self
  end

  def debug_graph(query_string, graph = nil)
    self.graph = graph unless graph.nil?
    if parsed = clean_and_parse(query_string)
      msg = []
      parsed.debug(scope, msg)
      @graph = nil
      msg
    else
      @graph = nil
      raise Gql::GqlError.new("Gql::QueryInterface.query query is not valid: #{clean(query_string)}.")
    end
  rescue => e
    e.inspect
  end

  ##
  #
  # @param query [String, Gquery] Escaped query_string
  # @return [Float]
  # @raise [Gql::GqlError] if query is not valid.
  #
  def query(query)
    if query.is_a?(::Gquery)
      subquery(query.key)
    elsif parsed = clean_and_parse(query)
      parsed.result(scope)
    else
      raise Gql::GqlError.new("Gql::QueryInterface.query query is not valid: #{clean(query)}.")
    end
  end


  ##
  # Is the given gquery_string valid?
  #
  def check(query)
    Gql::QueryInterface::Preparser.check_query(query)
  end

  ##
  # A subquery is a call to another query.
  # e.g. "SUM(QUERY(foo))"
  #
  def subquery(gquery_key)
    # subquery should not set or reset the graph_for_grammar.
    # It is a subquery of a #query, so it should still use the same
    # graph_for_grammar.
    if gquery_key.is_a?(::Gquery)
      gquery = gquery_key
    else
      gquery = ::Gquery.get(gquery_key)
    end

    if gquery
      gquery.parsed_query.result(scope)
    else
      nil
    end
  end

  private

  def clean(query_string)
    Gql::QueryInterface::Preparser.clean(query_string)
  end

  def clean_and_parse(query_string)
    Gql::QueryInterface::Preparser.clean_and_parse(query_string)
  end


end
