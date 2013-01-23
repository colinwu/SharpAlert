class NotifyControlAddLastSentFields < ActiveRecord::Migration
  def up
    add_column :notify_controls, :jam_sent, :datetime
    add_column :notify_controls, :toner_low_sent, :datetime
    add_column :notify_controls, :toner_empty_sent, :datetime
    add_column :notify_controls, :paper_sent, :datetime
    add_column :notify_controls, :service_sent, :datetime
    add_column :notify_controls, :pm_sent, :datetime
    add_column :notify_controls, :waste_almost_full_sent, :datetime
    add_column :notify_controls, :waste_full_sent, :datetime
    add_column :notify_controls, :job_log_full_sent, :datetime
  end

  def down
    remove_column :notify_controls, :jam_sent
    remove_column :notify_controls, :toner_low_sent
    remove_column :notify_controls, :toner_empty_sent
    remove_column :notify_controls, :paper_sent
    remove_column :notify_controls, :service_sent
    remove_column :notify_controls, :pm_sent
    remove_column :notify_controls, :waste_almost_full_sent
    remove_column :notify_controls, :waste_full_sent
    remove_column :notify_controls, :job_log_full_sent
  end
end
