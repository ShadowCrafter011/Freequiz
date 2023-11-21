class CreateScores < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.binary :data
      t.bigint :total
      t.references :quiz, type: :string, null: false, foreign_key: { primary_key: :uuid }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
