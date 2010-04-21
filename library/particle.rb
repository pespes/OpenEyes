# Particles + Forces
# Daniel Shiffman <http:#www.shiffman.net>

# A simple Particle class
# Incorporates forces code

class Particle 
  
  include Processing::Proxy
  attr_accessor :loc, :vel, :acc
  
  # Another constructor (the one we are using here)
  def initialize(ac,ve,lo,r) 
    @acc = PVector.new(ac.x, ac.y, ac.z)
    @vel = PVector.new(ve.x, ve.y, ve.z)
    @loc = PVector.new(lo.x, lo.y, lo.z)
    @r = 10
    @timer = 100.0
    @maxspeed = 2
  end

  def run
    update
    render
  end

  # Method to update @location
  def update
    @vel.add(@acc)
    @vel.limit(@maxspeed)
    @loc.add(@vel)
    @acc.mult(0)
    @timer -= 0.5
  end
  
  def apply_force(force) 
    mass = 1 # We aren't bothering with mass here
    force.div(mass)
    @acc.add(force)
  end

  # Method to display
  def render 
    ellipse_mode(CENTER)
    stroke(0,@timer)
    fill(80)
    ellipse(@loc.x,@loc.y,@r,@r)
  end
  
  # Is the particle still useful?
  def dead? 
    if (timer <= 0.0) 
      return true
    else 
      return false
    end
  end
end