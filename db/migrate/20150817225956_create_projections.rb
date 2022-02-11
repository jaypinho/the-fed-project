class CreateProjections < ActiveRecord::Migration[5.1]
  def change
    create_table :projections do |t|
      t.date :present_date
      t.decimal :projected_rate
      t.date :fulfillment_date

      t.timestamps null: false
    end
  end
end
