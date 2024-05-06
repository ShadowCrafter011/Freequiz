class CreateTranslations < ActiveRecord::Migration[7.1]
  def change
    create_table :translations do |t|
      t.string :word
      t.string :translation
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
