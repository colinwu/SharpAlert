class CreateNotifyControls < ActiveRecord::Migration
  def self.up
    create_table :notify_controls do |t|
      t.string :device_serial
      t.string :who
      t.integer :jam
      t.integer :toner_low
      t.integer :toner_empty
      t.integer :paper
      t.integer :service
      t.integer :pm
      t.integer :waste_almost_full
      t.integer :waste_full
      t.integer :job_log_full
      t.timestamps
    end

    n = NotifyControl.new
    n.device_serial = 'default'
    n.who = 'wuc@sharpsec.com'
    n.jam = 24
    n.service = 24
    n.pm = 24
    n.save

  end

  def self.down
    drop_table :notify_controls
  end
end
