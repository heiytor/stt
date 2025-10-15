# frozen_string_literal: true

class Policy::FindOneService
  # @param [Policy::FindOneContract] contract
  def initialize(contract)
    @contract = contract
  end

  # @return [PolicySerializer]
  def call
    policy = Policy.where(numero: @contract.numero).first rescue nil
    raise Errors::NotFoundError.new("Policy with numero '#{@contract.numero}' not found") if policy.nil?

    PolicySerializer.new(policy)
  end
end
