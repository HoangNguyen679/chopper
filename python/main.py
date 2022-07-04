from api.book_api import BookApi

book_api = BookApi()

# print(book_api.get_books())

# print(book_api.get_books_pagination())

book_api.get_books()

book_api.get_books_consistent_read()

book_api.get_books_pagination(10)

book_api.get_books_pagination(100)

book_api.get_books_pagination(1000)

book_api.get_books_isbn()

book_api.get_books_with_page_is_larger_than(100)

book_api.get_books_with_multi_thread(4)
