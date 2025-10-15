class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies, id: false do |t|
      t.binary :id, limit: 16, primary_key: true
      t.string :numero, null: false
      t.date :data_emissao, null: false
      t.date :inicio_vigencia, null: false
      t.date :fim_vigencia, null: false
      t.bigint :importancia_segurada, null: false
      t.bigint :lmg, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
