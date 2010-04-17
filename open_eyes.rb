#Khartoum 15.640891, 32.485199
$LOAD_PATH << 'library/'
$LOAD_PATH << 'library/data/tiles/7/'
$LOAD_PATH << 'library/data/tiles/8/'
$LOAD_PATH << 'library/data/'

require 'library/tile.rb'

class OpenEyes < Processing::App
  
  load_libraries 'opengl'
  include_package "javax.media.opengl"
  
  S_tile = Struct.new(:x, :y, :z, :path)
  
  def setup 
    size 1024, 768, OPENGL
    @zoom = 7
    @start_loc = latlon2loc( 15.640891, 32.485199, @zoom, true )
    puts @start_loc
    set_center(@start_loc.x, @start_loc.y, @zoom)
    @f = create_font("Helvetica", 16)
    text_font(@f)
    
    #Tile Management
    @list = {}
    lvl_start, lvl_end = 7, 8
    for lvl in ( lvl_start..lvl_end )
      @list[lvl] = get_files(lvl)
    end
    @drawQueue = Array.new
    puts @drawQueue
    load_tiles(@zoom)
    #puts @list[8]
  end
  
  def load_tiles(zoom)
    if @tiles
      tiles = nil
    end
    @tiles = Array.new
    if(zoom = 7||8)
      for s in @list[zoom]
        t = Tile.new(s.x, s.y, s.z, s.path)
        @drawQueue.push(t)
      end
    end
  end
  
  def get_files(lvl)
	  list = Array.new
	  dir = "data/tiles/"<<lvl.to_s
	  Dir.foreach(dir) do |entry|
	    if (entry.length > 3)
  	     arr = entry.split(/x|y|z|.png/)
         arr.shift
         arr.push(entry)
         t = S_tile.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3])
         list.push(t)
      end
    end
    return list
  end

  def draw 
    background(0)
    push_matrix
    
      translate(width/2, height/2)
      scale(@sc,@sc)
      translate(@tx,@ty)

       minX = screen_x(0,0)
       minY = screen_y(0,0)
       maxX = screen_x(256,256)
       maxY = screen_y(256,256)

       @zoom = [10, [0, (log(@sc)/log(2)).round].max].min
     
       cols = pow(2,@zoom)
       rows = pow(2,@zoom)

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
        scale(1.0/pow(2,@zoom))
        for col in ( @minCol..@maxCol )
          for row in ( @minRow..@maxRow )
            fill(col >= 0 && col < cols && row >= 0 && row < rows ? 128 : 80)
            stroke(255)
            rect(col*256,row*256,256,256)
            fill(255)
            noStroke
            text_align(LEFT, TOP)
            #text("c:"+col.to_s+" "+"r:"+row.to_s+" "+"z:"+@zoom.to_s, col*256, row*256)
            #text("c:"+col.to_s+" "+"r:"+row.to_s+" "+"z:"+@zoom.to_s, col*256.to_s, row*256.to_s)
          end
        end
        fill(250, 0, 90)
        aloc = latlon2loc( 15.640891, 32.485199, @zoom, false )
        @drawQueue.each do |img|
          img.render
        end
        rect(aloc.x*256, aloc.y*256, 25, 25)
      pop_matrix
    pop_matrix
    fill(250, 0, 90)
    text("zoom:"<<@zoom.to_s<<" "<<"scale:"<<@sc.to_s<<" "<<"minCol"<<@minCol.to_s<<" "<<"tx:"<<@tx.to_s<<" "<<"ty"<<@ty.to_s, 5, 5)
  end
  
  #def configure_camera
  #  @cam = PeasyCam.new(self, 800)
  #  cam.set_minimum_distance(400)
  #  cam.set_maximum_distance(1200)
  #end
  
  def set_center(x, y, z)
		@sc = 2.0**z-1 
		@tx = -256 * x / @sc;
		@ty = -256 * y / @sc;
	end
	
	def latlon2loc(lat, lon, zoom, tile)
    factor = 2**(zoom - 1)
    lat = radians(lat)
    lon = radians(lon)
    xtile = 1 + lon / Math::PI
    ytile = 1 - log(tan(lat) + (1 / cos(lat))) / Math::PI
    if tile
      return PVector.new((xtile * factor).to_i, (ytile * factor).to_i)
    else
      return PVector.new((xtile * factor), (ytile * factor))
    end
  end
  
  def key_pressed 
    if (key == CODED) 
      if (keyCode == LEFT) 
        @tx += 15
      elsif (keyCode == RIGHT) 
        @tx -= 15        
      end
    elsif (key == '+' || key == '=') 
      @sc *= 1.05
    elsif (key == '_' || key == '-' && @sc > 0.1) 
      @sc *= 1.0/1.05
      puts @sc
    elsif (key == ' ') 
      set_center(@start_loc.x, @start_loc.y, @zoom)
    elsif (key == 'z')
      puts("@zoom is ", @zoom).to_s 
    end
  end

  def mouseDragged 
    dx = (mouseX - pmouseX) / @sc
    dy = (mouseY - pmouseY) / @sc
    @tx += dx
    @ty += dy
  end
  
end

OpenEyes.new :title => "OpenEyes"