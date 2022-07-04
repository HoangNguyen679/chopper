require File.dirname(__FILE__) + '/../lib/dynamodb'
require 'parallel'

class BookApi
  @@client = CustomDynamoDB.client()
  @@table_name = 'books'

  def get_books()
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @@client.scan(
      table_name: @@table_name,
    )
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts('Scan time:')
    puts(finish - start)
    puts('--------------------------------')
    return response.items
  end

  def get_books_consistent_read()
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @@client.scan(
      table_name: @@table_name,
      consistent_read: false,
    )
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts('Scan time with consistent read:')
    puts(finish - start)
    puts('--------------------------------')
    return response.items
  end

  def get_books_pagination(page_size=100)
    result = []
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @@client.scan(
      table_name: @@table_name,
      limit: page_size
    )

    result.push(*response.items)

    while response.key?('last_evaluated_key') do
      response = @@client.scan(
        table_name: @@table_name,
        limit: page_size,
        exclusive_start_key: response.last_evaluated_key
      )

      result.push(*response.items)
    end

    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts("Scan time with page size = #{page_size}:")
    puts(finish - start)
    puts('--------------------------------')
    return result
  end

  def get_books_isbn()
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @@client.scan(
      table_name: @@table_name,
      projection_expression: 'isbn'
    )
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts('Scan with only isbn time:')
    puts(finish - start)
    puts('--------------------------------')
    return response.items
  end

  def get_books_with_page_is_larger_than(value=100)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    response = @@client.scan(
      table_name: @@table_name,
      filter_expression: "#page_count >= :value",
      expression_attribute_names: {
        '#page_count': 'pageCount'
      },
      expression_attribute_values: {
        ':value': value
      }
    )
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts("Scan with page is larger than #{value}:")
    puts(finish - start)
    puts('--------------------------------')
    return response.items
  end

  def get_books_with_multi_thread(num_threads)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    result = Parallel.map((0...num_threads), in_threads: num_threads) { |i|
      __scan_with_segment(i, num_threads)
    }.flatten

    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts('--------------------------------')
    puts("Scan with #{num_threads} threads:")
    puts(finish - start)
    puts('--------------------------------')

    return result
  end

  def __scan_with_segment(segment, total_segments)
    result = []
    response = @@client.scan(
      table_name: @@table_name,
      segment: segment,
      total_segments: total_segments
    )
    result.push(*response.items)

    while response.key?('last_evaluated_key') do
      response = @@client.scan(
        table_name: @@table_name,
        segment: segment,
        total_segments: total_segments,
        exclusive_start_key: response.last_evaluated_key
      )

      result.push(*response.items)
    end

    return result
  end
end