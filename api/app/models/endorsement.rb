class Endorsement < ApplicationRecord
  include AttributeEnumable
  include ConflictFindable

  belongs_to :policy, counter_cache: true
  belongs_to :cancelled_endorsement, class_name: 'Endorsement', optional: true
  has_one :cancelled_by_endorsement, class_name: 'Endorsement', foreign_key: 'cancelled_endorsement_id'

  attribute_as_enum :tipo, values: [:aumento_is, :reducao_is, :alteracao_vigencia, :aumento_is_alteracao_vigencia,
                                    :reducao_is_alteracao_vigencia, :cancelamento]
end
