# frozen_string_literal: true

class Policy::CreateService
  MAXIMUM_ATTEMPTS = 5

  # @param [Policy::CreateContract] contract
  def initialize(contract)
    @contract = contract
  end

  # @return [String]
  def call
    policy = Policy.create!(numero: generate_number, data_emissao: @contract.data_emissao, inicio_vigencia: @contract.inicio_vigencia,
                            fim_vigencia: @contract.fim_vigencia, importancia_segurada: @contract.importancia_segurada,
                            lmg: @contract.importancia_segurada, status: Policy::Status::ATIVA)

    Rails.logger.info("Policy with number #{policy.numero} created successfuly")
    policy.numero
  end

  private 

  # @return [String]
  def generate_number
    attempts = 0
    loop do
      attempts += 1
      raise Errors::UnexpectedError.new("Falha ao gerar número único") if attempts >= MAXIMUM_ATTEMPTS

      candidate = "#{rand(1..9999).to_s.rjust(4, '0')}#{Time.current.to_i}"
      conflicts = Policy.find_conflicts(numero: candidate)
      if conflicts.empty?
        Rails.logger.info("Policy number #{candidate} generated successfully")
        return candidate
      end

      Rails.logger.warn("Policy number #{candidate} conflict detected for candidate")
    end
  end
end
