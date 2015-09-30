class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :member_type
      t.date :dob
      t.text :bio

      t.timestamps null: false
    end
  end
end
