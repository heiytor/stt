# frozen_string_literal: true

require "rails_helper"

RSpec.describe Policy::FindOneContract do
  describe "validations" do
    let(:valid_attributes) do
      {
        numero: "01681760574732"
      }
    end

    context "when numero is invalid" do
      it "fails when numero is missing" do
        contract = described_class.from({}, raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:numero]).to include("is missing")
      end

      it "fails when numero is blank" do
        contract = described_class.from({ numero: "" }, raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:numero]).to include("must be filled")
      end

      it "fails when numero is nil" do
        contract = described_class.from({ numero: nil }, raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:numero]).to include("must be filled")
      end

      it "fails when numero is not a string" do
        contract = described_class.from({ numero: 123 }, raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:numero]).to include("must be a string")
      end

      it "fails when numero exceeds maximum size" do
        contract = described_class.from({ numero: "a" * 15 }, raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:numero]).to include("size cannot be greater than 14")
      end
    end

    context "when all attributes are valid" do
      it "succeeds with valid numero" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
        expect(contract.numero).to eq("01681760574732")
      end

      it "succeeds with short numero" do
        contract = described_class.from({ numero: "123" }, raise_errors: false)

        expect(contract.valid?).to be true
      end

      it "succeeds at maximum size limit" do
        contract = described_class.from({ numero: "a" * 14 }, raise_errors: false)

        expect(contract.valid?).to be true
      end
    end
  end
end