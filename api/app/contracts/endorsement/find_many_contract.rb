# frozen_string_literal: true

class Endorsement::FindManyContract < ApplicationContract
  attributes do
    attribute :policy_numero, Types::String
    attribute :page, Types::Integer.default(1)
    attribute :size, Types::Integer.default(10)
    attribute :sort_by, Types::Symbol.default(:created_at)
    attribute :sort_order, Types::Symbol.default(:desc)
    attribute :tipo, Types::String.optional.default(nil)
    attribute :data_emissao_lte, Types::Params::Date.optional.default(nil)
    attribute :data_emissao_gte, Types::Params::Date.optional.default(nil)
  end

  validations do
    params(BaseSchema::Paginator, BaseSchema::Sorter) do
      required(:policy_numero).filled(:string, max_size?: 14)
      optional(:tipo).maybe(:string, included_in?: Endorsement::Tipo.all.map(&:to_s))
      optional(:data_emissao_lte).maybe(:string)
      optional(:data_emissao_gte).maybe(:string)
    end
  end
end
