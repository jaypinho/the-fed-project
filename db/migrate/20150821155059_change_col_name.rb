class ChangeColName < ActiveRecord::Migration
  def change
    rename_column :key_rates, :present_date, :rate_date
  end
end
