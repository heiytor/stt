# frozen_string_literal: true

class PolicySerializer
  include JSONAPI::Serializer

  attributes :numero, :data_emissao, :inicio_vigencia, :fim_vigencia,
             :importancia_segurada, :lmg, :status, :created_at, :updated_at
end
