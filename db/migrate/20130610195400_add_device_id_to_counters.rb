class AddDeviceIdToCounters < ActiveRecord::Migration
  def change
    add_column :counters, :device_id, :integer
  end
end
