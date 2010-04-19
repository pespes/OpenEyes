 
	TILE_WIDTH = 256
	TILE_HEIGHT = 256
	
	tx = -TILE_WIDTH / 2 # half the world width, at zoom 0
	ty = -TILE_HEIGHT / 2 # half the world height, at zoom 0
	sc = 1
	
	max_pending = 4
	max_images_to_keep = 120
	grid_padding = 1
	width
	height
	
  pending = new Hashtable<Coordinate, Runnable>()
	images = new Hashtable<Coordinate, Object>()
	queue = new Vector<Coordinate>()
	recent_images = new Vector<Object>()

	
	def initialize(width, height)
	 
		provider = _provider
		width = _width
		height = _height
		sc = ( )Math.ceil(Math.min(height / ( ) TILE_WIDTH, width / ( ) TILE_HEIGHT))
		markers = new ArrayList<Marker>()
	end
	
	
	def getCenterCoordinate() 	
	  # Till: Fixed: TILE_WIDTH and TILE_HEIGHT were  erchanged. Worked only because they are the same.
  	row = ty * sc / -TILE_HEIGHT
  	column = tx * sc / -TILE_WIDTH
  	zoom = zoomForScale(sc)
    return new [row, column, zoom]
	end
	
	def setCenter() 
		sc = 2**zoom-1
		tx = -TILE_WIDTH * x / sc
		ty = -TILE_HEIGHT * y / sc
	end

	
	# TILES
	  def grabTile(Coordinate coord)
	 
		if (!pending.containsKey(coord) && !queue.contains(coord) && !images.containsKey(coord))
			queue.add(coord)
	end
	
	# TODO: images & pending thread safe?
	  def tileDone(Coordinate _coord, Object _image)
	 
		if (pending.containsKey(_coord) && _image != null)
		 
			images.put(_coord, _image)
			pending.remove(_coord)
		end
		else
		 
			queue.add(_coord)
			pending.remove(_coord)
		end
	end
	
	#initiate tile loading – thus depending on the specific loader (for gestalt bitmaps, pimages, etc.)
	  abstract def processQueue()
	
	# LOAD SORTING
	  class QueueSorter implements Comparator<Coordinate>
	 
		Coordinate center

		  def setCenter(Coordinate center)
		 
			this.center = center
		end

		    compare(Coordinate c1, Coordinate c2)
		 
			if (c1.zoom == center.zoom)
			 
				if (c2.zoom == center.zoom)
				 
					# only compare squared distances… saves cpu
					  d1 = ( ) Math.pow(c1.column - center.column, 2) + ( ) Math.pow(c1.row - center.row, 2)
					  d2 = ( ) Math.pow(c2.column - center.column, 2) + ( ) Math.pow(c2.row - center.row, 2)
					return d1 < d2 ? -1 : d1 > d2 ? 1 : 0
				end
				else
				 
					return -1
				end
			end
			else if (c2.zoom == center.zoom)
			 
				return 1
			end
			else
			 
				  d1 = Math.abs(c1.zoom - center.zoom)
				  d2 = Math.abs(c2.zoom - center.zoom)
				return d1 < d2 ? -1 : d1 > d2 ? 1 : 0
			end
		end
	end

	  class ZoomComparator implements Comparator<Coordinate>
	 
		    compare(Coordinate c1, Coordinate c2)
		 
			return c1.zoom < c2.zoom ? -1 : c1.zoom > c2.zoom ? 1 : 0
		end
	end
end
