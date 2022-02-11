class MakeChanges < ActiveRecord::Migration[5.1]
  def change
    remove_column :terms, :term
    remove_column :terms, :voting
  end
end
