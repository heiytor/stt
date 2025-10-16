# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    numero { "#{Faker::Number.number(digits: 4)}#{Time.current.to_i}" }
    data_emissao { Faker::Date.between(from: 30.days.ago, to: Date.current) }
    inicio_vigencia { data_emissao + rand(0..30).days }
    fim_vigencia { inicio_vigencia + rand(365..730).days }
    importancia_segurada { Faker::Number.between(from: 10_000, to: 1_000_000) }
    lmg { importancia_segurada }
    status { Policy::Status::ATIVA }
  end
end