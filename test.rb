
$LOAD_PATH << 'library/'
$LOAD_PATH << 'library/ocd/'


class Persp < Processing::App
  
  load_libraries 'ocd'
  import 'damkjer.ocd'
  import 'processing.core.PMatrix3D'
  
  def setup
    size 1024, 768, P3D
    no_stroke
    @camera1 = Camera.new(self, 0, 0, 1024, 0, 0, 0)
    @originalMatrix = PMatrix3D.new(self.getMatrix)
    @grid_size = 20
    @map_size = 100
    @tile_size = 256
    @tx = 0
    @ty = 0
    @sc = 1
  end

  def draw    
    background 0
    lights
    begin_hud
      fill 255
      rect(0, 0, 30, 30)
    end_hud
    @camera1.feed
    push_matrix
    scale(@sc,@sc)
      #translate(width/2, height/2)
      #translate(@tx, @ty)
      @cx=model_x(0, 0, 0)
      @cy=model_y(0, 0, 0)
      for i in 0..@grid_size-1 
        for j in 0..@grid_size-1
          stroke(1)
          fill(50)
          rect(i*30, j*30, 30, 30)
        end
      end
      push_matrix
        translate(@tx,@ty)
        @mx=model_x(@tx, @ty, 0)
        @my=model_y(@tx, @ty, 0)
        
        #@minCol = (cols * (screenMinX-@minX) / (@maxX-@minX)).floor
        #@maxCol = (cols * (screenMaxX-@minX) / (@maxX-@minX)).ceil
        #@minRow = (rows * (screenMinY-@minY) / (@maxY-@minY)).floor
        #@maxRow = (rows * (screenMaxY-@minY) / (@maxY-@minY)).ceil
        
        @minCol = (@map_size * (0-@mx) / (@grid_size*@tile_size-@mx)).floor
        @maxCol = (@map_size * (@grid_size-@minX) / (@grid_size*@tile_size-@mx)).ceil
        @minRow = (@map_size * (0-@my) / (@maxY-@my)).floor
        @maxRow = (@map_size * (@grid_size-@minY) / (@maxY-@minY)).ceil
        
        
        for i in 0..@grid_size2-1 
          for j in 0..@grid_size2-1
            stroke(1)
            fill(10, 10, 80, 80)
            rect(i*30, j*30, 30, 30)
            #text("zoom:"<<@zoom.to_s<<" "<<"scale:"<<@sc.to_s)
          end
        end
      pop_matrix
    pop_matrix
  end
  
  def mouseDragged 
    dx = mouseX - pmouseX
    dy = mouseY - pmouseY
    @tx += dx
    @ty += dy
    puts ["cx", @cx, "", "cy", @cy].to_s
    puts ["x", @mx, "", "y", @my].to_s
  end
  
  
  
  def key_pressed 
    if (key == CODED)
      if (keyCode == LEFT)
      end
    end
    if (key == '+' || key == '=')
      @sc *= 1.05
      puts "sc"
    end
    if (key == '_' || key == '-')
      @sc /= 1.05
      puts "sc"
    end
    if(key == 'z' || key == 'Z')
      
    end
  end
  
  def mouse_moved
    @camera1.dolly(mouse_x - pmouse_x)
  end
  
  def begin_hud
		push_matrix
		hint(DISABLE_DEPTH_TEST)
		#Load the identity matrix.
		reset_matrix
		#Apply the original Processing transformation matrix.
		apply_matrix(@originalMatrix);
  end
	
	def end_hud
		hint(ENABLE_DEPTH_TEST)
		pop_matrix
	end
  
end

Persp.new :title => "Persp"