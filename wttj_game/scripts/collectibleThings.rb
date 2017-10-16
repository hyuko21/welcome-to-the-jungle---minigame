class CollectibleThings
	attr_reader :x, :y

	def initialize(x, y, kind)
		@x = x
		@y = y
		@kind = kind
		@sprite = Image.load_tiles("graphics/sprites/#{@kind.to_s}.png", 16, 16)
	end

	def draw(cam_x, cam_y)
		frame = milliseconds / 120 % @sprite.size
		@sprite[frame].draw(@x - cam_x, @y - cam_y, ZOrder::Map)
	end
end