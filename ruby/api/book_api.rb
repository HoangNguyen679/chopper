# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../lib/dynamodb"

# Service to scan all books table
class BookApi
  TABLE_NAME = 'books'

  def initialize
    @client = CustomDynamoDB.client
  end

  def describe_books_table()
    @client.describe_table({ table_name: TABLE_NAME }).to_h
  end

  private

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
