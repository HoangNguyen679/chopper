# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../story_api"

# Service to query books
class QueryStoryApi < StoryApi
  def stories(author)
    benmark('Get stories by author in: ') do
      __query_with_author(author)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def __query_with_author(author)
    result = []
    response = @client.query({
                               table_name: TABLE_NAME,
                               key_condition_expression: 'id = :id',
                               filter_expression: 'contains(#author.#name, :author)',
                               expression_attribute_names: {
                                 '#author' => 'author',
                                 '#name' => 'name'
                               },
                               expression_attribute_values: {
                                 ':id' => '1',
                                 ':author' => author
                               },
                               projection_expression: 'id, content'
                             })
    result.push(*response.items)

    while response.key?('last_evaluated_key')
      response = @client.query({
                                 table_name: TABLE_NAME,
                                 key_condition_expression: 'id = :id',
                                 filter_expression: 'contains(#author.#name, :author)',
                                 expression_attribute_names: {
                                    '#author' => 'author',
                                    '#name' => 'name'
                                 },
                                 expression_attribute_values: {
                                   ':id' => '1',
                                   ':author' => author
                                 },
                                 projection_expression: 'id, content',
                                 exclusive_start_key: response.last_evaluated_key
                               })
      result.push(*response.items)
    end

    result
  end
  # rubocop:enable Metrics/MethodLength
end
