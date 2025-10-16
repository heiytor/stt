# frozen_string_literal: true

require "rails_helper"

RSpec.describe Policy::FindManyContract do
  describe "validations" do
    let(:valid_attributes) do
      {
        page: 1,
        size: 10,
        sort_by: :created_at,
        sort_order: :desc,
        status: "ativa",
        inicio_vigencia_gte: "2024-01-01",
        inicio_vigencia_lte: "2024-12-31",
        fim_vigencia_gte: "2025-01-01",
        fim_vigencia_lte: "2025-12-31"
      }
    end

    context "when pagination parameters are invalid" do
      it "fails when page is zero" do
        contract = described_class.from(valid_attributes.merge(page: 0), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:page]).to include("must be greater than or equal to 1")
      end

      it "fails when page is negative" do
        contract = described_class.from(valid_attributes.merge(page: -1), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:page]).to include("must be greater than or equal to 1")
      end

      it "fails when size is zero" do
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

    context "when sort parameters are invalid" do
      it "fails when sort_order is invalid" do
        contract = described_class.from(valid_attributes.merge(sort_order: :invalid), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:sort_order]).to include("must be one of: asc, desc")
      end
    end

    context "when status parameter is invalid" do
      it "fails when status is invalid" do
        contract = described_class.from(valid_attributes.merge(status: "invalid"), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:status]).to include("must be one of: ativa, baixada")
      end
    end

    context "when all attributes are valid" do
      it "succeeds with all parameters" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
      end

      it "succeeds with minimal parameters" do
        contract = described_class.from({}, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.page).to eq(1)
        expect(contract.size).to eq(10)
        expect(contract.sort_by).to eq(:created_at)
        expect(contract.sort_order).to eq(:desc)
      end

      it "succeeds with valid status" do
        contract = described_class.from({ status: "baixada" }, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.status).to eq("baixada")
      end

      it "succeeds with nil status" do
        contract = described_class.from({ status: nil }, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.status).to be_nil
      end

      it "succeeds with date filters" do
        contract = described_class.from({
          inicio_vigencia_gte: "2024-01-01",
          fim_vigencia_lte: "2024-12-31"
        }, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.inicio_vigencia_gte).to eq(Date.parse("2024-01-01"))
        expect(contract.fim_vigencia_lte).to eq(Date.parse("2024-12-31"))
      end
    end
  end
end