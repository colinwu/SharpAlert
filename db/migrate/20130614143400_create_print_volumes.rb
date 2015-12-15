class CreatePrintVolumes < ActiveRecord::Migration
  def self.up
    create_table :print_volumes do |t|
      t.string :model
      t.integer :ave_bw
      t.integer :max_bw
      t.integer :ave_c
      t.integer :max_c
      t.timestamps
    end
  end

  def self.down
    drop_table :print_volumes
  end
end
