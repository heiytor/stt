# frozen_string_literal: true

class Endorsement::CreateService
  # @param [Endorsement::CreateContract] contract
  def initialize(contract)
    @contract = contract
  end

  # @return [String]
  def call
    policy = Policy.where(numero: @contract.policy_numero).first rescue nil
    raise Errors::NotFoundError.new("Policy with numero '#{@contract.policy_numero}' not found") if policy.nil?

    tipo = determine_endorsement_type(policy)
    endorsement = tipo == Endorsement::Tipo::CANCELAMENTO ? handle_cancellation(policy) : create_regular_endorsement(policy, tipo)
    endorsement.id
  end

  private

  # @param [Policy] policy
  #
  # @return [String]
  def determine_endorsement_type(policy)
    has_is_change = @contract.importancia_segurada && @contract.importancia_segurada != policy.importancia_segurada
    has_vigencia_change = (@contract.inicio_vigencia && @contract.inicio_vigencia != policy.inicio_vigencia) ||
                         (@contract.fim_vigencia && @contract.fim_vigencia != policy.fim_vigencia)

    return Endorsement::Tipo::CANCELAMENTO if !@contract.importancia_segurada && !@contract.inicio_vigencia && !@contract.fim_vigencia

    if has_is_change && has_vigencia_change
      @contract.importancia_segurada > policy.importancia_segurada ?
        Endorsement::Tipo::AUMENTO_IS_ALTERACAO_VIGENCIA :
        Endorsement::Tipo::REDUCAO_IS_ALTERACAO_VIGENCIA
    elsif has_is_change
      @contract.importancia_segurada > policy.importancia_segurada ?
        Endorsement::Tipo::AUMENTO_IS :
        Endorsement::Tipo::REDUCAO_IS
    elsif has_vigencia_change
      Endorsement::Tipo::ALTERACAO_VIGENCIA
    else
      Endorsement::Tipo::CANCELAMENTO
    end
  end

  # @param [Policy] policy
  #
  # @return [Endorsement]
  def handle_cancellation(policy)
      last_valid_endorsement = policy.endorsements
                                    .where(cancelled_by_endorsement_id: nil)
                                    .where.not(tipo: 'cancelamento')
                                    .order(:created_at)
                                    .last

      raise Errors::UnprocessableEntityError.new("No valid endorsement to cancel") if last_valid_endorsement.nil?

      cancellation_endorsement = Endorsement.create!(
        policy: policy,
        data_emissao: @contract.data_emissao,
        tipo: Endorsement::Tipo::CANCELAMENTO,
        cancelled_endorsement: last_valid_endorsement
      )

      valid_endorsements = policy.endorsements
                                .where(cancelled_by_endorsement_id: nil)
                                .where.not(tipo: 'cancelamento')
                                .where.not(id: last_valid_endorsement.id)
                                .order(:created_at)

      if valid_endorsements.any?
        last_valid = valid_endorsements.last
        policy.update!(
          importancia_segurada: last_valid.importancia_segurada,
          lmg: last_valid.importancia_segurada,
          inicio_vigencia: last_valid.inicio_vigencia,
          fim_vigencia: last_valid.fim_vigencia
        )
      else
        policy.update!(status: Policy::Status::BAIXADA)
      end

      Rails.logger.info("Cancellation endorsement #{cancellation_endorsement.id} created for policy #{policy.numero}")
      cancellation_endorsement
  end

  # @param [Policy] policy
  # @param [String] tipo
  #
  # @return [Endorsement]
  def create_regular_endorsement(policy, tipo)
      new_is = @contract.importancia_segurada || policy.importancia_segurada
      new_inicio = @contract.inicio_vigencia || policy.inicio_vigencia
      new_fim = @contract.fim_vigencia || policy.fim_vigencia

      raise Errors::UnprocessableEntityError.new("LMG cannot be negative") if new_is < 0

      endorsement = Endorsement.create!(
        policy: policy,
        data_emissao: @contract.data_emissao,
        tipo: tipo,
        importancia_segurada: new_is,
        inicio_vigencia: new_inicio,
        fim_vigencia: new_fim
      )

      policy.update!(
        importancia_segurada: new_is,
        lmg: new_is,
        inicio_vigencia: new_inicio,
        fim_vigencia: new_fim
      )

      Rails.logger.info("Endorsement #{endorsement.id} created for policy #{policy.numero}")
      endorsement
  end
end
