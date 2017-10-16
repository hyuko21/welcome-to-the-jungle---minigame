class MapEditor
	def initialize
		@bg = Image.new("editor/editor.png", false)
		width = 60
		height = 45
		if FileTest.exists?("editor/layer0.txt") or FileTest.exists?("editor/layer1.txt") then
			parser = Parser.new
			@level = parser.parse_data(width, height)
		else
			@level = []
			for layer in 0...2
				@level[layer] = []
				for y in 0...height
					@level[layer][y] = []
					for x in 0...width
						@level[layer][y][x] = 0
					end
				end
			end
		end		
		# Loading up tileset graphic
		@used_tileset = "area02_level_tiles.png"
		@tileset = Image.load_tiles("graphics/tiles/#{@used_tileset}", 16, 16, :tileable => true)
		# Selection mark: 16
		@sel_16 = Image.new("editor/sel16.png", false)
		@sel_16_x = 16
		@sel_16_y = 112
		@sel_32 = Image.new("editor/sel32.png", false)
		@sel_32_x = 672
		@sel_32_y = 112
		# Selected tile index
		@selected_tile = 0
		# Current layer
		@current_layer = 0
		# Grid
		@grid = Image.new("editor/grid.png", false)
		# Offsets
		@offset_x = 0
		@offset_y = 0
		# Ctrlheld
		@ctrl_held = false
		# Object placement
		@objects = []
		@player_graphic = Image.load_tiles("graphics/sprites/char2/run/char2_run.png", 32, 32)
		@enemy_graphic = Image.load_tiles("graphics/sprites/snake/snake.png", 32, 32)
		@gem10_graphic = Image.load_tiles("graphics/sprites/gem10.png", 16, 16)
		@gem20_graphic = Image.load_tiles("graphics/sprites/gem20.png", 16, 16)
		@gem35_graphic = Image.load_tiles("graphics/sprites/gem35.png", 16, 16)
		@gem65_graphic = Image.load_tiles("graphics/sprites/gem65.png", 16, 16)
		@gem100_graphic = Image.load_tiles("graphics/sprites/gem100.png", 16, 16)
		@gem125_graphic = Image.load_tiles("graphics/sprites/gem125.png", 16, 16)
		@coinsilver_graphic = Image.load_tiles("graphics/sprites/coinsilver.png", 16, 16)
		@coingold_graphic = Image.load_tiles("graphics/sprites/coingold.png", 16, 16)
		@active_mode = :map
		@object_held = nil
	end
	
	def update
		if button_down? MsLeft and $window.mouse_x.between?(368, 1008) and $window.mouse_y.between?(160, 640) then
			place_tile($window.mouse_x, $window.mouse_y)
		end
	end

	def click
		if $window.mouse_x.between?(16, 336) and $window.mouse_y.between?(112, 304) then
			select_tile($window.mouse_x, $window.mouse_y)
		elsif $window.mouse_x.between?(368, 1008) and $window.mouse_y.between?(160, 640) then
			if @active_mode == :map then
				place_tile($window.mouse_x, $window.mouse_y)
			elsif @active_mode == :objects then
				place_object($window.mouse_x, $window.mouse_y)
			end
		elsif $window.mouse_x.between?(672,704) and $window.mouse_y.between?(112,144) then
			@current_layer = 0
			@sel_32_x = 672
		elsif $window.mouse_x.between?(720,752) and $window.mouse_y.between?(112,144) then
			@current_layer = 1
			@sel_32_x = 720
		#=========
		elsif $window.mouse_x.between?(32, 64) and $window.mouse_y.between?(352, 384) then
			select_object(:player)
		elsif $window.mouse_x.between?(32, 64) and $window.mouse_y.between?(416, 448) then
			select_object(:snake)
		elsif $window.mouse_x.between?(208, 224) and $window.mouse_y.between?(352, 368) then
			select_object(:gem10)
		elsif $window.mouse_x.between?(240, 256) and $window.mouse_y.between?(352, 368) then
			select_object(:gem20)
		elsif $window.mouse_x.between?(272, 288) and $window.mouse_y.between?(352, 368) then
			select_object(:gem35)
		elsif $window.mouse_x.between?(208, 224) and $window.mouse_y.between?(384, 400) then
			select_object(:gem65)
		elsif $window.mouse_x.between?(240, 256) and $window.mouse_y.between?(384, 400) then
			select_object(:gem100)
		elsif $window.mouse_x.between?(272, 288) and $window.mouse_y.between?(384, 400) then
			select_object(:gem125)
		elsif $window.mouse_x.between?(128, 144) and $window.mouse_y.between?(432, 448) then
			select_object(:coinsilver)
		elsif $window.mouse_x.between?(160, 176) and $window.mouse_y.between?(432, 448) then
			select_object(:coingold)
		#==========
		elsif $window.mouse_x.between?(560, 592) and $window.mouse_y.between?(112, 144) then
			save
		end
	end

	def save
		f = File.new("Map000.map", "w+")
		Marshal.dump(@used_tileset, f)
		Marshal.dump(@level, f)
		Marshal.dump(@objects, f)
		f.close
	end

	def place_object(x, y)		
		if @object_held == :player then
			for i in 0...@objects.size
				if @objects[i][0] == :player
					@objects.delete_at(i)
				end
			end
		end
		rx = x + (@offset_x*16) - 368
		ry = y + (@offset_y*16) - 160
		@objects << [@object_held, rx, ry]
		if @object_held == :player then
			@object_held = nil
		end
	end

	def select_object(object)
		@object_held = object
		@active_mode = :objects
		@sel_32_x = 768
	end

	def place_tile(x, y)
		tx = ((x - 368) / 16).floor
		ty = ((y - 160) / 16).floor
		@level[@current_layer][ty + @offset_y][tx + @offset_x] = @select_tile
	end

	def select_tile(x, y)
		@active_mode = :map
		tx = ((x - 16) / 16).floor
		ty = ((y - 112) / 16).floor
		i = tx + (ty*20)
		@sel_16_x = (tx * 16) + 16
		@sel_16_y = (ty * 16) + 112
		@select_tile = i
	end

	def increase_offset
		if @ctrl_held
			@offset_x += 1 if (@offset_x < @level[0][0].size - 40)
		else
			@offset_y += 1 if (@offset_y < @level[0].size - 30)
		end
	end

	def decrease_offset
		if @ctrl_held
			@offset_x -= 1 if @offset_x > 0
		else
			@offset_y -= 1 if @offset_y > 0
		end
	end

	def draw
		@bg.draw(0,0,0)
		# Drawing map
		for l in 0...@level.size
			for y in 0...@level[l].size
				for x in 0...@level[l][y].size
					if x < 40 and y < 30 then
						tx = 368 + (x*16)	
						ty = 160 + (y*16)
						i = @level[l][y + @offset_y][x + @offset_x]
						if l == @current_layer then
							@tileset[i].draw(tx,ty,1+l) if i != 0 and i != nil
						else
							@tileset[i].draw(tx,ty,1+l,1.0,1.0,Color.new(160,255,255,255)) if i != 0 and i != nil
						end
					end
				end
			end
		end
		# Drawing tileset graphics
		for i in 0...@tileset.size
			tx = 16 + ((i%20)*16)
			ty = 112 + ((i/20)*16)
			@tileset[i].draw(tx,ty,1)
		end
		# Drawing tile selection
		@sel_16.draw(@sel_16_x, @sel_16_y, 5)
		@sel_32.draw(@sel_32_x, @sel_32_y, 5)
		# Grid
		@grid.draw(368,160,5)
		# Player object
		frame = milliseconds / 150 % @player_graphic.size
		@player_graphic[frame].draw(32, 352, 1)
		@enemy_graphic[frame].draw(32, 416, 1)
		frame = milliseconds / 150 % @gem10_graphic.size
		@gem10_graphic[frame].draw(208, 352, 1)
		@gem20_graphic[frame].draw(240,352, 1)
		@gem35_graphic[frame].draw(272,352, 1)
		@gem65_graphic[frame].draw(208,384, 1)
		@gem100_graphic[frame].draw(240,384, 1)
		@gem125_graphic[frame].draw(272,384, 1)
		frame = milliseconds / 150 % @coinsilver_graphic.size
		@coinsilver_graphic[frame].draw(128,432,1)
		@coingold_graphic[frame].draw(160,432,1)

		# Drawing all objects on map
		for i in 0...@objects.size
			case @objects[i][0]
				when :player
					frame = milliseconds / 150 % @player_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@player_graphic[frame].draw(rx,ry,6)
				when :snake
					frame = milliseconds / 150 % @enemy_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@enemy_graphic[frame].draw(rx,ry,6)
				when :gem10
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem10_graphic[frame].draw(rx,ry,6)
				when :gem20
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem20_graphic[frame].draw(rx,ry,6)
				when :gem35
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem35_graphic[frame].draw(rx,ry,6)
				when :gem65
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem65_graphic[frame].draw(rx,ry,6)
				when :gem100
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem100_graphic[frame].draw(rx,ry,6)
				when :gem125
					frame = milliseconds / 150 % @gem10_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@gem125_graphic[frame].draw(rx,ry,6)
				when :coinsilver
					frame = milliseconds / 150 % @coinsilver_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@coinsilver_graphic[frame].draw(rx,ry,6)
				when :coingold
					frame = milliseconds / 150 % @coingold_graphic.size
					rx = @objects[i][1] - (@offset_x * 16) + 368
					ry = @objects[i][2] - (@offset_y * 16) + 160
					@coingold_graphic[frame].draw(rx,ry,6)
			end
		end

		# Object info
		case @object_held
			when nil

			when :player
				@player_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :snake
				@enemy_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem10
				@gem10_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem20
				@gem20_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem35
				@gem35_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem65
				@gem65_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem100
				@gem100_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :gem125
				@gem125_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :coinsilver
				@coinsilver_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
			when :coingold
				@coingold_graphic[0].draw($window.mouse_x, $window.mouse_y,10)
		end	
	end

	def button_down(id)
		if id == MsLeft then
			click
		end
		if id == MsWheelDown then
			increase_offset
		end
		if id == MsWheelUp then
			decrease_offset
		end
		if id == KbLeftControl then
			@ctrl_held = true
		end
		if id == KbUp then
			decrease_offset
		end
		if id == KbDown then
			increase_offset
		end
	end

	def button_up(id)
		if id == KbLeftControl then
			@ctrl_held = false
		end
	end

end
