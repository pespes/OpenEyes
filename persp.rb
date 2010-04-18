class Persp < Processing::App

  def setup
    size 640, 360, P3D
    no_stroke
  end

  def draw
    lights
    background 204
    camera_y = height/2.0
    fov = mouse_x/width.to_f * PI/2.0
    camera_z = camera_y / tan(fov / 2.0)
    aspect = width.to_f / height.to_f

    aspect /= 2.0 if mouse_pressed?

    perspective(fov, aspect, camera_z/10.0, camera_z*10.0)

    translate width/2.0+30, height/2.0, 0
    rotate_x -PI/6
    rotate_y PI/3 + mouse_y/height.to_f * PI
    box 45
    translate 0, 0, -50
    box 30
  end
  
end

Persp.new :title => "Persp"