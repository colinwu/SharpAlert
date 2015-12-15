class CreateSheetCounts < ActiveRecord::Migration
  def self.up
    create_table :sheet_counts do |t|
      t.integer :bw
      t.integer :color
      t.integer :alert_id
      t.timestamps
    end
  end

  def self.down
    drop_table :sheet_counts
  end
end
