# frozen_string_literal: true

class Errors::UnexpectedError < Errors::CustomError
  def initialize(message="unexpected error")
    super(:internal_server_error, message)
  end
end
