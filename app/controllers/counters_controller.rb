class CountersController < ApplicationController
  def index
    if (params[:name_q].nil? or params[:name_q].empty?)
      where = []
    else
      @name_q = params[:name_q]
      where = ["devices.name regexp ?", @name_q]
    end
    @devices = Counter.group(:device_id).joins(:device).order('devices.name').select(:device_id).where(where).paginate(:page => params[:page], :per_page => 15)
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
    
    @devices.each do |d|
      if (params[:end_q].nil? or params[:end_q].empty?)
        @last[d.device_id] = Counter.where("device_id = #{d.device_id}").order("status_date").last
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
        elsif (@bw_ratio[d.device_id] < 0.5)
          @healthbw[d.device_id] = 'cyan'
        end
        unless (d.device.print_volume.ave_c.nil? or d.device.print_volume.ave_c == 0)
          @c_ratio[d.device_id] = (totalc * 30 / days) / d.device.print_volume.ave_c
          if (@c_ratio[d.device_id] > 1.5)
            @healthc[d.device_id] = 'red'
          elsif (@c_ratio[d.device_id] <= 1.5 and @c_ratio[d.device_id] > 1)
            @healthc[d.device_id] = 'yellow'
          elsif (@c_ratio[d.device_id] < 0.5)
            @healthc[d.device_id] = 'cyan'
          end
        end
      else
        @oldc[d.device_id] = 0
        @oldbw[d.device_id] = 0
      end
        
    end
  end
  
  def detail
    where = Array.new
    if (not params[:commit].nil?)
      if (not params[:name_q].nil?)
        @name_q = params[:name_q]
        where = ["devices.name = ?", @name_q]
      end
    end
    @counters = Counter.joins(:device).where(where).order(:status_date).paginate(:page => params[:page])
  end

  def show
    @counter = Counter.find(params[:id])
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
    @counter = Counter.find(params[:id])
  end

  def update
    @counter = Counter.find(params[:id])
    if @counter.update_attributes(params[:counter])
      redirect_to @counter, :notice  => "Successfully updated counter."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @counter = Counter.find(params[:id])
    @counter.destroy
    redirect_to counters_url, :notice => "Successfully destroyed counter."
  end
end
