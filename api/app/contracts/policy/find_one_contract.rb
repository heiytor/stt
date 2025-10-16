# frozen_string_literal: true

class Policy::FindOneContract < ApplicationContract
  attributes do
    attribute :numero, Types::String
  end

  validations do
    params do
      required(:numero).filled(:string, max_size?: 14)
    end
  end
end
