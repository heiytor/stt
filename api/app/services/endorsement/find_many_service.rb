# frozen_string_literal: true

class Endorsement::FindManyService
  # @param [Endorsement::FindManyContract] contract
  def initialize(contract)
    @contract = contract
  end

  def call
    policy = Policy.where(numero: @contract.policy_numero).first rescue nil
    raise Errors::NotFoundError.new("Policy with numero '#{@contract.policy_numero}' not found") if policy.nil?

    criteria = policy.endorsements
    criteria = criteria.where(tipo: @contract.tipo) if @contract.tipo.present?
    criteria = criteria.where(data_emissao: ..@contract.data_emissao_lte) if @contract.data_emissao_lte.present?
    criteria = criteria.where(data_emissao: @contract.data_emissao_gte..) if @contract.data_emissao_gte.present?

    endorsements = criteria.order(@contract.sort_by => @contract.sort_order).page(@contract.page).per(@contract.size)
    [EndorsementSerializer.new(endorsements.to_a), endorsements.total_count]
  end
end
