class RenameDeviceColumns < ActiveRecord::Migration
  change_table :notify_controls do |t|
    t.rename :device_name,   :name
    t.rename :device_model,  :model
    t.rename :device_serial, :serial
    t.rename :device_code,   :code
  end
end
