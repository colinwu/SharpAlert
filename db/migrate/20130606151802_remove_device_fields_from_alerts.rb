class RemoveDeviceFieldsFromAlerts < ActiveRecord::Migration
  def up
    remove_column :alerts, :device_model
    remove_column :alerts, :device_serial
    remove_column :alerts, :device_name
    remove_column :alerts, :device_code
  end

  def down
    add_column :alerts, :device_model, :string
    add_column :alerts, :device_serial, :string
    add_column :alerts, :device_name, :string
    add_column :alerts, :device_code, :string
  end
end
