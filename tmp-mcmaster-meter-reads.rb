if File.exists?('Mcmaster.csv')
  r = CsvMapper.import('Mcmaster.csv') do
    start_at_row 1
    [serial,bldg,room,floor,inst,code,url,totalprintbw,totalprintc,model]
  end
  r.each do |row|
    puts "#{row.model}, #{row.serial}"
    dev = Device.where(["model = ? and serial = ?",row.model,row.serial]).first
    if dev.nil?
      row.url =~ /(\d+\.\d+\.\d+\.\d+)/
      ip = $1
      name = `host #{ip}`.split(' ')[-1].split('.')[-4]
      client = Client.find_by_name('McMaster University')
      dev = Device.create(:name => name, :model => row.model, :serial => row.serial, :code => row.code, :client_id => client.id)
      ndef = NotifyControl.joins(:device).where("devices.serial = 'default'").first
      nc = dev.create_notify_control(
        :tech => 'bwares@sharpdirect.ca',
        :local_admin => 'bwares@sharpdirect.ca',
        :jam => ndef.jam,
        :paper => ndef.paper,
        :toner_low => ndef.toner_low,
        :toner_empty => ndef.toner_empty,
        :waste_almost_full => ndef.waste_almost_full,
        :waste_full => ndef.waste_full,
        :service => ndef.service,
        :pm => ndef.pm,
        :job_log_full => ndef.job_log_full)
    end

    counter = dev.counters.create(:status_date => '2013-04-23 01:00:00', :totalprintbw => row.totalprintbw, :totalprintc => row.totalprintc)
  end
end
