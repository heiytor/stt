class Policy < ApplicationRecord
  include AttributeEnumable
  include ConflictFindable

  has_many :endorsements, dependent: :destroy

  attribute_as_enum :status, values: [:ativa, :baixada]
end
