class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.date :start_date
      t.date :end_date
      t.integer :term
      t.boolean :voting
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
