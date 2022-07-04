from lib.dynamodb import CustomDynamoDB

from timeit import default_timer as timer
from boto3.dynamodb.conditions import Attr

from concurrent import futures

class BookApi:
  TABLE = CustomDynamoDB.resource().Table('books')

  def get_books(self):
    start = timer()
    response = self.TABLE.scan()
    end = timer()
    print('--------------------------------')
    print('Scan time:')
    print(end - start)
    print('--------------------------------')
    return response['Items']

  def get_books_consistent_read(self):
    start = timer()
    response = self.TABLE.scan(
      ConsistentRead=True
    )
    end = timer()
    print('--------------------------------')
    print('Scan time with consistent read:')
    print(end - start)
    print('--------------------------------')
    return response['Items']

  def get_books_pagination(self, page_size=100):
    result = []
    start = timer()
    response = self.TABLE.scan(
      Limit=page_size
    )

    result.extend([e for e in response['Items']])

    while 'LastEvaluatedKey' in response:
      response = self.TABLE.scan(
        Limit=page_size,
        ExclusiveStartKey=response['LastEvaluatedKey']
      )

      result.extend([e for e in response['Items']])

    end = timer()
    print('--------------------------------')
    print(f'Scan time with page size = {page_size}:')
    print(end - start)
    print('--------------------------------')
    return result

  def get_books_isbn(self):
    start = timer()
    response = self.TABLE.scan(
      ProjectionExpression='isbn'
    )
    end = timer()
    print('--------------------------------')
    print('Scan with only isbn time:')
    print(end - start)
    print('--------------------------------')
    return response['Items']

  def get_books_with_page_is_larger_than(self, value):
    start = timer()
    response = self.TABLE.scan(
      FilterExpression=Attr('pageCount').gte(value),
    )
    end = timer()
    print('--------------------------------')
    print(f'Scan with page is larger than {value}:')
    print(end - start)
    print('--------------------------------')
    return response['Items']

  def get_books_with_multi_thread(self, num_threads):
    def scan_with_multi_thread(segment, total_segments):
      result = []
      response = self.TABLE.scan(
        Segment=segment,
        TotalSegments=total_segments
      )
      result.extend([e for e in response['Items']])

      while 'LastEvaluatedKey' in response:
        response = self.TABLE.scan(
          Segment=segment,
          TotalSegments=total_segments,
          ExclusiveStartKey=response['LastEvaluatedKey']
        )

        result.extend([e for e in response['Items']])

      return result

    start = timer()

    futures_list = []

    with futures.ThreadPoolExecutor() as executor:
      for i in range(num_threads):
        future = executor.submit(scan_with_multi_thread, i, num_threads)
        futures_list.append(future)

    end = timer()
    print('--------------------------------')
    print(f'Scan with {num_threads} threads time:')
    print(end - start)
    print('--------------------------------')

    result = []
    for i in range(num_threads):
      result.extend(futures_list[i].result())

    return result