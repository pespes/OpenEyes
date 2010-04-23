$LOAD_PATH << 'library/'

require 'attractor.rb'
require 'particle.rb'

class Arc
  
  V3 = Java::toxi.geom
  include Processing::Proxy  
    
  def initialize(start, finish)
    size 800, 600, P3D
    @ac = V3.Vec3D.new(0.0,0.0,2.0)
    @ve = V3.Vec3D.new(0.0,1.0,1.0)
    new_particle(start, finish)
  end

  def new_particle(start_loc, end_loc)
    t = start_loc.add(end_loc)
    t.scale_self(0.5)
    t.add_self(0,0,300)
    @lo = start_loc
    # Create new thing with some initial settings
    @p = Particle.new(@ac,@ve,start_loc)
    # Create an attractive body
    @a = Attractor.new(t, 3, 6)
    @a2 = Attractor.new(end_loc, 3, 6)
    @target = false
  end
  
  def draw_particle
    if(@p.loc.z <= 300 && @target == false)
      @a.go
      f = @a.calcGravForce(@p)
      @p.apply_force(f)
      puts [@p.loc.x, @p.loc.y, @p.loc.z].to_s
      @p.run
    elsif(@p.loc.z >= 0)
      @a2.go
      f2 = @a2.calcGravForce(@p)
      @p.apply_force(f2)
      @target = true
      puts [@p.loc.x, @p.loc.y, @p.loc.z].to_s
      @p.run
    end
    @p.draw_points
  end
  
end