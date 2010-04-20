
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
    @grid_size = 5
    @map_size = 10
    @tile_size = 256
    @tx = 0
    @ty = 0
    @sc = 1
    @f = create_font("Helvetica", 16)
    text_font(@f)
  end

  def draw    
    background 0
    lights
    #@camera1.feed
    push_matrix
      #rotate(PI/1.0)
      translate(width/2, height/2)
      #scale(@sc,@sc)
      translate(@tx,@ty)   
       
       #
       @minX = model_x(0,0,0)
       @minY = model_y(0,0,0)
       @maxX = model_x(256,256, 0)
       @maxY = model_y(256,256, 0)

       minX = screen_x(0,0)
       minY = screen_y(0,0)
       maxX = screen_x(256,256)
       maxY = screen_y(256,256)

       #@zoom = [10, [0, (log(@sc)/log(2)).round].max].min
     
       cols = 128 #pow(2,@zoom)
       rows = 128 #pow(2,@zoom)

       # find the biggest box the screen would fit in, aligned with the map:
       screenMinX = 0
       screenMinY = 0
       screenMaxX = width
       screenMaxY = height
       # TODO align this box!

       # find start and end columns
       @minCol = (cols * (screenMinX-minX) / (maxX-minX)).floor
       @maxCol = (cols * (screenMaxX-minX) / (maxX-minX)).ceil
       @minRow = (rows * (screenMinY-minY) / (maxY-minY)).floor
       @maxRow = (rows * (screenMaxY-minY) / (maxY-minY)).ceil
    
       
       @minCol = constrain(@minCol, 0, cols);
       @maxCol = constrain(@maxCol, 0, cols);
       @minRow = constrain(@minRow, 0, rows);
       @maxRow = constrain(@maxRow, 0, rows);
       
      push_matrix
        scale(1.0/ 128)
        for col in ( @minCol..@maxCol )
          for row in ( @minRow..@maxRow )
            fill(75)
            stroke(1)
            #rect(col*@tile_size,row*@tile_size, 256, 256)
            fill(255, 55, 15)
            text(["col:", col, " ", "row", row].to_s, col*256, row*256)
            #puts ["col:", col, " ", "row", row].to_s
          end
        end
      pop_matrix
      begin_hud
        fill(255, 155, 25)
        text([@minCol, " ", @maxCol, " ", @minRow, " ", @maxRow].to_s, 20, 20)
        text([@m_startx, " ", @m_starty, " ", @m_endx, " ", @m_endy].to_s, 20, 40)
        text([screenMinX, " ", screenMaxX, " ", screenMinY, " ", screenMaxY].to_s, 20, 60)
      end_hud
    pop_matrix
  end
  def mouseDragged 
    dx = mouseX - pmouseX
    dy = mouseY - pmouseY
    @tx += dx
    @ty += dy
    puts ["minX:", @minX, " ", "maxX:", @maxX].to_s
    puts ["minY:", @minY, " ", "maxX:", @maxY].to_s
    testx = @maxX-@minX
    testy = @maxY-@minY
    puts ["testX:", testx, " ", "testY:", testy].to_s
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