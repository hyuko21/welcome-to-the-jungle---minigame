class Enemy
	attr_reader :x, :y, :life
	attr_writer :dir

	def initialize(map, x, y)
		@map = map
		@x = x
		@y = y
		@snake = Image.load_tiles("graphics/sprites/snake/snake.png", 32, 32)
		@dying = Image.load_tiles("graphics/sprites/dying/blood32.png", 32, 32)
		@color = Color.new(255, 0, 255, 255)

		@dir = :right
		@vel_y = 0
		@vel_x = 0.5
		@can_move = true

		@life = 1
		@dead = false
		@death = @dying.size
	end

	def dead?
		@dead
	end

	def struck
		@life = 0
	end

	def in_chase
		@vel_x = 1.5
	end

	def out_chase
		@vel_x = 0.5
	end

	def update
		if @can_move
			@current_sprite = @snake

			if @dir == :right
				@x += @vel_x
			else
				@x -= @vel_x
			end
		end

		if @vel_y < 5
			@vel_y += 1
		end

		if @vel_y > 0 and @map.no_ground?(@x, @y)
			@vel_y.times { @y += 1 }
		end

		if (@map.wall?(@x, @y, @dir) or @map.no_ground?(@x+16, @y)) and @dir == :right
			@dir = :left
		elsif (@map.wall?(@x, @y, @dir) or @map.no_ground?(@x-16, @y)) and @dir == :left
			@dir = :right
		end

		if @life == 0
			if @death > 0
				@can_move = false
				@current_sprite = @dying
				@death -= 0.3
			else
				@dead = true
			end
		end
	end

	def draw(cam_x, cam_y)
		if @dir == :right
			offset_x = -16
			factor_x = 1
		else
			offset_x = 16
			factor_x = -1
		end
		if @current_sprite.size == @dying.size
			offset_y = 20
			@color.red = 255
		else
			offset_y = 32
			@color.red = 0
		end

		frame = milliseconds / (150/@vel_x) % @current_sprite.size
		@current_sprite[frame].draw((@x + offset_x) - cam_x, (@y - offset_y) - cam_y, ZOrder::Map, factor_x, 1, @color)
	end
end
