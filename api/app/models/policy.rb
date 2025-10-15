class Policy < ApplicationRecord
  has_many :endorsements, dependent: :destroy
end
