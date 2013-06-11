class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.datetime :status_date
      t.integer :copybw
      t.integer :copy2c
      t.integer :copy1c
      t.integer :copyfc
      t.integer :printbw
      t.integer :printfc
      t.integer :totalprintbw
      t.integer :totalprint2c
      t.integer :totalprint1c
      t.integer :totalprintc
      t.integer :scanbw
      t.integer :scan2c
      t.integer :scan1c
      t.integer :scanfc
      t.integer :fileprintbw
      t.integer :fileprint2c
      t.integer :fileprint1c
      t.integer :fileprintfc
      t.integer :faxin
      t.integer :faxinline1
      t.integer :faxinline2
      t.integer :faxinline3
      t.integer :otherprintbw
      t.integer :otherprintc
      t.integer :faxout
      t.integer :faxoutline1
      t.integer :faxoutline2
      t.integer :faxoutline3
      t.integer :hddscanbw
      t.integer :hddscan2c
      t.integer :hddscan1c
      t.integer :hddscanfc
      t.integer :tonerbkin
      t.integer :tonercin
      t.integer :tonermin
      t.integer :toneryin
      t.integer :tonernnendbk
      t.integer :tonernnendc
      t.integer :tonernnendm
      t.integer :tonernnendy
      t.integer :tonerendbk
      t.integer :tonerendc
      t.integer :tonerendm
      t.integer :tonerendy
      t.integer :tonerleftbk
      t.integer :tonerleftc
      t.integer :tonerleftm
      t.integer :tonerlefty
      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end
