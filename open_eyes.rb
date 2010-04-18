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
    size 1024, 768#, OPENGL
    @zoom = 7
    @loaded = false
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
    @gridsize = 7
    @drawQueue = {}
    #@drawQueue = Array.new(@gridsize)
    #@drawQueue.map! { |a| Array.new(@gridsize)}
    #puts @drawQueue
  end
  
  def get_files(lvl)
	  list = {}
	  dir = "data/tiles/"<<lvl.to_s
	  Dir.foreach(dir) do |entry|
	    if (entry.length > 10)
  	     arr = entry.split(/x|y|z|.png/)
         arr.shift
         arr.push(entry)
         t = S_tile.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3])
         list[arr[0]<<arr[1]] = t
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
       
       if(!@loaded)
         load_tiles
       end
       
      push_matrix
        scale(1.0/pow(2,@zoom))
        for col in ( @minCol..@maxCol )
          for row in ( @minRow..@maxRow )
            hash = col.to_s << row.to_s
            fill(col >= 0 && col < cols && row >= 0 && row < rows ? 128 : 80)
            stroke(255)
            rect(col*256,row*256,256,256)
            fill(255)
            noStroke
            text_align(LEFT, TOP)
            #text("c:"+col.to_s+" "+"r:"+row.to_s+" "+"z:"+@zoom.to_s, col*256, row*256)
            #text("c:"+col.to_s+" "+"r:"+row.to_s+" "+"z:"+@zoom.to_s, col*256.to_s, row*256.to_s)
            text("c:"+col.to_s+" "+"r:"+row.to_s+" "+"z:"+@zoom.to_s, col*256, row*256)
            if (@drawQueue[hash])
              @drawQueue[hash].render
            end
          end
        end
        fill(250, 0, 90)
        aloc = latlon2loc( 15.640891, 32.485199, @zoom, false )
        rect(aloc.x*256, aloc.y*256, 25, 25)
      pop_matrix
    pop_matrix
    fill(250, 0, 90)
    text("zoom:"<<@zoom.to_s<<" "<<"scale:"<<@sc.to_s<<" "<<"minCol"<<@minCol.to_s<<" "<<"maxCol"<<@maxCol.to_s, 5, 5)
  end
  
  def load_tiles
    for col in ( @minCol..@maxCol )
      for row in ( @minRow..@maxRow )
        hash = col.to_s << row.to_s
        if(@list[@zoom][hash] && !@drawQueue[hash])
          s = @list[@zoom][hash]
          @drawQueue[hash] = Tile.new(s.x, s.y, s.z, s.path)
        end
      end
    end
    low = (@minCol.to_s << @minRow.to_s).to_i
    high = (@maxCol.to_s << @maxRow.to_s).to_i
    @drawQueue.delete_if { |key, value| key.to_i < low || key.to_i > high} 
    puts @drawQueue
    @loaded = true
    #puts @list[lvl]
    #puts @list[lvl][7154.to_s]
    #@drawQueue[lvl]=nil
    #if(zoom = 7||8)
    #  @drawQueue[lvl]=Array.new
    #  for s in @list[lvl]
    #    puts s
    #    t = Tile.new(s.x, s.y, s.z, s.path)
    #    @drawQueue[lvl].push(t)
    #  end
    #end
  end
  
  
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
      load_tiles
      check_level(@zoom, @sc)
    elsif (key == '_' || key == '-' && @sc > 0.1) 
      @sc *= 1.0/1.05
      load_tiles
      check_level(@zoom, @sc)
    elsif (key == ' ') 
      set_center(@start_loc.x, @start_loc.y, 7)
    elsif (key == 'z')
      puts "z"
    end
  end
  
  def check_level(z, s)
    l = log(s) / log(2)
    if (l < z-0.35)
      puts "lower than zoom: " << l.to_s
      #deref(z+1)
      #load_tiles(z-1)
    elsif (l > z+0.35)
      puts "higher than zoom: " << l.to_s
      #deref(z-1)
      #load_tiles(z+1)
    end
  end
  
  def mouseDragged 
    dx = (mouseX - pmouseX) / @sc
    dy = (mouseY - pmouseY) / @sc
    @tx += dx
    @ty += dy
    load_tiles
  end
  
end

OpenEyes.new :title => "OpenEyes"