class AddColumnPassword < ActiveRecord::Migration
  def change
    add_column :users, :password, :string
  end
end
