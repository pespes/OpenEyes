# Path Following
# Daniel Shiffman <http:#www.shiffman.net>
# The Nature of Code, Spring 2009

class Path 
  
  include Processing::Proxy
  include Math
  
  attr_accessor :points, :radius
  
  def initialize
    # Arbitrary @radius of 20
    @radius = 20
    @points = Array.new
    $debug = true
  end

  # Add a point to the path
  def addPoint( x, y) 
    point = PVector.new(x, y)
    @points.push(point)
  end

  # Draw the path
  def display 

    # Draw the @radius as thick lines and circles
    if ($debug==true) 
      # Draw end @points
      @points.each do |point|
        #point = @points.get(point)
        fill(175)
        noStroke()
        ellipse(point.x, point.y, @radius*2, @radius*2)
      end

      # Draw Polygon around path
      @points.each_index do |i|
        if (i < @points.length-1)
          p_start = @points[i]
          p_end = @points[i+1]
          #puts p_start, p_end
          line = PVector.sub(p_end, p_start)
          normal = PVector.new(line.y, -line.x)
          normal.normalize
          normal.mult(@radius)

          # Polygon has four vertices
          a = PVector.add(p_start, normal)
          b = PVector.add(p_end, normal)
          c = PVector.sub(p_end, normal)
          d = PVector.sub(p_start, normal)

          fill(175)
          no_stroke
          begin_shape
          vertex(a.x,a.y)
          vertex(b.x,b.y)
          vertex(c.x,c.y)
          vertex(d.x,d.y)
          end_shape
        end
      end
    end

    # Draw Regular Line
    stroke(0)
    no_fill()
    begin_shape
    @points.each do |point|
      #loc = @points.get(point)
      vertex(point.x, point.y)
    end
    end_shape

  end
  
end



