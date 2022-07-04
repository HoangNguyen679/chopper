import boto3

# https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html

class CustomDynamoDB:
  def __init__(self):
    pass

  def resource():
    return boto3.resource('dynamodb', endpoint_url='http://localhost:8000')

  def client():
    return boto3.client('dynamodb', endpoint_url='http://localhost:8000')

