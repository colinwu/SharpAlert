class CreateMaintCodes < ActiveRecord::Migration
  def self.up
    create_table :maint_codes do |t|
      t.string :code
      t.integer :alert_id
    end
  end

  def self.down
    drop_table :maint_codes
  end
end
