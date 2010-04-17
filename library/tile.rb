class Tile
  
  include Processing::Proxy

  def initialize(x, y, z, path)
    @x, @y, @z, @path = x*256, y*256, z.to_s, path
    #@img = load_image("data/x72y54z7.png")
    #puts @img
    @img = load_image( "../data/tiles/"<<@z<<"/"<<path )
  end
  
  def render
    #make_shape
    image(@img, @x, @y)
  end
  
  def make_shape
    begin_shape
       texture(@img)
       vertex(@x, @y, 0, 0)
       vertex(@x+256, @y, 256, 0)
       vertex(@x+256, @y+256, 256, 256)
       vertex(@x, @y+256, 0, 256)
     end_shape
  end
  
end