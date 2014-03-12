class CreateTonerCodes < ActiveRecord::Migration
  def self.up
    create_table :toner_codes do |t|
      t.string :colour
      t.integer :alert_id
    end
  end

  def self.down
    drop_table :toner_codes
  end
end
