class CleanupTables < ActiveRecord::Migration
  def change
    remove_column :alerts, :notify_control_id
    change_table :notify_controls do |t|
      t.remove :name
      t.remove :model
      t.remove :serial
      t.remove :code
      t.remove :client_id
    end
  end
end
