class AddDeviceAssociations < ActiveRecord::Migration
  def up
    add_column    :alerts, :device_id, :integer
    add_column    :notify_controls, :device_id, :integer
    add_column    :devices, :client_id, :integer
  end

  def down
    remove_column :alerts, :device_id
    remove_column :notify_controls, :device_id
    remove_column :devices, :client_id
  end
end
