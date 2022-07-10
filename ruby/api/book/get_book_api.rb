# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../book_api"

# Service to get book
class GetBookApi < BookApi
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
end
