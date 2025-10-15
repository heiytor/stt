# frozen_string_literal: true

class Policy::CreateContract < ApplicationContract
  attributes do
    attribute :data_emissao, Types::Date
    attribute :inicio_vigencia, Types::Date
    attribute :fim_vigencia, Types::Date
    attribute :importancia_segurada, Types::Integer
  end

  validations do
    params do
      required(:data_emissao).filled(:date)
      required(:inicio_vigencia).filled(:date)
      required(:fim_vigencia).filled(:date)
      required(:importancia_segurada).filled(:integer)
    end

    rule(:fim_vigencia, :inicio_vigencia) do
      if values[:fim_vigencia] && values[:inicio_vigencia] && values[:fim_vigencia] < values[:inicio_vigencia]
        key(:fim_vigencia).failure("deve ser posterior ao início da vigência")
      end
    end

    rule(:inicio_vigencia, :data_emissao) do
      if values[:inicio_vigencia] && values[:data_emissao]
        diff = (values[:inicio_vigencia] - values[:data_emissao]).to_i
        if diff.abs > 30
          key(:inicio_vigencia).failure("deve estar no máximo 30 dias da data de emissão")
        end
      end
    end

    rule(:importancia_segurada) do
      if values[:importancia_segurada] && values[:importancia_segurada] <= 0
        key(:importancia_segurada).failure("deve ser maior que zero")
      end
    end
  end
end
