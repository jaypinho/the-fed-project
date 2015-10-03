class MakeChanges < ActiveRecord::Migration
  def change
    remove_column :terms, :term
    remove_column :terms, :voting
  end
end
