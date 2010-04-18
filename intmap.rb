		
    @tile_width = 256
  	@tile_height = 256
  	@grid_padding = 1
  	
  	images = {}
		# !!! VERY IMPORTANT
		# (all the renderers apart from OpenGL will choke if you ask for smooth
		# scaling of image calls)
		no_smooth

		# translate and scale, from the middle
		push_matrix
  		translate(width / 2, height / 2)
  		scale(sc)
  		translate(tx, ty)

  		# find the bounds of the ur-tile in screen-space:
  		float minX = screenX(0, 0)
  		float minY = screenY(0, 0)
  		float maxX = screenX(@tile_width, @tile_height)
  		float maxY = screenY(@tile_width, @tile_height)

  		# what power of 2 are we at?
  		# 0 when scale is around 1, 1 when scale is around 2,
  		# 2 when scale is around 4, 3 when scale is around 8, etc.
  		zoom = [10, [1, (log(@sc)/log(2)).round].max].min
  		

  		# how many columns and rows of tiles at this zoom?
  		# (this is basically (int)sc, but let's derive from zoom to be sure
  		cols = 2**zoom)
  		rows = 2**zoom)

  		# find the biggest box the screen would fit in:, aligned with the map:
  		screenMinX = 0
  		screenMinY = 0
  		screenMaxX = width
  		screenMaxY = height
  		# TODO: align this, and fix the next bit to work with rotated maps

  		# find start and end columns
      @minCol = (cols * (screenMinX-minX) / (maxX-minX)).floor
      @maxCol = (cols * (screenMaxX-minX) / (maxX-minX)).ceil
      @minRow = (rows * (screenMinY-minY) / (maxY-minY)).floor
      @maxRow = (rows * (screenMaxY-minY) / (maxY-minY)).ceil
  		# pad a bit, for luck (well, because we might be zooming out between
  		# zoom levels)
  		@minCol -= grid_padding
  		@minRow -= grid_padding
  		@maxCol += grid_padding
  		@maxRow += grid_padding
  		# we don't wrap around the world yet, so:
      @minCol = constrain(@minCol, 0, cols)
      @maxCol = constrain(@maxCol, 0, cols)
      @minRow = constrain(@minRow, 0, rows)
      @maxRow = constrain(@maxRow, 0, rows)

  		# keep track of what we can see already:
  		visibleKeys = []

  		# grab coords for visible tiles
      for col in ( @minCol..@maxCol )
        for row in ( @minRow..@maxRow )
  				# keep this for later:
  				visibleKeys.push([col, row, zoom])
  				if (!images.has_key?([col, row, zoom])
  					# fetch it if we don't have it
  					#grabTile(coord)
  					# see if we have a parent coord for this tile?
  				end

  			end # rows
  		end # columns

  		# sort by zoom so we draw small zoom levels (big tiles) first:
  		visibleKeys.sort_by { |x| x[2] }

  		if (visibleKeys.size > 0)
  			previous = visibleKeys[0]
  			pushMatrix()
  			# correct the scale for this zoom level:
  			scale(1 / 2**previous[2]))
  			#for (int i = 0 i < visibleKeys.size() i++)
			  visibleKeys.each do |key|
  				#oord = (Coordinate) visibleKeys.get(i)
				
  				# Till: REVISIT This seems to be done for every coord, even though one would be sufficient.
  				# Even if the coord is of different zoom, the next one (with same as previous.zoom)
  				# won't use the outer matrix (from before for-loop), but the one from the i-1 coord.
  				if (key[2] != previous[2]
  					pop_matrix
  					push_matrix
  					# correct the scale for this zoom level:
  					scale(1 / 2**key[2])
  				end

  				if (images.has_key(key))
  					tile = (PImage) images.get(coord)
  					.image(tile, coord.column * @tile_width, coord.row * @tile_height, @tile_width, @tile_height)
					
  					if (recent_images.contains(tile))
					
  						recent_images.remove(tile)
  					end
  					recent_images.add(tile)
  				end
  			end
  			.popMatrix()
  		end

		.popMatrix()

		# stop fetching things we can't see:
		# (visibleKeys also has the parents and children, if needed, but that
		# shouldn't matter)
		queue.retainAll(visibleKeys)

		# sort what's left by distance from center:
		queueSorter.setCenter(new Coordinate((minRow + maxRow) / 2.0f, (minCol + maxCol) / 2.0f, zoom))
		Collections.sort(queue, queueSorter)

		# load up to 4 more things:
		processQueue()

		# clear some images away if we have too many...
		if (recent_images.size() > max_images_to_keep)
		
			recent_images.subList(0, recent_images.size() - max_images_to_keep).clear()
			images.values().retainAll(recent_images)
		end

		# restore smoothing, if needed
		if (smooth)
		
			.smooth()
		end
	end
	
	# INTERACTION
	public def mouseDragged()
	
		double dx = (double) (.mouseX - .pmouseX) / sc
		double dy = (double) (.mouseY - .pmouseY) / sc
		tx += dx
		ty += dy
	end
	
	# TILE LOADING
	public def processQueue()
	
		while (pending.size() < max_pending && queue.size() > 0)
		
			Coordinate coord = (Coordinate) queue.remove(0)
			TileLoader tileLoader = new TileLoader(coord)
			pending.put(coord, tileLoader)
			new Thread(tileLoader).start()
		end
	end
	
	/**
	 * for tile loader threads to load PImages
	 */
	public class TileLoader implements Runnable
	
		Coordinate coord

		TileLoader(Coordinate coord)
		
			this.coord = coord
		end

		public def run()
		
			String[] urls = provider.getTileUrls(coord)
			PImage img = .loadImage(urls[0], "unknown") # use unknown to let
															# loadImage decide
			if (img != null)
			
				for (int i = 1 i < urls.length i++)
				
					PImage img2 = .loadImage(urls[i], "unknown")
					if (img2 != null)
					
						img.blend(img2, 0, 0, img.width, img.height, 0, 0, img.width, img.height, BLEND)
					end
				end
			end
			tileDone(coord, img)
		end
	end
end

public class ZoomComparator implements Comparator<Coordinate>
	{
		public int compare(Coordinate c1, Coordinate c2)
		{
			return c1.zoom < c2.zoom ? -1 : c1.zoom > c2.zoom ? 1 : 0;
		}
	}
