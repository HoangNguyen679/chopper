# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../book_api"

# Service to get books in batch
class BatchBookApi < BookApi
  # batch get item
  # max 100 items
  # retrieve items in paralel
  # no order

  def books
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
end
