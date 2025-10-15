# frozen_string_literal: true

class Policy::FindManyService
  # @param [Policy::FindManyContract] contract
  def initialize(contract)
    @contract = contract
  end

  def call
    criteria = Policy.unscoped
    criteria = criteria.where(status: @contract.status) if @contract.status.present?
    criteria = criteria.where(inicio_vigencia: ..@contract.inicio_vigencia_lte) if @contract.inicio_vigencia_lte.present?
    criteria = criteria.where(inicio_vigencia: @contract.inicio_vigencia_gte..) if @contract.inicio_vigencia_gte.present?
    criteria = criteria.where(fim_vigencia: ..@contract.fim_vigencia_lte) if @contract.fim_vigencia_lte.present?
    criteria = criteria.where(fim_vigencia: @contract.fim_vigencia_gte..) if @contract.fim_vigencia_gte.present?

    policies = criteria.order(@contract.sort_by => @contract.sort_order).page(@contract.page).per(@contract.size)
    [PolicySerializer.new(policies.to_a), policies.total_count]
  end
end
