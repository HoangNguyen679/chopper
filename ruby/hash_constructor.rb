# frozen_string_literal: true

# Init object with hash values
module HashConstructor
  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
