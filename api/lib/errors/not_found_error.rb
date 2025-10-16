# frozen_string_literal: true

module Errors
  class NotFoundError < CustomError
    def initialize(message = "Resource not found")
      super(404, message)
    end
  end
end