class ReportController < ApplicationController
  def index
    # Show list of available special reports - maybe with fields for any optional
    # settings for each report
    @days = 7
  end
  
  # Retrieve count of specified alerts (for each day) for specified devices. 
  # Devices can be specified by name, model, sn, code, or client.
  def frequency
    @days = 7 # default: look at last 7 days
    unless (params[:commit].nil?)
      where_array = Array.new
      condition_array = ['place holder']
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days]
      end
      condition_array << @days
      where_array << "alert_date > date_sub(curdate(), interval ? day) and alert_date < curdate()"
      comment_array = ["For last #{@days} days"]
      if (not params['name_q'].nil? and not params['name_q'].empty?)
        @name_q = params[:name_q]
        condition_array << @name_q.condition
        where_array << @name_q.where('devices.name')
        comment_array << "Name = #{@name_q}"
      end
      if(not params['model_q'].nil? and not params['model_q'].empty?)
        @model_q = params[:model_q]
        condition_array << @model_q.condition
        where_array << @model_q.where('devices.model')
        comment_array << "Model = #{@model_q}"
      end
      if(not params['serial_q'].nil? and not params['serial_q'].empty?)
        @serial_q = params[:serial_q]
        condition_array << @serial_q.condition
        where_array << @serial_q.where('devices.serial')
        comment_array << "Serial # = #{@serial_q}"
      end
      if(not params['code_q'].nil? and not params['code_q'].empty?)
        @code_q = params[:code_q]
        where_array << @code_q.where('devices.code')
        condition_array << @code_q.condition
        comment_array << "Machine Code = #{@code_q}"
      end
      if (not params[:client].nil? and not params[:client][:name].empty?)
        @client = Client.new
        @client['name'] = params[:client][:name]
        where_array << @client.name.where('clients.name')
        condition_array << @client.name.condition
        comment_array << "Client Name contains #{@client.name}"
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        @msg_q = params[:msg_q]
        where_array << @msg_q.where('alert_msg')
        condition_array << @msg_q.condition
        comment_array << "Message contains #{@msg_q}"
      end
      unless where_array.empty?
        condition_array[0] = where_array.join(' and ')
        @comment = comment_array.join(' and ')
      else
        condition_array = []
      end
    end
    @alert_counts = Alert.where(condition_array).joins(:device => :client).group('device_id','date(alert_date)').order('devices.name').count
    @devices = @alert_counts.keys.map { |key| key[0] }.uniq
    @dates = (Date.today-@days.to_i..Date.today-1).map {|d| d }
  end

  # Jam Code frequency per device
  def jam_code_stats
    unless (params['days'].nil?)
      @days = params['days']
      @code_list = JamStat.select('jam_code').group('jam_code').joins(:alert).where(["alert_date > date_sub(now(),interval ? day)", @days])
    else
      @code_list = JamStat.select('jam_code').group('jam_code')
    end
    @dev_stats = Hash.new
    @dev_list = Device.order(:name)
    @dev_list.each do |d|
      unless @days.nil?
        g = JamStat.where(["alert_msg = 'Misfeed has occurred.' and device_id = ? and alert_date > date_sub(now(),interval ? day)", d.id, @days]).joins(:alert).group('jam_code').select('jam_stats.jam_code').count
      else
        g = JamStat.where(["alert_msg = 'Misfeed has occurred.' and device_id = ?", d.id]).joins(:alert).group('jam_code').select('jam_stats.jam_code').count
      end
      unless g.empty?
        @dev_stats[d.id] = g
      end
    end
  end
  
  def jam_detail
    if (params.nil? or params[:dev].empty? or params[:dev].empty?)
      # should show an error message
    else
      @dev = Device.find params[:dev]
      @jam = params[:code]
      unless (params[:days].nil? or params[:days].empty?)
        @days = params[:days]
        @alerts = Alert.where(["device_id = ? and jam_code = ? and alert_date > date_sub(now(),interval ? day)",@dev.id,@jam,@days]).joins(:jam_stat).order(:alert_date)
      else
        @alerts = Alert.where(["device_id = ? and jam_code = ?",@dev.id,@jam]).joins(:jam_stat).order(:alert_date)
      end
    end
    @title = "Jam Code #{@jam} Detail for #{@dev.name}"
    render :detail
  end
  
  def toner_detail
    @dev = Device.find params[:dev]
    @alerts = Alert.where("device_id = #{@dev.id} and (alert_msg regexp 'add toner') and sheet_counts.bw is not NULL").joins(:sheet_count).order(:alert_date)
    @title = "Toner Supply Alert Details for #{@dev.name}"
    render :detail
  end
  
    
  # Show list of devices that have usage(s) that exceed their rated volume
  def volume
    where_array = Array.new
    conditions_array = ['place holder']
    @days = 30
    if (not params[:name_q].nil? and not params[:name_q].empty?)
      @name_q = params[:name_q]
      where_array << @name_q.where('devices.name')
      conditions_array << @name_q.condition
    end
    if (not params[:client].nil? and not params[:client][:name].empty?)
      @client = Client.new
      @client.name = params[:client][:name]
      where_array << @client.name.where('clients.name')
      conditions_array << @client.name.condition
    end
    unless (params[:days].nil?)
      @days = params[:days].to_i
    end
    unless( where_array.empty? )
      conditions_array[0] = where_array.join(' and ')
    else
      conditions_array = []
    end
    @all_devices = Counter.group(:device_id).order('devices.name').select(:device_id).where(conditions_array).joins(:device => :client)
    @devices = Array.new
    @first = Hash.new
    @last = Hash.new
    @oldbw = Hash.new
    @newbw = Hash.new
    @oldc = Hash.new
    @newc = Hash.new
    @healthbw = Hash.new
    @healthc = Hash.new
    @bw_ratio = Hash.new
    @c_ratio = Hash.new
    
    @all_devices.each do |d|
      @last[d.device_id] = Counter.latest(d.device_id)
      @newc[d.device_id] = @last[d.device_id].totalprint1c.to_i + @last[d.device_id].totalprint2c.to_i + @last[d.device_id].totalprintc.to_i
      @newbw[d.device_id] = @last[d.device_id].totalprintbw.to_i
      
      first_date = @last[d.device_id].status_date - @days*86400
      @first[d.device_id] = Counter.earliest_or_before(first_date,d.device_id)
      unless @first[d.device_id].nil?
        @oldc[d.device_id] = @first[d.device_id].totalprint1c.to_i + @first[d.device_id].totalprint2c.to_i + @first[d.device_id].totalprintc.to_i
        @oldbw[d.device_id] = @first[d.device_id].totalprintbw
        totalbw = @newbw[d.device_id] - @oldbw[d.device_id]
        totalc  = @newc[d.device_id]  - @oldc[d.device_id]
        # @last and @first may not be exactly 30 days apart so must account for the actual number of days.
        days = (@last[d.device_id].status_date - @first[d.device_id].status_date) / 86400.0
        @bw_ratio[d.device_id] = (totalbw * 30 / days) / d.device.print_volume.ave_bw
        if (@bw_ratio[d.device_id] > 1.5)
          @healthbw[d.device_id] = 'red'
        elsif (@bw_ratio[d.device_id] <= 1.5 and @bw_ratio[d.device_id] > 1)
          @healthbw[d.device_id] = 'yellow'
        end
        unless (d.device.print_volume.ave_c.nil? or d.device.print_volume.ave_c == 0)
          @c_ratio[d.device_id] = (totalc * 30 / days) / d.device.print_volume.ave_c
          if (@c_ratio[d.device_id] > 1.5)
            @healthc[d.device_id] = 'red'
          elsif (@c_ratio[d.device_id] <= 1.5 and @c_ratio[d.device_id] > 1)
            @healthc[d.device_id] = 'yellow'
          end
        end
      else
        @oldc[d.device_id] = 0
        @oldbw[d.device_id] = 0
      end
      if ((not @bw_ratio[d.device_id].nil? and @bw_ratio[d.device_id] > 1) or (not @c_ratio[d.device_id].nil? and @c_ratio[d.device_id] > 1))
        @devices << d
      end
    end
