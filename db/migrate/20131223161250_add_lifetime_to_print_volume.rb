class AddLifetimeToPrintVolume < ActiveRecord::Migration
  def change
    add_column :print_volumes, :lifetime, :integer
  end
end
