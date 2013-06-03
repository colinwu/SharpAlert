class AddClientIdToNotifyControl < ActiveRecord::Migration
  def change
    add_column :notify_controls, :client_id, :integer
  end
end
