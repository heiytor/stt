# frozen_string_literal: true

class EndorsementsController < ApplicationController
  def index
    contract = Endorsement::FindManyContract.from(params)
    serializer, total_count = Endorsement::FindManyService.new(contract).call

    response.set_header("X-Total-Count", total_count)
    render json: serializer.serializable_hash.to_json, status: :ok
  end

  def show
    contract = Endorsement::FindOneContract.from(params)
    serializer = Endorsement::FindOneService.new(contract).call

    render json: serializer.serializable_hash.to_json, status: :ok
  end

  def create
    contract = Endorsement::CreateContract.from(params)
    inserted_id = Endorsement::CreateService.new(contract).call

    response.set_header("X-Inserted-Id", inserted_id)
    render status: :created
  end
end
