class AlertsAddNcIdColumn < ActiveRecord::Migration
  def up
    add_column :alerts, :notify_control_id, :integer
  end

  def down
    remove_column :alerts, :notify_control_id
  end
end
