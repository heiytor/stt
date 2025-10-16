# frozen_string_literal: true

require "rails_helper"

RSpec.describe Endorsement::FindManyContract do
  describe "validations" do
    let(:valid_attributes) do
      {
        policy_numero: "01681760574732"
      }
    end

    context "when policy_numero is invalid" do
      it "fails when policy_numero is missing" do
        contract = described_class.from(valid_attributes.except(:policy_numero), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:policy_numero]).to include("is missing")
      end

      it "fails when policy_numero is not a string" do
        contract = described_class.from(valid_attributes.merge(policy_numero: 123), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:policy_numero]).to include("must be a string")
      end

      it "fails when policy_numero is blank" do
        contract = described_class.from(valid_attributes.merge(policy_numero: ""), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:policy_numero]).to include("must be filled")
      end

      it "fails when policy_numero exceeds max size" do
        contract = described_class.from(valid_attributes.merge(policy_numero: "a" * 15), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:policy_numero]).to include("size cannot be greater than 14")
      end
    end

    context "when tipo is invalid" do
      it "fails when tipo is not in allowed values" do
        contract = described_class.from(valid_attributes.merge(tipo: "invalid_tipo"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:tipo]).to include("must be one of: aumento_is, reducao_is, alteracao_vigencia, aumento_is_alteracao_vigencia, reducao_is_alteracao_vigencia, cancelamento")
      end

      it "succeeds when tipo is valid" do
        Endorsement::Tipo.all.each do |tipo|
          contract = described_class.from(valid_attributes.merge(tipo: tipo.to_s), raise_errors: false)

          expect(contract.valid?).to be true
        end
      end
    end

    context "when pagination parameters are invalid" do
      it "fails when page is not an integer" do
        contract = described_class.from(valid_attributes.merge(page: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:page]).to include("must be an integer")
      end

      it "fails when size is not an integer" do
        contract = described_class.from(valid_attributes.merge(size: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:size]).to include("must be an integer")
      end

      it "fails when page is less than 1" do
        contract = described_class.from(valid_attributes.merge(page: 0), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:page]).to include("must be greater than or equal to 1")
      end

      it "fails when size is less than 1" do
        contract = described_class.from(valid_attributes.merge(size: 0), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:size]).to include("must be greater than or equal to 1")
      end

      it "fails when size exceeds maximum" do
        contract = described_class.from(valid_attributes.merge(size: 101), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:size]).to include("must be less than or equal to 100")
      end
    end

    context "when sorting parameters are invalid" do
      it "fails when sort_by is not a valid field" do
        contract = described_class.from(valid_attributes.merge(sort_by: "invalid_field"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:sort_by]).to include("must be one of: created_at, updated_at, data_emissao, tipo")
      end

      it "fails when sort_order is not asc or desc" do
        contract = described_class.from(valid_attributes.merge(sort_order: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:sort_order]).to include("must be one of: asc, desc")
      end
    end

    context "when date filters are invalid" do
      it "fails when data_emissao_gte is not a valid date string" do
        contract = described_class.from(valid_attributes.merge(data_emissao_gte: "invalid-date"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:data_emissao_gte]).to include("must be a string")
      end

      it "fails when data_emissao_lte is not a valid date string" do
        contract = described_class.from(valid_attributes.merge(data_emissao_lte: "invalid-date"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:data_emissao_lte]).to include("must be a string")
      end
    end

    context "when all attributes are valid" do
      it "succeeds with only required fields" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
      end

      it "succeeds with all optional fields" do
        contract = described_class.from(valid_attributes.merge(
          page: 2,
          size: 25,
          sort_by: "data_emissao",
          sort_order: "asc",
          tipo: "aumento_is",
          data_emissao_gte: "2024-01-01",
          data_emissao_lte: "2024-12-31"
        ), raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
      end

      it "succeeds with default values when not provided" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.page).to eq(1)
        expect(contract.size).to eq(10)
        expect(contract.sort_by).to eq(:created_at)
        expect(contract.sort_order).to eq(:desc)
        expect(contract.tipo).to be_nil
      end

      it "succeeds with exactly 14 character policy_numero" do
        contract = described_class.from(valid_attributes.merge(policy_numero: "a" * 14), raise_errors: false)

        expect(contract.valid?).to be true
      end
    end
  end
end