class Slider
  
  include Processing::Proxy
  attr_accessor :slider_a, :slider_y, :state_a, :state_b  
  
  def initialize(data, size)
    @data = data
    @size = size
    @slider_a = 0
    @slider_b = @size-2
    @x, @y = 0, 0
    @state_a = 0.to_i
    @state_b = data.length-1.to_i
  end
  
  def update(mx, my)
    if(mx >= 0 && mx <= @size)
      if(my >= @y-20 && my <= @y+20)
        da = (mx - @slider_a).abs
        db = (mx - @slider_b).abs
        if(da < db)
          @slider_a = mx
        else
          @slider_b = mx
        end
      end
    end
    @state_a = map(@loc_a, 0, @size, 0, @data.length-1).to_i
    @state_b = map(@loc_b, 0, @size, 0, @data.length-1).to_i
    ##puts ["mouse", " ", mx, " ", my, " ", "x: ", @x, " y: ", @y].to_s
  end
  
  def render(tlx, tly)
    @data.each_index do |i|
      stroke(0)
      l = map(i, 0, @data.length-1, 0, @size)
      line(l, 0, l, 10)
      fill(0)
      text_size(13)
      text(@data[i][0,3].capitalize, l, -3)
    end
    @x = tlx
    @y = tly
    fill(0)
    rect(0, 0, @size, 2)
    @loc_a = constrain(@slider_a, 0, @slider_b)
    @loc_b = constrain(@slider_b, @slider_a, @size)
    fill(200)
    rect(@loc_a, 0, @loc_b-@loc_a, 9)
    fill(0)
    rect(@loc_a, 0, 2, 16)
    rect(@loc_b, 0, 2, 16)  
  end
  
end