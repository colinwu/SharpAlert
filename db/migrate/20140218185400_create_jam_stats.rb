class CreateJamStats < ActiveRecord::Migration
  def self.up
    create_table :jam_stats do |t|
      t.string :jam_code
      t.string :paper_type
      t.string :paper_code
      t.string :jam_type
      t.integer :alert_id
      t.timestamps
    end
  end

  def self.down
    drop_table :jam_stats
  end
end
