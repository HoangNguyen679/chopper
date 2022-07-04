require 'aws-sdk-dynamodb'

# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Resource.html

class CustomDynamoDB
  @@region = 'ap-northeast-1'
  @@endpoint = 'http://localhost:8000'

  def self.resource()
    resource = Aws::DynamoDB::Resource.new(region: @@region, endpoint: @@endpoint)
    return resource
  end

  def self.client()
    client = Aws::DynamoDB::Client.new(region: @@region, endpoint: @@endpoint)
    return client
  end
end