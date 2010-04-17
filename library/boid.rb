# Path Following
# Daniel Shiffman <http:#www.shiffman.net>
# The Nature of Code, Spring 2009

# Boid class

class Boid 
  
  include Processing::Proxy
  include Math
  
  # Constructor initialize all values
  def initialize( l, ms, mf) 
    @loc = l.get
    @r = 4.0
    @maxspeed = ms
    @maxforce = mf
    @acc =PVector.new(0,0)
    @vel = PVector.new(@maxspeed,0)
  end

  # Main "run" function
  def run
    update
    borders
    render
  end

  # This function implements Craig Reynolds' path following algorithm
  # http:#www.red3d.com/cwr/steer/PathFollow.html
  def follow(p)

    # Predict @location 25 (arbitrary choice) frames ahead
    predict = @vel.get
    predict.normalize
    predict.mult(25)
    predictloc = PVector.add(@loc, predict)

    # Draw the predicted @location
    if ($debug) 
      fill(0)
      stroke(0)
      line(@loc.x, @loc.y, predictloc.x, predictloc.y)
      ellipse(predictloc.x, predictloc.y, 4, 4)
    end

    # Now we must find the normal to the path from the predicted location
    # We look at the normal for each line segment and pick out the closest one
    target = nil
    dir = nil
    record = 1000000  # Start with a very high record distance that can easily be beaten

    # Loop through all points of the path
    p.points.each_index do |i|
      if (i < p.points.length-1)
        # Look at a line segment
        a = p.points[i]
        b = p.points[i+1]

        # Get the normal point to that line
        normal = getNormalPoint(predictloc,a,b)

        # Check if normal is on line segment
        da = PVector.dist(normal,a)
        db = PVector.dist(normal,b)
        line = PVector.sub(b,a)
        # If it's not within the line segment, consider the normal to just be the end of the line segment (point b)
        if (da + db > line.mag+1) 
          normal = PVector.new(b.x, b.y)
        end

        # How far away are we from the path?
        d = PVector.dist(predictloc,normal)
        # Did we beat the record and find the closest line segment?
        if (d < record) 
          record = d
          # If so the target we want to steer towards is the normal
          target = normal

          # Look at the direction of the line segment so we can seek a little bit ahead of the normal
          dir = line
          dir.normalize
          # This is an oversimplification
          # Should be based on distance to path & velocity
          dir.mult(10)
        end
      end
    end

    # Draw the debugging stuff, $debug is global
    if ($debug) 
      # Draw normal location
      fill(0)
      no_stroke
      line(predictloc.x, predictloc.y, target.x, target.y)
      ellipse(target.x, target.y, 4, 4)
      stroke(0)
      # Draw actual target (red if steering towards it)
      line(predictloc.x, predictloc.y, target.x, target.y)
      if (record > p.radius) 
        fill(255, 0, 0)
        no_stroke
        ellipse(target.x+dir.x, target.y+dir.y, 8, 8)
      end
    end

    # Only if the distance is greater than the path's radius do we bother to steer
    if (record > p.radius) 
      target.add(dir)
      seek(target)			
    end
  end


  # A function to get the normal point from a point (p) to a line segment (a-b)
  # This function could be optimized to make fewer new Vector objects
  def getNormalPoint(p, a, b) 
    # Vector from a to p
    ap = PVector.sub(p,a)
    # Vector from a to b
    ab = PVector.sub(b,a)
    ab.normalize # Normalize the line
    # Project vector "diff" onto line by using the dot product
    ab.mult(ap.dot(ab))
    normalPoint = PVector.add(a,ab)
    return normalPoint
  end


  # Method to update @location
  def update 
    # Update ve@locity
    @vel.add(@acc)
    # Limit speed
    @vel.limit(@maxspeed)
    @loc.add(@vel)
    # Reset @accelertion to 0 each cycle
    @acc.mult(0)
  end

  def seek(target) 
    @acc.add(steer(target,false))
  end

  def arrive(target) 
    @acc.add(steer(target,true))
  end

  # A method that calculates a steering vector towards a target
  # Takes a second argument, if true, it slows down as it approaches the target
  def steer(target, slowdown) 
    desired = PVector.sub(target,@loc)  # A vector pointing from the @location to the target
    d = desired.mag # Distance from the target is the magnitude of the vector
    # If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) 
      # Normalize desired
      desired.normalize
      # Two options for desired vector magnitude (1 -- based on distance, 2 -- @maxspeed)
      if ((slowdown) && (d < 100.0)) 
        desired.mult(@maxspeed*(d/100.0)) # This damping is somewhat arbitrary
      else desired.mult(@maxspeed)
        # Steering = Desired minus Ve@locity
        steer = PVector.sub(desired,@vel)
        steer.limit(@maxforce)  # Limit to maximum steering force
      end 
    else 
      steer = PVector.new(0,0)
    end
    return steer
  end

  def render 
    # Draw a triangle rotated in the direction of ve@locity
    theta = @vel.heading2D + radians(90)
    fill(175)
    stroke(0)
    push_matrix
      translate(@loc.x,@loc.y)
      rotate(theta)
      begin_shape(TRIANGLES)
        vertex(0, -@r*2)
        vertex(-@r, @r*2)
        vertex(@r, @r*2)
      end_shape
    pop_matrix
  end

  # Wraparound
  def borders 
    if (@loc.x < -@r) 
      @loc.x = width+@r
    end
    #if (@loc.y < -r) @loc.y = height+r
    if (@loc.x > width+@r) 
      @loc.x = -@r
    end
    #if (@loc.y > height+r) @loc.y = -r
  end

end