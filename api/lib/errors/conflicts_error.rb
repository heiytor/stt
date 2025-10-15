# frozen_string_literal: true

module Errors
  class ConflictsError < CustomError
    def initialize(message="conflicts found", conflicts=[])
      super(message, 409)
      @conflicts = conflicts
    end

    def to_h
      super.merge(conflicts: @conflicts)
    end
  end
end
