# frozen_string_literal: true

class Policy::CreateService
  MAXIMUM_ATTEMPTS = 5

  # @param [Policy::CreateContract] contract
  def initialize(contract)
    @contract = contract
  end

  # @return [String]
  def call
    number = loop do
      attempts ||= 0
      attempts += 1
      raise Errors::UnexpectedError.new("Falha ao gerar número único") if attempts > MAXIMUM_ATTEMPTS

      candidate = "#{rand(1..9999).to_s.rjust(4, '0')}#{Time.current.to_i}"
      conflicts = Policy.find_conflicts(numero: candidate)
      if conflicts.any?
        raise Errors::ConflictsError.new("conflicts found", conflicts) if attempts >= MAXIMUM_ATTEMPTS
        next
      end

      break candidate
    end

    policy = Policy.create!(numero: number, data_emissao: @contract.data_emissao, inicio_vigencia: @contract.inicio_vigencia,
                            fim_vigencia: @contract.fim_vigencia, importancia_segurada: @contract.importancia_segurada,
                            lmg: @contract.importancia_segurada, status: Policy::Status::ATIVA)

    number
  end
end
