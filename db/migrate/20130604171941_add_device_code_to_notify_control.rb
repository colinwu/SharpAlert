class AddDeviceCodeToNotifyControl < ActiveRecord::Migration
  def change
    add_column :notify_controls, :device_code, :string
  end
end
