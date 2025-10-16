# frozen_string_literal: true

class Endorsement::CreateContract < ApplicationContract
  attributes do
    attribute :policy_numero, Types::String
    attribute :data_emissao, Types::Date
    attribute :importancia_segurada, Types::Integer.optional.default(nil)
    attribute :inicio_vigencia, Types::Date.optional.default(nil)
    attribute :fim_vigencia, Types::Date.optional.default(nil)
  end

  validations do
    params do
      required(:policy_numero).filled(:string, max_size?: 14)
      required(:data_emissao).filled(:date)
      optional(:importancia_segurada).maybe(:integer)
      optional(:inicio_vigencia).maybe(:date)
      optional(:fim_vigencia).maybe(:date)
    end

    rule(:fim_vigencia, :inicio_vigencia) do
      if values[:fim_vigencia] && values[:inicio_vigencia] && values[:fim_vigencia] < values[:inicio_vigencia]
        key(:fim_vigencia).failure("deve ser posterior ao início da vigência")
      end
    end

    rule(:importancia_segurada) do
      if values[:importancia_segurada] && values[:importancia_segurada] <= 0
        key(:importancia_segurada).failure("deve ser maior que zero")
      end
    end
  end
end