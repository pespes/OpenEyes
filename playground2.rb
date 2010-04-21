$LOAD_PATH << 'library/'

class Playground < Processing::App
  
    load_libraries 'opengl', 'toxiclibscore', 'verletphysics'
    include_package "toxi.geom"
    include_package "toxi.physics"
    
  def setup
    size 800, 600, P3D
    puts library_loaded? :toxiclibscore
    no_stroke
    # Initialize the physics
    @physics= VerletPhysics.new()
    @physics.setGravity(Vec3D.new(0,0.2,0));

    # This is the center of the world
    center = Vec3D.new(width/3,height/3,0);
    # These are the worlds dimensions (a vector pointing out from the center);
    extent = Vec3D.new(width/3,height/3,0);

    # Set the world's bounding box
    @physics.set_world_bounds(AABB.new(center,extent));

    # Make two particles
    @p1 = VerletParticle.new(width/2,20,0);
    @p2 = VerletParticle.new(100,180,0);
    @p3 = VerletParticle.new(width/2,180,0);
    # Lock one in place
    @p1.lock

    # Make a spring connecting both Particles
    spring= VerletSpring.new(@p1,@p2,200,0.01)

    # Anything we make, we have to add into the physics world
    @physics.add_particle(@p1);
    @physics.add_particle(@p2);
    @physics.add_particle(@p3);
    @physics.add_spring(spring);
  end
  t = SomeFlexibleClass.new
  def draw
    background 0
    @physics.update()
    ellipse(@p1.x, @p1.y, 16, 16)
    ellipse(@p2.x, @p2.y, 16, 16)
    ellipse(@p3.x, @p3.y, 16, 16)
  end
  
  def mouse_pressed
   # @p2.x = mouse_x
    #@p2.y = mouse_y
   @p3.x = mouse_x
   @p3.y = mouse_y
  end
end

class SomeFlexibleClass
    include "toxi.geom"
    include java.lang.Comparable
  end

Playground.new :title => "playground"