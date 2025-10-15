# frozen_string_literal: true

class ApplicationContract
  module BaseSchema
    Paginator = Dry::Schema.Params do
      optional(:page).filled(:integer, gteq?: 1)
      optional(:size).filled(:integer, lteq?: 100, gteq?: 1)
    end

    Sorter = Dry::Schema.Params do
      optional(:sort_by).filled(:symbol)
      optional(:sort_order).filled(:symbol, included_in?: [:asc, :desc])
    end
  end

  private_class_method :new
  attr_reader :errors

  class << self
    def from(attributes, raise_errors: true)
      raise Errors::BadRequestError.new("body must be a valid JSON") if attributes.nil?

      case attributes
      when ActionController::Parameters
        new(attributes.permit!.to_h.deep_symbolize_keys, raise_errors: raise_errors)
      when Hash
        new(attributes.deep_symbolize_keys, raise_errors: raise_errors)
      else
        raise Errors::BadRequestError.new("body must be a valid JSON") if body.nil?
      end
    end

    def attributes(&)
      @struct_class = Class.new(Dry::Struct, &)
    end

    def validations(&)
      @contract_class = Class.new(Dry::Validation::Contract, &)
    end

    def validations_instance
      @contract_class
    end

    def attributes_instance
      @struct_class
    end
  end

  def initialize(attributes, raise_errors: true)
    contract = self.class.validations_instance
    if contract
      result = contract.new.call(attributes)
      unless result.success?
        # rubocop:disable Rails/DeprecatedActiveModelErrorsMethods
        raise Errors::UnprocessableEntityError.new("invalid request", result.errors.to_h) if raise_errors
        @errors = result.errors.to_h
        # rubocop:enable Rails/DeprecatedActiveModelErrorsMethods
        @data = nil

        return
      end

      attributes = result.to_h
    end

    @errors = {}
    @data = self.class.attributes_instance.new(attributes)
  end

  def valid?
    @errors.empty?
  end

  def method_missing(method, *, &)
    raise ArgumentError.new("invalid contract method #{method}") unless @data.respond_to?(method)
    @data.public_send(method, *, &)
  end

  def respond_to_missing?(method, include_private=false)
    @data.respond_to?(method) || super
  end
end
