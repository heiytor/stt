# frozen_string_literal: true

module Errors
  class NotFoundError < CustomError
    def initialize(message = "Resource not found")
      super(message, 404)
    end
  end
end