class AlertsController < ApplicationController
  def new
    @alert = Alert.new
  end

  def create
    @alert = Alert.new(params[:alert])
    if @alert.save
      redirect_to alerts_url, :notice => "Successfully created alert."
    else
      render :action => 'new'
    end
  end

  def show
  end
  
  def index
    @request = request.env['QUERY_STRING'].sub(/sort=[^&]+&*/,'')
    if (params[:sort].nil?)
      @sort = 'alerts.id'
    elsif (params[:sort] == 'devices.model' or 
           params[:sort] == 'devices.serial' or 
           params[:sort] == 'devices.code' or
           params[:sort] == 'alert_msg')
      @sort = "#{params[:sort]},devices.name,alert_date"
    elsif (params[:sort] == 'devices.name')
      @sort = "#{params[:sort]},alert_date"
    else
      @sort = params[:sort]
    end
    unless (params[:commit].nil?)
      where_array = Array.new
      comment_array = Array.new
      condition_array = ['place holder']
      if (not params['date_q'].nil? and not params['date_q'].empty?)
        @date_q = params[:date_q]
        condition_array << @date_q.condition
        where_array << @date_q.where('alert_date')
        comment_array << "Date = #{@date_q}"
      end
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
        @client.name = params[:client][:name]
        where_array << @client.name.where('clients.name')
        condition_array << @client.name.condition
        comment_array << "Client Name = #{@client.name}"
      end
      if(not params['msg_q'].nil? and not params['msg_q'].empty?)
        @msg_q = params[:msg_q]
        where_array << @msg_q.where('alert_msg')
        condition_array << @msg_q.condition
        comment_array << "Message = #{@msg_q}"
      end
#       if(not params['sort'].nil? and not params['sort'].empty?)
#         @sort = params['sort']
#       end
      unless where_array.empty?
        condition_array[0] = where_array.join(' and ')
        comment = comment_array.join(' and ')
      else
        condition_array = []
      end
    end
    if (params[:page].nil? or params[:page].empty?)
      page_to_show = (Alert.where(condition_array).joins(:device => :client).count / 30.0 + 0.5).round
    else
      page_to_show = params[:page]
    end
    @alerts = Alert.where(condition_array).order(@sort).paginate(:page => page_to_show, :per_page => 30, :include => {:device => :client})
    if (params[:commit] == 'Export')
      @request.sub!(/commit=Export/,'commit=Find')
      csv_data = '"alert date","device name","model","serial number","machine code","client","message"' + "\n"
      unless (condition_array.empty?)
        csv_data += "### Filter condition: #{comment}\n\n"
      end
      Alert.order(@sort).where(condition_array).all(:include => {:device => :client}).each do |a|
        csv_data += a.to_csv + "\n"
      end
      send_data(csv_data, :type => "text/csv", :filename => 'alerts.csv', :disposition => "attachment")
    end
  end
  
end
