class CountersController < ApplicationController
  def index
    if (params[:name_q].nil?)
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
    @devices.each do |d|
      c = Counter.where("device_id = #{d.device_id}").order("(totalprintbw + totalprintc + totalprint1c + totalprint2c),status_date desc").limit(2).reverse
      if c.length > 1
        @first[d.device_id] = c[0]
        @oldc[d.device_id] = @first[d.device_id].totalprint1c.to_i + @first[d.device_id].totalprint2c.to_i + @first[d.device_id].totalprintc.to_i
        @oldbw[d.device_id] = @first[d.device_id].totalprintbw
      else
        @oldc[d.device_id] = 0
        @oldbw[d.device_id] = 0
      end
      @last[d.device_id] = c[-1]
      @newc[d.device_id] = @last[d.device_id].totalprint1c.to_i + @last[d.device_id].totalprint2c.to_i + @last[d.device_id].totalprintc.to_i
      @newbw[d.device_id] = @last[d.device_id].totalprintbw.to_i
      one_month_ago = @last[d.device_id].status_date.months_ago(1).to_date
      old_status = Counter.earliest_or_before(one_month_ago, d.device_id)
      unless old_status.nil?
        totalbw = @newbw[d.device_id] - old_status.totalprintbw.to_i
        totalc  = @newc[d.device_id]  - old_status.totalprint1c.to_i - old_status.totalprint2c.to_i - old_status.totalprintc.to_i
        bw_ratio = totalbw.to_f / d.device.print_volume.ave_bw
        if (bw_ratio > 1.5)
          @healthbw[d.device_id] = 'red'
        elsif (bw_ratio <= 1.5 and bw_ratio > 1)
          @healthbw[d.device_id] = 'yellow'
        elsif (bw_ratio < 0.5)
          @healthbw[d.device_id] = 'cyan'
        end
        unless d.device.print_volume.ave_c.nil?
          c_ratio = totalc.to_f / d.device.print_volume.ave_c
          if (c_ratio > 1.5)
            @healthc[d.device_id] = 'red'
          elsif (c_ratio <= 1.5 and c_ratio > 1)
            @healthc[d.device_id] = 'yellow'
          elsif (c_ratio < 0.5)
            @healthc[d.device_id] = 'cyan'
          end
        end
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
