class CountersController < ApplicationController
  before_action :set_counter, only: [:edit, :show, :update, :destroy]

  def index
    where_array = Array.new
    conditions_array = ['place holder']
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
    unless( where_array.empty? )
      conditions_array[0] = where_array.join(' and ')
    else
      conditions_array = []
    end
                                          
    @devices = Counter.joins(:device).group(:device_id).order('devices.name').select(:device_id).where(conditions_array).paginate(:page => params[:page], :per_page => 15)
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
    @lifetime = Hash.new
    
    @devices.each do |d|
      @lifetime[d.device_id] = d.device.print_volume.nil? ? nil : d.device.print_volume.lifetime
      if (params[:end_q].nil? or params[:end_q].empty?)
        @last[d.device_id] = Counter.latest(d.device_id)
      else
        @end_q = params[:end_q]
        @last[d.device_id] = Counter.latest_or_after(@end_q, d.device_id)
      end
      @newc[d.device_id] = @last[d.device_id].totalprint1c.to_i + @last[d.device_id].totalprint2c.to_i + @last[d.device_id].totalprintc.to_i
      @newbw[d.device_id] = @last[d.device_id].totalprintbw.to_i
      if (params[:start_q].nil? or params[:start_q].empty?)
        one_month_ago = @last[d.device_id].status_date.months_ago(1).to_date
        @first[d.device_id] = Counter.earliest_or_before(one_month_ago, d.device_id)
      else
        @start_q = params[:start_q]
        @first[d.device_id] = Counter.earliest_or_before(@start_q, d.device_id)
      end
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
        elsif (@bw_ratio[d.device_id] <= 0.5 and @bw_ratio[d.device_id] > 0)
          @healthbw[d.device_id] = 'cyan'
        elsif (@bw_ratio[d.device_id] < 0)
          @healthbw[d.device_id] = 'pink'
        else 
          @healthbw[d.device_id] = 'white'
        end
        unless (d.device.print_volume.ave_c.nil? or d.device.print_volume.ave_c == 0)
          @c_ratio[d.device_id] = (totalc * 30 / days) / d.device.print_volume.ave_c
          if (@c_ratio[d.device_id] > 1.5)
            @healthc[d.device_id] = 'red'
          elsif (@c_ratio[d.device_id] <= 1.5 and @c_ratio[d.device_id] > 1)
            @healthc[d.device_id] = 'yellow'
          elsif (@c_ratio[d.device_id] <= 0.5 and @c_ratio[d.device_id] > 0)
            @healthc[d.device_id] = 'cyan'
          elsif (@c_ratio[d.device_id] < 0)
            @healthc[d.device_id] = 'pink'
          else
            @healthc[d.device_id] = 'white'
          end
        end
      else
        @oldc[d.device_id] = 0
        @oldbw[d.device_id] = 0
      end
        
    end
  end
  
  def detail
    where_array = Array.new
    conditions_array = ['place holder']
    if (not params[:model_q].nil?)
      @model_q = params[:model_q]
      where_array << @model_q.where('devices.model')
      conditions_array << @model_q.condition
    end
    if (not params[:serial_q].nil?)
      @serial_q = params[:serial_q]
      where_array << @serial_q.where('devices.serial')
      conditions_array << @serial_q.condition
    end
    unless (where_array.empty?)
      conditions_array[0] = where_array.join(' and ')
    else
      conditions_array = []
    end
    @counters = Counter.where(conditions_array).order(:status_date).paginate(:page => params[:page], :include => :device)
  end

  def show
  end

  def new
    @counter = Counter.new
  end

  def create
    @counter = Counter.new(params[:counter])
    if @counter.save
      redirect_to @counter, :notice => "Successfully created counter."
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @counter.update(counter_params)
      redirect_to @counter, :notice  => "Successfully updated counter."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @counter.destroy
    redirect_to counters_url, :notice => "Successfully destroyed counter."
  end

  private

  def set_counter
    @counter = Counter.find(params[:id])
  end

  def counter_params
    params.require(:counter).permit(:status_date, :copybw, :copy2c, :copy1c, :copyfc, :printbw, :printfc, :totalprintbw, :totalprint2c, :totalprint1c, :totalprintc, :scanbw, :scan2c, :scan1c, :scanfc, :fileprintbw, :fileprint2c, :fileprint1c, :fileprintfc, :faxin, :faxinline1, :faxinline3, :otherprintbw, :otherprintc, :faxout, :faxoutline1, :faxoutline2, :faxoutline3, :hddscanbw, :hddscan2c, :hddscan1c, :hddscanfc, :tonerbkin, :tonercin, :tonermin, :toneryin, :tonernnendbk, :tonernnendc, :tonernnendm, :tonernnendy, :tonerendbk, :tonerendc, :tonerendm, :tonerendy, :tonerleftbk, :tonerleftc, :tonerleftm, :tonerlefty, :device_id)
  end
end
