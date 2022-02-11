class AddColToStatement < ActiveRecord::Migration[5.1]
  def change
    add_column :statements, :similar_to_prior, :boolean, :default => false
  end
end
