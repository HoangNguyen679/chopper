# frozen_string_literal: true

require 'base'

class Book < Base
  attr_accessor :isbn, :title, :page_count, :published_date, :thumbnail_url, :short_description, :long_description,
                :status, :authors, :categories
end
