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
