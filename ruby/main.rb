require './ruby/api/book_api'

book_api = BookApi.new

book_api.books

book_api.books_consistent_read

book_api.books_pagination(10)

book_api.books_pagination(100)

book_api.books_pagination(1000)

book_api.books_isbn

book_api.books_with_page_is_larger_than(100)

book_api.books_with_multi_thread(4)

book_api.books_with_multi_thread(10)

book_api.books_with_batch_get_item

book_api.book('1933988673', 'Unlocking Android')
