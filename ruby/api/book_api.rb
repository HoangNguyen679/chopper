# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../lib/dynamodb"
require 'parallel'

# Service to scan all books table
class BookApi
  TABLE_NAME = 'books'

  def initialize
    @client = CustomDynamoDB.client
  end

  def books
    response = benmark('Scan in: ') do
      @client.scan(
        table_name: TABLE_NAME
      )
    end
    response.items
  end

  def books_consistent_read
    response = benmark('Scan with consistent read in: ') do
      @client.scan(
        table_name: TABLE_NAME,
        consistent_read: false
      )
    end
    response.items
  end

  def books_pagination(page_size = 100)
    benmark("Scan with page size = #{page_size} in: ") do
      result = []

      response = @client.scan(
        table_name: TABLE_NAME,
        limit: page_size
      )

      result.push(*response.items)

      while response.key?('last_evaluated_key')
        response = @client.scan(
          table_name: TABLE_NAME,
          limit: page_size,
          exclusive_start_key: response.last_evaluated_key
        )

        result.push(*response.items)
      end
      result
    end
  end

  def books_isbn
    response = benmark('Scan only isbn in: ') do
      @client.scan(
        table_name: TABLE_NAME,
        projection_expression: 'isbn'
      )
    end
    response.items
  end

  def books_with_page_is_larger_than(value = 100)
    response = benmark("Scan with page is larger than #{value} in: ") do
      @client.scan(
        table_name: TABLE_NAME,
        filter_expression: '#page_count >= :value',
        expression_attribute_names: {
          '#page_count': 'pageCount'
        },
        expression_attribute_values: {
          ':value': value
        }
      )
    end
    response.items
  end

  def books_with_multi_thread(num_threads)
    benmark("Scan with #{num_threads} threads in: ") do
      Parallel.map((0...num_threads), in_threads: num_threads) { |i| __scan_with_segment(i, num_threads) }.flatten
    end
  end

  # batch get item
  # start
  # max 100 items
  # retrieve items in paralel
  # no order

  def books_with_batch_get_item()
    response = benmark('Batch get item in:') do
      @client.batch_get_item({
                               request_items: {
                                 TABLE_NAME => {
                                   keys: [
                                     {
                                       'isbn' => '1933988673'
                                     }
                                   ]
                                 }
                               }
                             })
    end
    response.responses
  end

  # describe table
  #
  #

  def describe_books_table()
    @client.describe_table({
                             table_name: TABLE_NAME
                           }).to_h
  end

  # get item
  #
  #

  def book(isbn)
    response = benmark('Get item in: ') do
      @client.get_item({
                         table_name: TABLE_NAME,
                         key: {
                           'isbn' => isbn
                         }
                       })
    end
    response.item
  end

  # query
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

  def __scan_with_segment(segment, total_segments)
    result = []
    response = @client.scan(
      table_name: TABLE_NAME,
      segment: segment,
      total_segments: total_segments
    )
    result.push(*response.items)

    while response.key?('last_evaluated_key')
      response = @client.scan(
        table_name: TABLE_NAME,
        segment: segment,
        total_segments: total_segments,
        exclusive_start_key: response.last_evaluated_key
      )

      result.push(*response.items)
    end

    result
  end

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

  def benmark(description)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = yield
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts(description)
    puts(finish - start)
    response
  end
end
