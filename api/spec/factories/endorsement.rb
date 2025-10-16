# frozen_string_literal: true

FactoryBot.define do
  factory :endorsement do
    association :policy
    data_emissao { Faker::Date.between(from: 30.days.ago, to: Date.current) }
    tipo { Endorsement::Tipo.all.sample }
    importancia_segurada { Faker::Number.between(from: 10_000, to: 1_000_000) }
    inicio_vigencia { data_emissao + rand(0..30).days }
    fim_vigencia { inicio_vigencia + rand(365..730).days }
  end
end