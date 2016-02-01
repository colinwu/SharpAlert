class AddIpToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :ip, :string
  end
end
