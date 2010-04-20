require 'rubygems'
Gem.clear_paths
ENV['GEM_HOME'] = '/opt/jruby/lib/ruby/gems/1.8'
ENV['GEM_PATH'] = '/opt/jruby/lib/ruby/gems/1.8'

#Khartoum 15.640891, 32.485199
$LOAD_PATH << 'library/'
$LOAD_PATH << 'library/data/tiles/7/'
$LOAD_PATH << 'library/data/tiles/8/'
$LOAD_PATH << 'library/data/'
$LOAD_PATH << 'library/peasycam'

require 'json/pure'
require 'net/http'
require 'library/tile.rb'

class OpenEyes < Processing::App
  
  load_libraries 'opengl', 'peasycam'
  include_package "javax.media.opengl"
  import 'peasy'
  import 'processing.core.PMatrix3D'
  
  S_tile = Struct.new(:x, :y, :z, :path)
  
  def setup 
    size 1024, 768, P3D
    configure_camera 
    no_smooth
    @zoom = 7
    @sc = 1
    @loaded = false
    @start_loc = latlon2loc( 15.640891, 32.485199, @zoom, true )
    @start_loc2 = latlon2loc( 15.640891, 32.485199, 2, true )
    puts @start_loc2
    @loc = @start_loc
    set_center(@start_loc.x, @start_loc.y, @zoom)
    @f = create_font("Helvetica", 16)
    text_font(@f)
    #@originalMatrix = PMatrix3D.new(self.getMatrix)
    
    #Tile Management
    @list = {}
    lvl_start, lvl_end = 6,9
    for lvl in ( lvl_start..lvl_end )
      @list[lvl] = get_files(lvl)
    end
    @gridsize = 7
    @visible_keys = []
    @markers = []
    @images = {}
    @recent = {}
    get_couch_locs
    #@drawQueue = Array.new(@gridsize)
    #@drawQueue.map! { |a| Array.new(@gridsize)}
    #puts @drawQueue
    
  end
  
  def get_couch_locs
    url = URI.parse('http://localhost:5984/flights/_design/all_latlong/_view/allgeo')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
    }
    json = JSON.parse(res.body)
    json["rows"].each do |row|
      loc = PVector.new(row["value"]["lat"].to_f, row["value"]["long"].to_f, 0)
      @markers.push(loc)
    end
  end
  
  def get_files(lvl)
	  list = {}
	  dir = "data/tiles/"<<lvl.to_s
	  Dir.foreach(dir) do |entry|
	    if (entry.length > 10)
  	     arr = entry.split(/x|y|z|.png/)
         arr.shift
         arr.push(entry)
         #t = S_tile.new(arr[0].to_i, arr[1].to_i, arr[2].to_i, arr[3])
         v =[arr[0].to_i,arr[1].to_i,arr[2].to_i]
         list[v] = "../data/tiles/"<<arr[2]<<"/"<<arr[3]
      end
    end
    return list
  end

  def draw 
    background(0)
    
    push_matrix
      
      #rotate(PI/1.0)
      translate(width/2, height/2, 0)
      fill(250, 0, 90)

      scale(@sc, @sc)
      translate(@tx,@ty, -100)       
       #
       @minX = model_x(0,0,0)
       @minY = model_y(0,0,0)
       @maxX = model_x(256,256, 0)
       @maxY = model_y(256,256, 0)

       @zoom = [10, [0, (log(@sc)/log(2)).round].max].min
     
       cols = pow(2,@zoom)
       rows = pow(2,@zoom)
       
       # find the biggest box the screen would fit in, aligned with the map:
       screenMinX = 0
       screenMinY = 0
       screenMaxX = 1024
       screenMaxY = 768
       # TODO align this box!

       # find start and end columns
       #@minCol = (cols * (screenMinX-@minX) / (@maxX-@minX)).floor
       #@maxCol = (cols * (screenMaxX-@minX) / (@maxX-@minX)).ceil
       #@minRow = (rows * (screenMinY-@minY) / (@maxY-@minY)).floor
       #@maxRow = (rows * (screenMaxY-@minY) / (@maxY-@minY)).ceil
       
       @minCol = (@loc.x-3) #* factor
       @maxCol = (@loc.x+3) #* factor
       @minRow = (@loc.y-3) #* factor
       @maxRow = (@loc.y+3) #* factor
       
       @minCol = constrain(@minCol, 0, cols)
       @maxCol = constrain(@maxCol, 0, cols)
       @minRow = constrain(@minRow, 0, rows)
       @maxRow = constrain(@maxRow, 0, rows)
       
       @visible_keys = []
       
      push_matrix
      @markers.each do |marker|
        push_matrix
        mrk = latlon2loc(marker.x, marker.y, @zoom, false)
        translate(mrk.x*256-12.5, mrk.y*256-12.5, 100)
        sphere_detail(4)
        sphere(10)
        #box(20)
        #rect(mrk.x*256-12.5, mrk.y*256-12.5, 25, 25)
        pop_matrix
      end
        scale(1.0/ 2**@zoom)
        for col in ( @minCol..@maxCol )
          for row in ( @minRow..@maxRow )
            @visible_keys.push([col, row, @zoom])
            v = [col, row, @zoom]
            if(@list[v[2]])
              if(!@images.has_key?(v) && @list[v[2]][v])
                get_image(v)
              else
                #puts @images.keys
                if(@images[v])
                  image(@images[v], col*256, row*256 )
                  if(!@recent.has_key?(v))
                    @recent[v] = @images[v]
                  end
                  #puts @recent.size
                end
              end
            end
          end
        end

      pop_matrix
    pop_matrix
    #begin_hud
    #   text("zoom:"<<@zoom.to_s<<" "<<"scale:"<<@sc.to_s<<" "<<"minCol"<<@minCol.to_s<<" "<<"minRow"<<@minRow.to_s<<" "<<"maxCol"<<@maxCol.to_s<<" "<<"maxRow"<<@maxRow.to_s<<" "<<"minX"<<@minX.to_s<<" "<<"maxX"<<@maxX.to_s, -600,-400)
    #end_hud
    if(@recent.size > 40)
      @images.replace(@recent)
      @recent.clear
    end
    fill(250, 0, 90)
  end
  
  def configure_camera
    @cam = PeasyCam.new(self, 800)
    @cam.set_minimum_distance(-1000)
    @cam.set_maximum_distance(5000)
  end
  
  def get_image(v)
    path = @list[v[2]][v]
    img = PImage.new
    t = Thread.new { 
      img = load_image(path)    
    }
    t.join
    @images[v] = img
  end
    
  def set_center(x, y, z)
		@sc = 2.0**z-1 
		@tx = -256 * x / @sc
		@ty = -256 * y / @sc
	end
	
	def latlon2loc(lat, lon, zoom, tile)
    factor = 2**(zoom - 1)
    lat = radians(lat)
    lon = radians(lon)
    xtile = 1 + lon / Math::PI
    ytile = 1 - log(tan(lat) + (1 / cos(lat))) / Math::PI
    #puts "xtile: "<<xtile.to_s<<" ytile: "<<ytile.to_s
    if tile
      return PVector.new((xtile * factor).to_i, (ytile * factor).to_i, zoom)
    else
      return PVector.new((xtile * factor), (ytile * factor), zoom)
    end
  end
  
  def key_pressed 
    if (key == CODED)
      
      if (keyCode == LEFT) 
        @tx += 0.15
        #@loc = get_cent(@tx, @ty, @sc, @zoom)
        @loc = PVector.new(@loc.x-0.15,@loc.y,@loc.z)
        #set_center(@loc.x, @loc.y, @zoom)
      elsif (keyCode == RIGHT) 
        @tx -= 0.15
        @loc = PVector.new(@loc.x+0.15,@loc.y,@loc.z)
        #@loc = get_cent(@tx, @ty, @sc, @zoom)
      end
    elsif (key == '+' || key == '=')
      pz = @zoom 
      @sc *= 1.05
      puts ["prev zoom", pz, "", "curr zoom", @zoom].to_s
      #@loc = get_cent(@tx, @ty, @sc, @zoom)
      check_level(@zoom, @sc, @loc.x, @loc.y)
    elsif (key == '_' || key == '-' && @sc > 0.1) 
      @sc *= 1.0/1.05
      #@loc = get_cent(@tx, @ty, @sc, @zoom)
      check_level(@zoom, @sc, @loc.x, @loc.y)
    elsif (key == ' ') 
      set_center(@start_loc.x, @start_loc.y, 7)
      @loc = get_cent(@tx, @ty, @sc, @zoom)
    elsif (key == 'z')
      puts "z"
    end
  end
  
  def get_cent(tx, ty, sc, z)
		column = (ty * sc / -256).round
		row = (tx * sc / -256).round
		puts [row, " ", column].to_s
		return PVector.new(row, column, z)
	end
  
  def zoom_plus(x,y,z)
    basic = 2**z-1
    
  end
  
  def check_level(z, s, x, y)
    l = log(s) / log(2)
    if (l < z-0.5)
      @loc = PVector.new(x/2,y/2,z-1)
      #@loc = get_cent(@tx, @ty, @sc, @zoom)
      puts "lower than zoom: " << l.to_s
      #deref(z+1)
      #load_tiles(z-1)
    elsif (l > z+0.5)
      @loc = PVector.new(x*2,y*2,z+1)
      #@loc = get_cent(@tx, @ty, @sc, @zoom)
      puts "higher than zoom: " << l.to_s
      #deref(z-1)
      #load_tiles(z+1)
    end
  end
  
  def mouseDragged 
    #dx = (mouseX - pmouseX) / @sc
   #dy = (mouseY - pmouseY) / @sc
    #@tx += dx
    #@ty += dy
  end
  
  #def begin_hud
	#	push_matrix
	#	hint(DISABLE_DEPTH_TEST)
		#Load the identity matrix.
	#	reset_matrix
		#Apply the original Processing transformation matrix.
	#	apply_matrix(@originalMatrix);
  #end
	
	#def end_hud
	#	hint(ENABLE_DEPTH_TEST)
	#	pop_matrix
	#end
  
end

OpenEyes.new :title => "OpenEyes"