class CreateServiceCodes < ActiveRecord::Migration
  def self.up
    create_table :service_codes do |t|
      t.string :code
      t.integer :alert_id
    end
  end

  def self.down
    drop_table :service_codes
  end
end
