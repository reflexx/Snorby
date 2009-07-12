class GraphController < ApplicationController

  def event_severity
    title = Title.new("Event Severity")

    high = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 1']).size
    medium = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 2']).size
    low = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 3']).size

    data = []

    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#val# Events of #total# Total.<br>#percent# of 100%<br>'
    pie.colours = ["#adffa2", "#f8f9a4", "#fb9c9c"]

    data << PieValue.new(low, "Low Severity") unless low == 0
    data << PieValue.new(medium, "Medium Severity") unless medium == 0
    data << PieValue.new(high, "High Severity") unless high == 0

    pie.values  = data

    chart = OpenFlashChart.new
    chart.title = title
    chart.set_bg_colour('#FFFFFF')
    chart.add_element(pie)

    chart.x_axis = nil

    render :text => chart.to_s
  end

  def sensor_information
    @sensors ||= Sensor.all :include => [:events, :sensor]
    data = []
    title = Title.new("Sensor Information")

    pie = Pie.new

    for sensor in @sensors
      data << PieValue.new(sensor.events.size, "#{sensor.hostname}") unless sensor.events.size <= 1
    end

    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = ["#adffa2", "#f8f9a4", "#fb9c9c"]
    pie.values  = data

    chart = OpenFlashChart.new
    chart.title = title
    chart.set_bg_colour('#FFFFFF')
    chart.add_element(pie)

    chart.x_axis = nil

    render :text => chart.to_s
  end


  def category_information

    high = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 1']).size
    medium = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 2']).size
    low = Event.find(:all, :include => :sig, :conditions => ['signature.sig_priority = 3']).size

    data = []
    data_labels = []
    unless high.blank?
      data << high
      data_labels << "High Severity"
    end
    unless medium.blank?
      data << medium
      data_labels << "Medium Severity"
    end
    unless low.blank?
      data << low
      data_labels << "Low Severity"
    end

    x = XAxis.new
    x.grid_colour= '#FFFFFF'
    x.set_3d 5
    x.offset= true
    x.colour= '#909090'
    x.labels= data_labels

    y = YAxis.new
    y.grid_colour= '#FFFFFF'
    @all ||= Event.all.size
    if @all >= 1000
      y.set_range(0, @all, 100)
    else
      y.set_range(0, @all, 50)
    end

    bar = Bar3d.new
    #bar.set_values(@data)

    bar.values= data
    bar.colour= '#28d2fc'
    bar.tooltip = '#val# Events'

    chart = OpenFlashChart.new
    chart.title= Title.new('Event Severity')
    chart << bar
    chart.bg_colour = '#FFFFFF'
    chart.x_axis= x
    chart.y_axis= y
    render :text => chart.render
  end



end
