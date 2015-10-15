class AddColToStatement < ActiveRecord::Migration
  def change
    add_column :statements, :similar_to_prior, :boolean, :default => false
  end
end
