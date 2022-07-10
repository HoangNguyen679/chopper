# frozen_string_literal: true

require './ruby/api/book_api'
require './ruby/api/book/scan_book_api'
require './ruby/api/book/query_book_api'
require './ruby/api/book/get_book_api'
require './ruby/api/book/batch_book_api'

book_api = BookApi.new

pp book_api.describe_books_table

scan_book_api = ScanBookApi.new

scan_book_api.books

scan_book_api.books

scan_book_api.books_consistent_read

scan_book_api.books_pagination(10)

scan_book_api.books_pagination(100)

scan_book_api.books_pagination(1000)

scan_book_api.books_isbn

scan_book_api.books_with_page_is_larger_than(100)

scan_book_api.books_with_multi_thread(4)

scan_book_api.books_with_multi_thread(10)

batch_book_api = BatchBookApi.new

batch_book_api.books

get_book_api = GetBookApi.new

get_book_api.book('1933988673')

query_book_api = QueryBookApi.new

query_book_api.books_by_part_of_title('Android')
