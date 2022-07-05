# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/base"
require "#{File.dirname(__FILE__)}/../hash_constructor"

class Book < Base
  include HashConstructor
  attr_accessor :isbn, :title, :page_count, :published_date, :thumbnail_url, :short_description, :long_description,
                :status, :authors, :categories
end
