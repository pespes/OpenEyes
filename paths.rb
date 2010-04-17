$LOAD_PATH << 'library/'

require 'library/path.rb'
require 'library/boid.rb'

class Paths < Processing::App
  
  # Path Following
  # Daniel Shiffman <http:#www.shiffman.net>
  # The Nature of Code, Spring 2009
  # Via Reynolds: http://www.red3d.com/cwr/steer/pathFollow.html
  # Using this variable to decide whether to draw all the stuff

  def setup
    size 640, 320
    # A @path object (series of connected points)
    smooth
    @f = create_font("Georgia", 12, true)
    # Call a function to generate new @path object
    new_path
    #Each boid has different maxspeed and maxforce for demo purposes
    @boid0 = Boid.new(PVector.new(0, height/2), 3, 0.1)
    @boid1 = Boid.new(PVector.new(0, height/2), 5, 1.0)
  end

  def draw
    background(255)
    # Display the path
    @path.display()
    # The boids follow the path
    @boid0.follow(@path)
    @boid1.follow(@path)
    # Call the generic run method (update, borders, display, etc.)
    @boid0.run()
    @boid1.run()
    # Instructions
    text_font(@f)
    fill(0)
    text("Hit space bar to toggle debugging lines.\nClick the mouse to generate a new @path.", 10, height-30)
  end

  def new_path
    # A path is a series of connected points
    # A more sophisticated path might be a curve
    @path = Path.new
    @path.addPoint(0, height/2)
    @path.addPoint(random(0, width/2), random(0, height))
    @path.addPoint(random(width/2, width), random(0, height))
    @path.addPoint(width, height/2)
  end
  
  def key_pressed
    $debug = !$debug
  end
  
  def  mouse_pressed
    new_path
  end
end




