# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Policies API", type: :request do
  describe "GET /policies" do
    context "when listing policies without filters" do
      let!(:policy1) { create(:policy, numero: "001", status: Policy::Status::ATIVA) }
      let!(:policy2) { create(:policy, numero: "002", status: Policy::Status::BAIXADA) }

      before do
        get "/policies"
      end

      it "returns 200 status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns X-Total-Count header" do
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "returns policies in JSONAPI format" do
        response_data = JSON.parse(response.body)

        expect(response_data).to have_key("data")
        expect(response_data["data"]).to be_an(Array)
        expect(response_data["data"].size).to eq(2)
        expect(response_data["data"].first).to have_key("id")
        expect(response_data["data"].first).to have_key("type")
        expect(response_data["data"].first).to have_key("attributes")
      end
    end

    context "when filtering by status" do
      let!(:policy_ativa) { create(:policy, numero: "001", status: Policy::Status::ATIVA) }
      let!(:policy_baixada) { create(:policy, numero: "002", status: Policy::Status::BAIXADA) }

      it "filters policies by status ativa" do
        get "/policies", params: { status: "ativa" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["numero"]).to eq("001")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end

      it "filters policies by status baixada" do
        get "/policies", params: { status: "baixada" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["numero"]).to eq("002")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end
    end

    context "when filtering by inicio_vigencia dates" do
      let!(:policy_early) { create(:policy, numero: "001", inicio_vigencia: Date.parse("2024-01-01")) }
      let!(:policy_middle) { create(:policy, numero: "002", inicio_vigencia: Date.parse("2024-06-01")) }
      let!(:policy_late) { create(:policy, numero: "003", inicio_vigencia: Date.parse("2024-12-01")) }

      it "filters by inicio_vigencia_gte" do
        get "/policies", params: { inicio_vigencia_gte: "2024-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by inicio_vigencia_lte" do
        get "/policies", params: { inicio_vigencia_lte: "2024-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by inicio_vigencia range" do
        get "/policies", params: { inicio_vigencia_gte: "2024-02-01", inicio_vigencia_lte: "2024-11-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["numero"]).to eq("002")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end
    end

    context "when filtering by fim_vigencia dates" do
      let!(:policy_early) { create(:policy, numero: "001", fim_vigencia: Date.parse("2025-01-01")) }
      let!(:policy_middle) { create(:policy, numero: "002", fim_vigencia: Date.parse("2025-06-01")) }
      let!(:policy_late) { create(:policy, numero: "003", fim_vigencia: Date.parse("2025-12-01")) }

      it "filters by fim_vigencia_gte" do
        get "/policies", params: { fim_vigencia_gte: "2025-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by fim_vigencia_lte" do
        get "/policies", params: { fim_vigencia_lte: "2025-06-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(2)
        expect(response.headers["X-Total-Count"]).to eq(2)
      end

      it "filters by fim_vigencia range" do
        get "/policies", params: { fim_vigencia_gte: "2025-02-01", fim_vigencia_lte: "2025-11-01" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response_data["data"].first["attributes"]["numero"]).to eq("002")
        expect(response.headers["X-Total-Count"]).to eq(1)
      end
    end

    context "when testing pagination" do
      before do
        15.times { |i| create(:policy, numero: "policy_#{i.to_s.rjust(3, '0')}") }
      end

      it "respects default pagination (page 1, size 10)" do
        get "/policies"

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(10)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "respects custom page size" do
        get "/policies", params: { size: 5 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(5)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "respects page number" do
        get "/policies", params: { page: 2, size: 5 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(5)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end

      it "handles last page with remaining items" do
        get "/policies", params: { page: 3, size: 7 }

        response_data = JSON.parse(response.body)
        expect(response_data["data"].size).to eq(1)
        expect(response.headers["X-Total-Count"]).to eq(15)
      end
    end

    context "when testing sorting" do
      let!(:policy1) { create(:policy, numero: "001", created_at: 1.day.ago) }
      let!(:policy2) { create(:policy, numero: "002", created_at: 2.days.ago) }
      let!(:policy3) { create(:policy, numero: "003", created_at: 3.days.ago) }

      it "sorts by created_at desc by default" do
        get "/policies"

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["numero"]).to eq("001")
        expect(response_data["data"][1]["attributes"]["numero"]).to eq("002")
        expect(response_data["data"][2]["attributes"]["numero"]).to eq("003")
      end

      it "sorts by created_at asc when specified" do
        get "/policies", params: { sort_order: "asc" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["numero"]).to eq("003")
        expect(response_data["data"][1]["attributes"]["numero"]).to eq("002")
        expect(response_data["data"][2]["attributes"]["numero"]).to eq("001")
      end

      it "sorts by numero when specified" do
        get "/policies", params: { sort_by: "numero", sort_order: "asc" }

        response_data = JSON.parse(response.body)
        expect(response_data["data"][0]["attributes"]["numero"]).to eq("001")
        expect(response_data["data"][1]["attributes"]["numero"]).to eq("002")
        expect(response_data["data"][2]["attributes"]["numero"]).to eq("003")
      end
    end
  end

  describe "GET /policies/:numero" do
    context "when policy does not exist" do
      before do
        get "/policies/nonexistent"
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

    context "when policy exists" do
      let!(:policy) do
        create(:policy,
               numero: "01681760574732",
               data_emissao: Date.parse("2024-10-15"),
               inicio_vigencia: Date.parse("2024-10-25"),
               fim_vigencia: Date.parse("2025-10-25"),
               importancia_segurada: 50_000_000,
               lmg: 50_000_000)
      end

      before do
        get "/policies/#{policy.numero}"
      end

      it "returns 200 status" do
        expect(response).to have_http_status(:ok)
      end

      it "returns policy data with correct structure and attributes" do
        expected_response = {
          "data" => {
            "id" => policy.id,
            "type" => "policy",
            "attributes" => {
              "numero" => "01681760574732",
              "data_emissao" => "2024-10-15",
              "inicio_vigencia" => "2024-10-25",
              "fim_vigencia" => "2025-10-25",
              "importancia_segurada" => 50_000_000,
              "lmg" => 50_000_000,
              "status" => "ativa",
              "endorsements_count" => 0,
              "created_at" => policy.created_at.iso8601(3),
              "updated_at" => policy.updated_at.iso8601(3)
            },
            "relationships" => {
              "endorsements" => {
                "data" => []
              }
            }
          }
        }

        expect(JSON.parse(response.body)).to eq(expected_response)
      end
    end

    context "when policy has endorsements" do
      let!(:policy_with_endorsements) do
        create(:policy,
               numero: "01681760574733",
               data_emissao: Date.parse("2024-10-15"),
               inicio_vigencia: Date.parse("2024-10-25"),
               fim_vigencia: Date.parse("2025-10-25"),
               importancia_segurada: 50_000_000,
               lmg: 50_000_000)
      end

      let!(:endorsement1) { create(:endorsement, policy: policy_with_endorsements, data_emissao: Date.parse("2024-11-01"), tipo: Endorsement::Tipo::AUMENTO_IS) }
      let!(:endorsement2) { create(:endorsement, policy: policy_with_endorsements, data_emissao: Date.parse("2024-11-15"), tipo: Endorsement::Tipo::REDUCAO_IS) }

      before do
        get "/policies/#{policy_with_endorsements.numero}"
      end

      it "returns policy with endorsements_count and relationships" do
        response_data = JSON.parse(response.body)

        expect(response_data["data"]["attributes"]["endorsements_count"]).to eq(2)
        expect(response_data["data"]["relationships"]["endorsements"]).to be_present
        expect(response_data["data"]["relationships"]["endorsements"]["data"]).to be_an(Array)
        expect(response_data["data"]["relationships"]["endorsements"]["data"].size).to eq(2)
      end
    end
  end

  describe "POST /policies" do
    before(:each) do
      allow(Rails.logger).to receive(:warn).and_call_original
      allow(Rails.logger).to receive(:info).and_call_original
    end

    context "when creating a policy with maximum conflicts" do
      let(:valid_params) do
        {
          data_emissao: Date.current,
          inicio_vigencia: Date.current + 10.days,
          fim_vigencia: Date.current + 1.year,
          importancia_segurada: 100_000
        }
      end

      before do
        allow_any_instance_of(Policy::CreateService).to receive(:rand).and_return(999)

        mock_time = Time.new(2024, 1, 1, 12, 0, 0)
        allow(Time).to receive(:current).and_return(mock_time)
        allow(mock_time).to receive(:to_i).and_return(1704110400)

        allow(Policy).to receive(:find_conflicts).and_return([double("conflict")])
      end

      it "returns 500 status after maximum attempts" do
        post "/policies", params: valid_params

        expect(response).to have_http_status(:internal_server_error)
      end

      it "returns error message" do
        post "/policies", params: valid_params

        expect(JSON.parse(response.body)["message"]).to eq("Falha ao gerar número único")
      end
    end

    context "when creating a policy with valid parameters" do
      let(:valid_params) do
        {
          data_emissao: Date.current,
          inicio_vigencia: Date.current + 10.days,
          fim_vigencia: Date.current + 1.year,
          importancia_segurada: 100_000
        }
      end

      before do
        post "/policies", params: valid_params
      end

      it "returns 201 status" do
        expect(response).to have_http_status(:created)
      end

      it "returns X-Inserted-Number header" do
        expect(response.headers["X-Inserted-Number"]).to be_present
      end

      it "creates a new policy in database" do
        expect { post "/policies", params: valid_params }.to change(Policy, :count).by(1)
      end

      it "creates policy with correct attributes" do
        created_policy = Policy.find_by(numero: response.headers["X-Inserted-Number"])

        expect(created_policy).to be_present
        expect(created_policy.data_emissao).to eq(valid_params[:data_emissao])
        expect(created_policy.inicio_vigencia).to eq(valid_params[:inicio_vigencia])
        expect(created_policy.fim_vigencia).to eq(valid_params[:fim_vigencia])
        expect(created_policy.importancia_segurada).to eq(valid_params[:importancia_segurada])
        expect(created_policy.lmg).to eq(valid_params[:importancia_segurada])
        expect(created_policy.status).to be(:ativa)
      end

      context "when creating a policy with number conflict resolution" do
        let(:valid_params) do
          {
            data_emissao: Date.current,
            inicio_vigencia: Date.current + 10.days,
            fim_vigencia: Date.current + 1.year,
            importancia_segurada: 100_000
          }
        end

        before do
          create(:policy, numero: "09991704110400")

          allow_any_instance_of(Policy::CreateService).to receive(:rand).and_return(999, 888)

          mock_time = Time.new(2024, 1, 1, 12, 0, 0)
          allow(Time).to receive(:current).and_return(mock_time)
          allow(mock_time).to receive(:to_i).and_return(1704110400)
        end

        it "retries on conflict and succeeds" do
          expect { post "/policies", params: valid_params }.to change(Policy, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(response.headers["X-Inserted-Number"]).to eq("08881704110400")
        end

        it "logs conflict and success messages" do
          post "/policies", params: valid_params

          expect(Rails.logger).to have_received(:warn).with("Policy number 09991704110400 conflict detected for candidate").exactly(:once)
          expect(Rails.logger).to have_received(:info).with("Policy number 08881704110400 generated successfully").exactly(:once)
        end
      end
    end
  end
end
