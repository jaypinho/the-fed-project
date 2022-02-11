class CreateKeyRates < ActiveRecord::Migration[5.1]
  def change
    create_table :key_rates do |t|

      t.date :present_date
      t.decimal :actual_rate

      t.timestamps null: false
    end
  end
end
