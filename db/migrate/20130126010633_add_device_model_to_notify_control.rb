class AddDeviceModelToNotifyControl < ActiveRecord::Migration
  def change
    add_column :notify_controls, :device_model, :string
  end
end
