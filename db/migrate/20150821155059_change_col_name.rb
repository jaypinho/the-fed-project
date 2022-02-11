class ChangeColName < ActiveRecord::Migration[5.1]
  def change
    rename_column :key_rates, :present_date, :rate_date
  end
end
