class Ortho < Processing::App

  def setup
    size 640, 360, P3D
    no_stroke
    fill 204
  end

  def draw
    background 0
    lights
  
    mouse_pressed? ? show_perspective : show_orthographic
  
    translate width/2, height/2, 0
    rotate_x -PI/6
    rotate_y PI/3
    box 160
  end

  def show_perspective
    fov = PI/3.0
    camera_z = (height/2.0) / tan(PI * fov / 360.0)
    perspective fov, width.to_f/height.to_f, camera_z/2.0, camera_z*2.0
  end

  def show_orthographic
    ortho -width/2, width/2, -height/2, height/2, -10, 10
  end
  
end

Ortho.new :title => "ortho"