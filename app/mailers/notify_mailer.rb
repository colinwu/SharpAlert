class NotifyMailer < ActionMailer::Base
  default from: "sharpmon@seclcsglab.sharpamericas.com"

  def notify_email(who, alert)
    @who = who
    @alert = alert
    mail(:to => who, :subject => "#{alert.device_name} - Alert Message - #{alert.alert_msg}")
  end
  
end
