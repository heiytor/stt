# frozen_string_literal: true

require "rails_helper"

RSpec.describe Policy::CreateContract do
  describe "validations" do
    let(:valid_attributes) do
      {
        data_emissao: Date.current,
        inicio_vigencia: Date.current + 10.days,
        fim_vigencia: Date.current + 1.year,
        importancia_segurada: 100_000
      }
    end

    context "when data_emissao is invalid" do
      it "fails when data_emissao is missing" do
        contract = described_class.from(valid_attributes.except(:data_emissao), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:data_emissao]).to include("is missing")
      end

      it "fails when data_emissao is not a date" do
        contract = described_class.from(valid_attributes.merge(data_emissao: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:data_emissao]).to include("must be a date")
      end

      it "fails when data_emissao is blank" do
        contract = described_class.from(valid_attributes.merge(data_emissao: ""), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:data_emissao]).to include("must be filled")
      end
    end

    context "when inicio_vigencia is invalid" do
      it "fails when inicio_vigencia is missing" do
        contract = described_class.from(valid_attributes.except(:inicio_vigencia), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:inicio_vigencia]).to include("is missing")
      end

      it "fails when inicio_vigencia is not a date" do
        contract = described_class.from(valid_attributes.merge(inicio_vigencia: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:inicio_vigencia]).to include("must be a date")
      end

      it "fails when inicio_vigencia is more than 30 days from data_emissao" do
        contract = described_class.from(valid_attributes.merge(data_emissao: Date.current, inicio_vigencia: Date.current + 31.days),
                                        raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:inicio_vigencia]).to include("deve estar no máximo 30 dias da data de emissão")
      end

      it "fails when inicio_vigencia is more than 30 days before data_emissao" do
        contract = described_class.from(valid_attributes.merge(data_emissao: Date.current, inicio_vigencia: Date.current - 31.days),
                                        raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:inicio_vigencia]).to include("deve estar no máximo 30 dias da data de emissão")
      end
    end

    context "when fim_vigencia is invalid" do
      it "fails when fim_vigencia is missing" do
        contract = described_class.from(valid_attributes.except(:fim_vigencia), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:fim_vigencia]).to include("is missing")
      end

      it "fails when fim_vigencia is not a date" do
        contract = described_class.from(valid_attributes.merge(fim_vigencia: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:fim_vigencia]).to include("must be a date")
      end

      it "fails when fim_vigencia is before inicio_vigencia" do
        contract = described_class.from(valid_attributes.merge(inicio_vigencia: Date.current + 10.days,
                                                               fim_vigencia: Date.current + 5.days), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:fim_vigencia]).to include("deve ser posterior ao início da vigência")
      end
    end

    context "when importancia_segurada is invalid" do
      it "fails when importancia_segurada is missing" do
        contract = described_class.from(valid_attributes.except(:importancia_segurada), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:importancia_segurada]).to include("is missing")
      end

      it "fails when importancia_segurada is not an integer" do
        contract = described_class.from(valid_attributes.merge(importancia_segurada: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:importancia_segurada]).to include("must be an integer")
      end

      it "fails when importancia_segurada is zero" do
        contract = described_class.from(valid_attributes.merge(importancia_segurada: 0), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:importancia_segurada]).to include("deve ser maior que zero")
      end

      it "fails when importancia_segurada is negative" do
        contract = described_class.from(valid_attributes.merge(importancia_segurada: -1000), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:importancia_segurada]).to include("deve ser maior que zero")
      end
    end

    context "when all attributes are valid" do
      it "succeeds" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
      end

      it "succeeds when inicio_vigencia is exactly 30 days from data_emissao" do
        contract = described_class.from(valid_attributes.merge(data_emissao: Date.current, inicio_vigencia: Date.current + 30.days),
                                        raise_errors: false)

        expect(contract.valid?).to be true
      end

      it "succeeds when fim_vigencia equals inicio_vigencia" do
        date = Date.current + 10.days
        contract = described_class.from(valid_attributes.merge(inicio_vigencia: date, fim_vigencia: date), raise_errors: false)

        expect(contract.valid?).to be true
      end
    end
  end
end
