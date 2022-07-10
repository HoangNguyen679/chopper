# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../book_api"

# Service to query books
class QueryBookApi < BookApi
  # results are always sorted by sort key value
  # Number -> numeric
  # otherwise -> utf-8
  # default is ascending, to reverse the order, set ScanIndexForward -> false
  def books_by_part_of_title(search_title)
    benmark('Get bbooks by part of title in: ') do
      __query_with_title(search_title)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def __query_with_title(search_title)
    result = []
    response = @client.query({
                               table_name: TABLE_NAME,
                               key_condition_expression: 'isbn = :isbn',
                               filter_expression: 'contains(title, :search_title)',
                               expression_attribute_values: {
                                 ':isbn' => '1933988673',
                                 ':search_title' => search_title
                               },
                               projection_expression: 'title, isbn, shortDescription'
                             })
    result.push(*response.items)

    while response.key?('last_evaluated_key')
      response = @client.query({
                                 table_name: TABLE_NAME,
                                 key_condition_expression: 'isbn = :isbn',
                                 filter_expression: 'contains(title, :search_title)',
                                 expression_attribute_values: {
                                   ':isbn' => '1933988673',
                                   ':search_title' => search_title
                                 },
                                 projection_expression: 'title, isbn, shortDescription',
                                 exclusive_start_key: res.last_evaluated_key
                               })
      result.push(*response.items)
    end

    result
  end
  # rubocop:enable Metrics/MethodLength
end
