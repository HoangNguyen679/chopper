# frozen_string_literal: true

require 'aws-sdk-dynamodb'

# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Resource.html

# Create client or resource of dynamodb
class CustomDynamoDB
  @@region = 'ap-northeast-1'
  @@endpoint = 'http://localhost:8000'

  def self.resource
    Aws::DynamoDB::Resource.new(region: @@region, endpoint: @@endpoint)
  end

  def self.client
    Aws::DynamoDB::Client.new(region: @@region, endpoint: @@endpoint)
  end
end
