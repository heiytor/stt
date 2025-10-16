# frozen_string_literal: true

require "rails_helper"

RSpec.describe Endorsement::FindOneContract do
  describe "validations" do
    let(:valid_attributes) do
      {
        policy_numero: "01681760574732",
        id: SecureRandom.uuid
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

    context "when id is invalid" do
      it "fails when id is missing" do
        contract = described_class.from(valid_attributes.except(:id), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:id]).to include("is missing")
      end

      it "fails when id is not a string" do
        contract = described_class.from(valid_attributes.merge(id: 123), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:id]).to include("must be a string")
      end

      it "fails when id is blank" do
        contract = described_class.from(valid_attributes.merge(id: ""), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:id]).to include("must be filled")
      end

      it "fails when id exceeds max size" do
        contract = described_class.from(valid_attributes.merge(id: "a" * 37), raise_errors: false)

        expect(contract.valid?).to be false
        expect(contract.errors[:id]).to include("size cannot be greater than 36")
      end
    end

    context "when all attributes are valid" do
      it "succeeds with valid policy_numero and id" do
        contract = described_class.from(valid_attributes, raise_errors: false)

        expect(contract.valid?).to be true
        expect(contract.errors).to be_empty
      end

      it "succeeds with UUID format id" do
        contract = described_class.from({
          policy_numero: "01681760574732",
          id: "550e8400-e29b-41d4-a716-446655440000"
        }, raise_errors: false)

        expect(contract.valid?).to be true
      end

      it "succeeds with exactly 14 character policy_numero" do
        contract = described_class.from(valid_attributes.merge(policy_numero: "a" * 14), raise_errors: false)

        expect(contract.valid?).to be true
      end

      it "succeeds with exactly 36 character id" do
        contract = described_class.from(valid_attributes.merge(id: "a" * 36), raise_errors: false)

        expect(contract.valid?).to be true
      end
    end
  end
end