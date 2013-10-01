class ReportController < ApplicationController
  def frequency
    # Retrieve count of specified alerts (for each day) for specified devices. 
    # Devices can be specified by name, model, sn, code, or client.
    @days = 7 # default: look at last 7 days
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    if params[:sort].nil?
      @sort = 'alerts.id'
    else
      @sort = "#{params[:sort]},alert_date"
    end
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
      if (not params['client_q'].nil? and not params['client_q'].empty?)
        @client_q = params[:client_q]
        where_array << @client_q.where('clients.name')
        condition_array << @client_q.condition
        comment_array << "Client Name contains #{@client_q}"
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        @msg_q = params[:msg_q]
        where_array << @msg_q.where('alert_msg')
        condition_array << @msg_q.condition
        comment_array << "Message contains #{@msg_q}"
      end
      if(not params['sort'].nil? and not params['sort'].empty?)
        @sort = params['sort']
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

  def volume
  end

end
