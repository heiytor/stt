# frozen_string_literal: true

module ConflictFindable
  extend ActiveSupport::Concern

  class_methods do
    def find_conflicts(**kargs)
      ignore_id = kargs.delete(:ignore)
      conflicts = []

      criteria = where(kargs.map { |attr, value| arel_table[attr].eq(value) }.reduce(:or))
      criteria = criteria.where.not(id: ignore_id) if ignore_id.present?
      criteria.find_each do |record|
        kargs.each { |attr, value| conflicts << attr if record.send(attr) == value }
      end

      conflicts.uniq.map(&:to_sym)
    end
  end
end
