# frozen_string_literal: true

class Errors::BadRequestError < Errors::CustomError
  def initialize(message="bad request", errors={})
    super(:bad_request, message, errors)
  end
end
