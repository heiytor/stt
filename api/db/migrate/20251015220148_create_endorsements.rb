class CreateEndorsements < ActiveRecord::Migration[8.0]
  def change
    create_table :endorsements, id: false do |t|
      t.binary :id, limit: 16, primary_key: true
      t.references :policy, null: false, foreign_key: true, type: :binary, limit: 16
      t.date :data_emissao, null: false
      t.string :tipo, null: false
      t.bigint :importancia_segurada
      t.date :inicio_vigencia
      t.date :fim_vigencia
      t.references :cancelled_endorsement, null: true, foreign_key: { to_table: :endorsements }, type: :binary, limit: 16
      t.references :cancelled_by_endorsement, null: true, foreign_key: { to_table: :endorsements }, type: :binary, limit: 16

      t.timestamps
    end
  end
end
