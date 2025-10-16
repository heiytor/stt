# frozen_string_literal: true

class Endorsement::FindOneService
  # @param [Endorsement::FindOneContract] contract
  def initialize(contract)
    @contract = contract
  end

  # @return [EndorsementSerializer]
  def call
    policy = Policy.where(numero: @contract.policy_numero).first rescue nil
    raise Errors::NotFoundError.new("Policy with numero '#{@contract.policy_numero}' not found") if policy.nil?

    endorsement = policy.endorsements.where(id: @contract.id).first rescue nil
    raise Errors::NotFoundError.new("Endorsement with id '#{@contract.id}' not found") if endorsement.nil?

    EndorsementSerializer.new(endorsement)
  end
end
