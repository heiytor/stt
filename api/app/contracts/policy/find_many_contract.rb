# frozen_string_literal: true

class Policy::FindManyContract < ApplicationContract
  attributes do
    attribute :page, Types::Integer.default(1)
    attribute :size, Types::Integer.default(10)
    attribute :sort_by, Types::Symbol.default(:created_at)
    attribute :sort_order, Types::Symbol.default(:desc)
    attribute :status, Types::String.optional.default(nil)
    attribute :inicio_vigencia_lte, Types::Params::Date.optional.default(nil)
    attribute :inicio_vigencia_gte, Types::Params::Date.optional.default(nil)
    attribute :fim_vigencia_lte, Types::Params::Date.optional.default(nil)
    attribute :fim_vigencia_gte, Types::Params::Date.optional.default(nil)
  end

  validations do
    params(BaseSchema::Paginator, BaseSchema::Sorter) do
      optional(:status).maybe(:string, included_in?: Policy::Status.all.map(&:to_s))
      optional(:inicio_vigencia_lte).maybe(:string)
      optional(:inicio_vigencia_gte).maybe(:string)
      optional(:fim_vigencia_lte).maybe(:string)
      optional(:fim_vigencia_gte).maybe(:string)
    end
  end
end
