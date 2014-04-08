module ReportHelper
  def date_time_diff(delta_t)
    diff = delta_t.to_i
    d,h,m,s = (diff/86400).to_i, (diff%86400/3600).to_i, (diff%3600/60).to_i, (diff%60).to_i
    ((d > 0) ? ((d == 1) ? "#{d}day " : "#{d}days ") : '') + "#{'%02d' % h}:#{'%02d' % m}:#{'%02d' % s}"
  end
end
