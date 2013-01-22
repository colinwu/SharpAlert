class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.datetime :alert_date
      t.string :device_name
      t.string :device_model
      t.string :device_serial
      t.string :device_code
      t.string :alert_msg
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
