from base import Base

class Book(Base):
  __slots__ = [
    'isbn',
    'title',
    'pageCount',
    'publishedDate',
    'thumbnailUrl',
    'shortDescription',
    'longDescription',
    'status',
    'authors',
    'categories'
  ]
