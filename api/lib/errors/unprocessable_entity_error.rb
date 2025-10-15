# frozen_string_literal: true

class Errors::UnprocessableEntityError < Errors::CustomError
  def initialize(message="unprocesasble entity", errors={})
    super(:unprocessable_entity, message, errors)
  end
end
