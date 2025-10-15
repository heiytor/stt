# frozen_string_literal: true

module AttributeEnumable
  extend ActiveSupport::Concern

  class_methods do
    def attribute_as_enum(key, values:, validate: true, scope: true, default: nil)
      raise ArgumentError.new("values be a non-empty array") if !values.instance_of?(Array) || values.empty?

      module_name = key.to_s.capitalize
      module_enum = const_set(module_name, Module.new)

      values.each do |value|
        module_enum.const_set(value.upcase, value.to_sym)
      end

      module_enum.define_singleton_method(:all) do
        values.map(&:to_sym)
      end

      module_enum.define_singleton_method(:default) do
        raise Errors::UnexpectedError.new("Enum #{module_name.capitalize} does not have a default value") if default.nil?

        default.downcase.to_sym
      end

      module_enum.define_singleton_method(:from) do |value|
        raise Errors::UnexpectedError.new("Enum #{module_name} does not have a default value") if default.nil?

        return module_enum.default if value.nil?

        raise Errors::UnexpectedError.new("Invalid enum value: #{value}") unless value.instance_of?(String) || value.instance_of?(Symbol)

        normalized = value.to_s.downcase.to_sym
        module_enum.all.include?(normalized) ? normalized : module_enum.default
      end

      define_method(key) do
        self[key]&.to_sym
      end

      define_method(:"#{key}?") do |value_name|
        send(key) == self.class.const_get("#{module_name}::#{value_name.upcase}")
      end

      values.each do |value|
        define_method(:"#{value}?") do
          send(key) == self.class.const_get("#{module_name}::#{value.upcase}")
        end

        self.scope :"with_#{key}_#{value}", -> { where(key => value) } if scope
      end

      if validate
        validates key, presence: true, inclusion: { in: module_enum.all }
      end
    end
  end
end
