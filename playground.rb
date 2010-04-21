$LOAD_PATH << 'library/'

require 'library/attractor.rb'
require 'library/particle.rb'

class Playground < Processing::App
  
    
  def setup
    size 200, 200, P3D
    @ac = PVector.new(0.0,0.0);
    @ve = PVector.new(0.0,1.0);
    @lo = PVector.new(50,50);
    # Create new thing with some initial settings
    @p = Particle.new(@ac,@ve,@lo,10);
    # Create an attractive body
    @a = Attractor.new(PVector.new(width/2, height/2), 5, 4);
  end

  def draw
    background 0
    @a.go
    # Calculate a force exerted by "attractor" on "thing"
    f = @a.calcGravForce(@p)
    # Apply that force to the thing
    @p.apply_force(f)
    # Update and render the positions of both objects
    @p.run
  end
  
  def mouse_pressed
  end
end


Playground.new :title => "playground"