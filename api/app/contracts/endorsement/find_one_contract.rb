# frozen_string_literal: true

class Endorsement::FindOneContract < ApplicationContract
  attributes do
    attribute :policy_numero, Types::String
    attribute :id, Types::String
  end

  validations do
    params do
      required(:policy_numero).filled(:string, max_size?: 14)
      required(:id).filled(:string, max_size?: 36)
    end
  end
end