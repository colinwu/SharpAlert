class AddTonerAdminToNotifyControl < ActiveRecord::Migration
  def change
    add_column :notify_controls, :toner_admin, :string
  end
end
