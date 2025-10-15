# frozen_string_literal: true

class PoliciesController < ApplicationController
  def index
    contract = Policy::FindManyContract.from(params)
    serializer, total_count = Policy::FindManyService.new(contract).call

    response.set_header("X-Total-Count", total_count)
    render json: serializer.serializable_hash.to_json, status: :ok
  end

  def show
    contract = Policy::FindOneContract.from(params)
    serializer = Policy::FindOneService.new(contract).call

    render json: serializer.serializable_hash.to_json, status: :ok
  end

  def create
    contract = Policy::CreateContract.from(params)
    inserted_number = Policy::CreateService.new(contract).call

    response.set_header("X-Inserted-Number", inserted_number)
    render status: :created
  end
end
