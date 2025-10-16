# frozen_string_literal: true

class EndorsementSerializer
  include JSONAPI::Serializer

  attributes :data_emissao, :tipo, :importancia_segurada, :inicio_vigencia,
             :fim_vigencia, :created_at, :updated_at

  belongs_to :policy
  belongs_to :cancelled_endorsement, serializer: EndorsementSerializer, optional: true
  has_one :cancelled_by_endorsement, serializer: EndorsementSerializer, optional: true
end