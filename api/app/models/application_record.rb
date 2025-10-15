# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create do
    |r| r.id ||= SecureRandom.uuid_v7
  end
end