#     render 'counters/index'
  end

  # Produce chart of number of daily "Misfeed", "Maintenance Request" and
  # "Call for Service" alerts for a single device over the past 30-, 60-, or 90-days.
  # Actually the number of days can be arbitrary but I only provide selection
  # options for those three.
  def alerts_graph
    @days = 30
    if (params.nil? or params[:device].nil? or params[:device][:id].empty?)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "No device selected")
      end
    else
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days].to_i
      end
      @device_id = params[:device][:id]
      @device = Device.find @device_id
      misfeed_alerts = Alert.where("device_id=#{@device_id} and alert_msg regexp 'misfeed' and alert_date > date_sub(curdate(), interval #{@days}  day)").group('date(alert_date)').count
      maint_alerts = Alert.where("device_id=#{@device_id} and alert_msg regexp 'maintenance' and alert_date > date_sub(curdate(), interval #{@days} day)").group('date(alert_date)').count
      service_alerts = Alert.where("device_id=#{@device_id} and alert_msg regexp 'service' and alert_date > date_sub(curdate(), interval #{@days} day)").group('date(alert_date)').count
      misfeed_data = Hash.new
      maint_data = Hash.new
      service_data = Hash.new
      (@days.days.ago.to_date..Date.today).map do |date|
        misfeed_data[date] = misfeed_alerts[date].nil? ? 0 : misfeed_alerts[date]
        maint_data[date] = maint_alerts[date].nil? ? 0 : maint_alerts[date]
        service_data[date] = service_alerts[date].nil? ? 0 : service_alerts[date]
      end
      @chart = LazyHighCharts::HighChart.new('chart') do |f|
        f.type('scatter')
        f.title( {:text => "Alerts for #{@device.name}"} )
        f.xAxis( :type => 'datetime' )
        f.series( :type => 'line', :name => 'Misfeed', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => misfeed_data.to_a )
        f.series( :type => 'line', :name => 'Maintenance Request', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => maint_data.to_a )
        f.series( :type => 'line', :name => 'Call for Service', 
                  :pointInterval => 1.day,
                  :pointStart => @days.days.ago.to_date,
                  :data => service_data.to_a )
#         f.series( :name => 'test', :data => test_data )
      end
    end
  end

  # Produce chart of bw and colour (if available) page counts between readings.
  def volume_graph
    @days = 30
    if (params.nil? or params[:device].nil? or params[:device][:id].empty?)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "No device selected")
      end
    else
      if (not params[:days].nil? and not params[:days].empty?)
        @days = params[:days].to_i
      end
      @device_id = params[:device][:id]
      @device = Device.find @device_id
      @last = Counter.latest(@device_id)
    end
  end
end
