class AddDeviceNameToNotifyControl < ActiveRecord::Migration
  def change
    add_column :notify_controls, :device_name, :string
  end
end
