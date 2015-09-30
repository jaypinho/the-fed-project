class CreateStatements < ActiveRecord::Migration
  def change
    create_table :statements do |t|
      t.string :url
      t.text :summary
      t.string :lean
      t.date :pub_date
      t.date :statement_date
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
