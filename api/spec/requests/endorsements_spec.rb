# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Endorsements API", type: :request do
  let!(:policy) do
    create(:policy,
           numero: "01681760574732",
           data_emissao: Date.parse("2024-10-15"),
           inicio_vigencia: Date.parse("2024-10-25"),
           fim_vigencia: Date.parse("2025-10-25"),
           importancia_segurada: 50_000_000,
           lmg: 50_000_000,
           status: Policy::Status::ATIVA)
  end

  describe "GET /policies/:numero/endorsements" do
    context "when listing endorsements without filters" do
      let!(:endorsement1) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-01"), tipo: Endorsement::Tipo::AUMENTO_IS) }
      let!(:endorsement2) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-15"), tipo: Endorsement::Tipo::REDUCAO_IS) }

      before do
        get "/policies/#{policy.numero}/endorsements"
      end

      it "returns 200 status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns X-Total-Count header" do
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "returns endorsements in JSONAPI format" do
        response_data = JSON.parse(response.body)

        expect(response_data).to have_key("data")
        expect(response_data["data"]).to be_an(Array)
        expect(response_data["data"].size).to eq(2)
        expect(response_data["data"].first).to have_key("id")
        expect(response_data["data"].first).to have_key("type")
        expect(response_data["data"].first).to have_key("attributes")
      end
    end

    context "when filtering by tipo" do
      let!(:endorsement_aumento) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-01"), tipo: Endorsement::Tipo::AUMENTO_IS) }
      let!(:endorsement_reducao) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-15"), tipo: Endorsement::Tipo::REDUCAO_IS) }

      it "filters endorsements by tipo aumento_is" do
        get "/policies/#{policy.numero}/endorsements", params: { tipo: "aumento_is" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["tipo"]).to eq("aumento_is")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end

      it "filters endorsements by tipo reducao_is" do
        get "/policies/#{policy.numero}/endorsements", params: { tipo: "reducao_is" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["tipo"]).to eq("reducao_is")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end
    end

    context "when filtering by data_emissao dates" do
      let!(:endorsement_early) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-01-01"), tipo: Endorsement::Tipo::AUMENTO_IS) }
      let!(:endorsement_middle) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-06-01"), tipo: Endorsement::Tipo::REDUCAO_IS) }
      let!(:endorsement_late) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-12-01"), tipo: Endorsement::Tipo::ALTERACAO_VIGENCIA) }

      it "filters by data_emissao_gte" do
        get "/policies/#{policy.numero}/endorsements", params: { data_emissao_gte: "2024-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by data_emissao_lte" do
        get "/policies/#{policy.numero}/endorsements", params: { data_emissao_lte: "2024-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by data_emissao range" do
        get "/policies/#{policy.numero}/endorsements", params: { data_emissao_gte: "2024-02-01", data_emissao_lte: "2024-11-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["data_emissao"]).to eq("2024-06-01")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end
    end

    context "when testing pagination" do
      before do
        15.times { |i| create(:endorsement, policy: policy, data_emissao: Date.current + i.days, tipo: Endorsement::Tipo::AUMENTO_IS) }
      end

      it "respects default pagination (page 1, size 10)" do
        get "/policies/#{policy.numero}/endorsements"

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(10)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "respects custom page size" do
        get "/policies/#{policy.numero}/endorsements", params: { size: 5 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(5)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "respects page number" do
        get "/policies/#{policy.numero}/endorsements", params: { page: 2, size: 5 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(5)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "handles last page with remaining items" do
        get "/policies/#{policy.numero}/endorsements", params: { page: 3, size: 7 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end
    end

    context "when testing sorting" do
      let!(:endorsement1) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-01"), tipo: Endorsement::Tipo::AUMENTO_IS, created_at: 1.day.ago) }
      let!(:endorsement2) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-02"), tipo: Endorsement::Tipo::REDUCAO_IS, created_at: 2.days.ago) }
      let!(:endorsement3) { create(:endorsement, policy: policy, data_emissao: Date.parse("2024-11-03"), tipo: Endorsement::Tipo::ALTERACAO_VIGENCIA, created_at: 3.days.ago) }

      it "sorts by created_at desc by default" do
        get "/policies/#{policy.numero}/endorsements"

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["data_emissao"]).to eq("2024-11-01")
        expect(response_data["data"][1]["attributes"]["data_emissao"]).to eq("2024-11-02")
        expect(response_data["data"][2]["attributes"]["data_emissao"]).to eq("2024-11-03")
      end

      it "sorts by created_at asc when specified" do
        get "/policies/#{policy.numero}/endorsements", params: { sort_order: "asc" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["data_emissao"]).to eq("2024-11-03")
        expect(response_data["data"][1]["attributes"]["data_emissao"]).to eq("2024-11-02")
        expect(response_data["data"][2]["attributes"]["data_emissao"]).to eq("2024-11-01")
      end

      it "sorts by data_emissao when specified" do
        get "/policies/#{policy.numero}/endorsements", params: { sort_by: "data_emissao", sort_order: "asc" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["data_emissao"]).to eq("2024-11-01")
        expect(response_data["data"][1]["attributes"]["data_emissao"]).to eq("2024-11-02")
        expect(response_data["data"][2]["attributes"]["data_emissao"]).to eq("2024-11-03")
      end
    end
  end

  describe "GET /policies/:numero/endorsements/:id" do
    context "when policy does not exist" do
      before do
        get "/policies/nonexistent/endorsements/some-id"
      end

      it "returns 404 status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found error message" do
        expected_response = {
          "message" => "Policy with numero 'nonexistent' not found"
        }

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "when endorsement does not exist" do
      before do
        get "/policies/#{policy.numero}/endorsements/nonexistent"
      end

      it "returns 404 status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found error message" do
        expected_response = {
          "message" => "Endorsement with id 'nonexistent' not found"
        }

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "when endorsement exists" do
      let!(:endorsement) do
        create(:endorsement,
               policy: policy,
               data_emissao: Date.parse("2024-11-01"),
               tipo: Endorsement::Tipo::AUMENTO_IS,
               importancia_segurada: 75_000_000,
               inicio_vigencia: Date.parse("2024-11-15"),
               fim_vigencia: Date.parse("2025-11-15"))
      end

      before do
        get "/policies/#{policy.numero}/endorsements/#{endorsement.id}"
      end

      it "returns 200 status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns endorsement data with correct structure and attributes" do
        expected_response = {
          "data" => {
            "id" => endorsement.id,
            "type" => "endorsement",
            "attributes" => {
              "data_emissao" => "2024-11-01",
              "tipo" => "aumento_is",
              "importancia_segurada" => 75_000_000,
              "inicio_vigencia" => "2024-11-15",
              "fim_vigencia" => "2025-11-15",
              "created_at" => endorsement.created_at.iso8601(3),
              "updated_at" => endorsement.updated_at.iso8601(3)
            },
            "relationships" => {
              "policy" => {
                "data" => {
                  "id" => policy.id,
                  "type" => "policy"
                }
              },
              "cancelled_endorsement" => {
                "data" => nil
              },
              "cancelled_by_endorsement" => {
                "data" => nil
              }
            }
          }
        }

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end
  end

  describe "POST /policies/:numero/endorsements" do
    context "when creating aumento_is endorsement" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 75_000_000
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "returns 201 status" do
        expect(response).to have_http_status(:created)
      end

      it "returns X-Inserted-Id header" do
        expect(response.headers["X-Inserted-Id"]).to be_present
      end

      it "creates endorsement with correct tipo" do
        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:aumento_is)
        expect(endorsement.importancia_segurada).to eq(75_000_000)
        expect(endorsement.data_emissao).to eq(Date.parse("2024-11-01"))
      end

      it "updates policy LMG and importancia_segurada" do
        policy.reload
        expect(policy.lmg).to eq(75_000_000)
        expect(policy.importancia_segurada).to eq(75_000_000)
      end

      it "increments endorsements counter" do
        expect(policy.reload.endorsements_count).to eq(1)
      end
    end

    context "when creating reducao_is endorsement" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 30_000_000
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "creates endorsement with correct tipo" do
        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:reducao_is)
        expect(endorsement.importancia_segurada).to eq(30_000_000)
      end

      it "updates policy LMG" do
        policy.reload
        expect(policy.lmg).to eq(30_000_000)
        expect(policy.importancia_segurada).to eq(30_000_000)
      end
    end

    context "when creating alteracao_vigencia endorsement" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          inicio_vigencia: Date.parse("2024-11-01"),
          fim_vigencia: Date.parse("2025-11-01")
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "creates endorsement with correct tipo" do
        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:alteracao_vigencia)
        expect(endorsement.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(endorsement.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end

      it "updates policy vigencia dates" do
        policy.reload
        expect(policy.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(policy.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end

      it "keeps original importancia_segurada and LMG" do
        policy.reload
        expect(policy.importancia_segurada).to eq(50_000_000)
        expect(policy.lmg).to eq(50_000_000)
      end
    end

    context "when creating aumento_is_alteracao_vigencia endorsement" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 75_000_000,
          inicio_vigencia: Date.parse("2024-11-01"),
          fim_vigencia: Date.parse("2025-11-01")
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "creates endorsement with correct tipo" do
        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:aumento_is_alteracao_vigencia)
        expect(endorsement.importancia_segurada).to eq(75_000_000)
        expect(endorsement.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(endorsement.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end

      it "updates both policy LMG and vigencia" do
        policy.reload
        expect(policy.lmg).to eq(75_000_000)
        expect(policy.importancia_segurada).to eq(75_000_000)
        expect(policy.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(policy.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end
    end

    context "when creating reducao_is_alteracao_vigencia endorsement" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 25_000_000,
          inicio_vigencia: Date.parse("2024-11-01"),
          fim_vigencia: Date.parse("2025-11-01")
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "creates endorsement with correct tipo" do
        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:reducao_is_alteracao_vigencia)
        expect(endorsement.importancia_segurada).to eq(25_000_000)
        expect(endorsement.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(endorsement.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end

      it "updates both policy LMG and vigencia" do
        policy.reload
        expect(policy.lmg).to eq(25_000_000)
        expect(policy.importancia_segurada).to eq(25_000_000)
        expect(policy.inicio_vigencia).to eq(Date.parse("2024-11-01"))
        expect(policy.fim_vigencia).to eq(Date.parse("2025-11-01"))
      end
    end

    context "when creating cancelamento endorsement" do
      let!(:existing_endorsement) do
        create(:endorsement,
               policy: policy,
               data_emissao: Date.parse("2024-11-01"),
               tipo: Endorsement::Tipo::AUMENTO_IS,
               importancia_segurada: 75_000_000,
               inicio_vigencia: Date.parse("2024-11-01"),
               fim_vigencia: Date.parse("2025-11-01"))
      end

      before do
        policy.update!(
          importancia_segurada: 75_000_000,
          lmg: 75_000_000,
          inicio_vigencia: Date.parse("2024-11-01"),
          fim_vigencia: Date.parse("2025-11-01")
        )
      end

      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-15")
        }
      end

      it "creates cancelamento endorsement" do
        post "/policies/#{policy.numero}/endorsements", params: valid_params

        expect(response).to have_http_status(:created)

        cancellation = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(cancellation.tipo).to be(:cancelamento)
        expect(cancellation.cancelled_endorsement).to eq(existing_endorsement)
        expect(cancellation.data_emissao).to eq(Date.parse("2024-11-15"))
      end

      it "marks policy as BAIXADA when no valid endorsements remain" do
        post "/policies/#{policy.numero}/endorsements", params: valid_params

        policy.reload
        expect(policy.status).to be(:baixada)
      end

      it "increments endorsements counter" do
        expect {
          post "/policies/#{policy.numero}/endorsements", params: valid_params
        }.to change { policy.reload.endorsements_count }.by(1)
      end

      context "when policy has multiple endorsements" do
        let!(:second_endorsement) do
          create(:endorsement,
                 policy: policy,
                 data_emissao: Date.parse("2024-11-05"),
                 tipo: Endorsement::Tipo::REDUCAO_IS,
                 importancia_segurada: 60_000_000,
                 inicio_vigencia: Date.parse("2024-11-01"),
                 fim_vigencia: Date.parse("2025-11-01"))
        end

        before do
          policy.update!(
            importancia_segurada: 60_000_000,
            lmg: 60_000_000
          )
        end

        it "reverts to previous valid endorsement after cancellation" do
          post "/policies/#{policy.numero}/endorsements", params: valid_params

          cancellation = Endorsement.find(response.headers["X-Inserted-Id"])
          expect(cancellation.cancelled_endorsement).to eq(second_endorsement)

          policy.reload
          expect(policy.importancia_segurada).to eq(75_000_000)
          expect(policy.lmg).to eq(75_000_000)
          expect(policy.status).to be(:ativa)
        end
      end
    end

    context "when trying to cancel with no valid endorsements" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-15")
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "returns 422 status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["message"]).to eq("No valid endorsement to cancel")
      end
    end

    context "when trying to make LMG negative" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: -1000
        }
      end

      before do
        post "/policies/#{policy.numero}/endorsements", params: valid_params
      end

      it "returns 422 status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["message"]).to eq("invalid request")
      end
    end

    context "when policy does not exist" do
      let(:valid_params) do
        {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 75_000_000
        }
      end

      before do
        post "/policies/nonexistent/endorsements", params: valid_params
      end

      it "returns 404 status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found error message" do
        expected_response = {
          "message" => "Policy with numero 'nonexistent' not found"
        }

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "when validations fail" do
      it "validates fim_vigencia after inicio_vigencia" do
        invalid_params = {
          data_emissao: Date.parse("2024-11-01"),
          inicio_vigencia: Date.parse("2024-12-01"),
          fim_vigencia: Date.parse("2024-11-01")
        }

        post "/policies/#{policy.numero}/endorsements", params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["message"]).to eq("invalid request")
      end

      it "validates positive importancia_segurada" do
        invalid_params = {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: -1000
        }

        post "/policies/#{policy.numero}/endorsements", params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["message"]).to eq("invalid request")
      end

      it "validates required data_emissao" do
        invalid_params = {
          importancia_segurada: 75_000_000
        }

        post "/policies/#{policy.numero}/endorsements", params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["message"]).to include("invalid request")
      end
    end

    context "when endorsement type determination works correctly" do
      it "detects aumento_is when only IS increases" do
        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.current,
          importancia_segurada: 75_000_000
        }

        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:aumento_is)
      end

      it "detects reducao_is when only IS decreases" do
        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.current,
          importancia_segurada: 25_000_000
        }

        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:reducao_is)
      end

      it "detects alteracao_vigencia when only vigencia changes" do
        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.current,
          inicio_vigencia: Date.current + 5.days
        }

        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:alteracao_vigencia)
      end

      it "detects cancelamento when no changes provided" do
        existing = create(:endorsement, policy: policy, data_emissao: Date.current, tipo: Endorsement::Tipo::AUMENTO_IS, importancia_segurada: 60_000_000)
        policy.update!(importancia_segurada: 60_000_000, lmg: 60_000_000)

        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.current + 1.day
        }

        endorsement = Endorsement.find(response.headers["X-Inserted-Id"])
        expect(endorsement.tipo).to be(:cancelamento)
        expect(endorsement.cancelled_endorsement).to eq(existing)
      end
    end

    context "when testing counter cache functionality" do
      it "increments counter when creating multiple endorsements" do
        expect(policy.reload.endorsements_count).to eq(0)

        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.parse("2024-11-01"),
          importancia_segurada: 75_000_000
        }

        expect(policy.reload.endorsements_count).to eq(1)

        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.parse("2024-11-05"),
          inicio_vigencia: Date.parse("2024-12-01")
        }

        expect(policy.reload.endorsements_count).to eq(2)

        post "/policies/#{policy.numero}/endorsements", params: {
          data_emissao: Date.parse("2024-11-10")
        }

        expect(policy.reload.endorsements_count).to eq(3)
      end
    end
  end
end
