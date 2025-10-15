#  frozen_string_literal: true

class Errors::CustomError < StandardError
  # @return [Exception]
  attr_reader :error
  # @return [Integer]
  attr_reader :status
  # @return [Hash]
  attr_reader :body

  def initialize(status=:internal_server_error, message="", errors={})
    super()

    @status = status
    @body = {}
    body[:message] = message if message.present?
    body[:errors] = errors if errors.present?
  end
end
