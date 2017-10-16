class Map
	def initialize(filename, status, id, need, time)
		file = File.open(filename)
		@used_tileset = Marshal.load(file)
		@level = Marshal.load(file)
		@object = Marshal.load(file)
		file.close

		@actual_level = filename
		@level_id = id
		@level_done = status
		@before_begin = need
		@timeS_over = false
		@the_end = false
		@time = time
		@seconds = @time%60
		if @time/60 >= 1
			@minutes = (@time/60).floor
		else
			@minutes = 0
		end
		@tileset = Image.load_tiles("graphics/tiles/#{@used_tileset}", 16, 16, :tileable => true)
		@player = nil
		@slash = []
		@entitie = []
		@enemy = []
		load_entities

		@color = Color.new(255, 255, 255, 255)
		@enable_color = Color.new(50, 255, 255, 255)
		@energy_sprite = Image.new("graphics/energy.png", false)
		@clock_sprite = Image.new("graphics/timer.png", false)
		@treasure_sprite = Image.new("graphics/treasure_chest.png", false)
		@rem_objects = @entitie.size
		@enemy_count = 0

		@delay = 5.0

		@bg = Image.new("graphics/images/map/jungle_bg.jpg", false)
		@fg = Image.new("graphics/images/map/jungle_fg.png", false)
		@font = Font.new(35, :name => "graphics/font/#{GAME_FONT}")
		@cam_x = @cam_y = 0
	end

	def load_entities
		for i in 0...@object.size
			case @object[i][0]
			when :player
				@player = Player.new(self, $kind, @object[i][1], @object[i][2])
			when :gem10, :gem20, :gem35, :gem65, :gem100, :gem125, :coinsilver, :coingold
				@entitie << CollectibleThings.new(@object[i][1], @object[i][2], @object[i][0])
			when :snake
				@enemy << Enemy.new(self, @object[i][1], @object[i][2])
			end
		end
	end

	def no_ground?(x, y)
		tile_x = (x/16).to_i
		tile_y = (y/16).to_i
		@level[0][tile_y][tile_x] == 0
	end

	def wall?(x, y, direction)
		tile_x = (x/16).to_i
		tile_y = (y/16).to_i
		if direction == :left
			@level[0][tile_y-1][tile_x-1] != 0
		elsif direction == :right
			@level[0][tile_y-1][tile_x+1] != 0
		end
	end

	def solid_overhead?(x, y)
		tile_x = (x/16).to_i
		tile_y = (y/16).to_i
		@level[0][tile_y-2][tile_x] != 0
	end

	def spiked?(x, y)
		tile_x = (x/16).to_i
		tile_y = (y/16).to_i
		@level[0][tile_y][tile_x] == 15 or @level[0][tile_y][tile_x] == 16 or @level[0][tile_y][tile_x] == 72
	end

	def in_hidden_entrance
		tile_x = (@player.x/16).to_i
		tile_y = (@player.y/16).to_i
		if @level[1] != nil
			@level[1][tile_y-1][tile_x] > 0 ? true : false
		end
	end

	def need_fix?(x, y)
		tile_x = (x/16).to_i
		tile_y = (y/16).to_i
		@level[0][tile_y][tile_x] == 4 or @level[0][tile_y][tile_x] == 2 or @level[0][tile_y][tile_y] == 31
	end

	def update
		unless @before_begin or @level_done
			if @seconds > 0.0
				@seconds -= 1.0/60.0
			elsif @minutes > 0
				@seconds = 60.0
				@minutes -= 1
			else
				@timeS_over = true
			end
			if @delay > 0.0
				@delay -= 1.0/60
			else
				@enable_color.alpha = 255
			end
		end

		if @minutes == 0 and @seconds <= 10.0
			@color.red = 200
			@color.green = 0
			@color.blue = 0
		end

		if @seconds <= 10.0
			@zero = "0"
		else
			@zero = nil
		end

		move_x = 0
		if !@timeS_over and !@before_begin and !@level_done
		    move_x -= 5 if button_down? KbLeft and !wall?(@player.x, @player.y, :left)
		    move_x += 5 if button_down? KbRight and !wall?(@player.x, @player.y, :right)
		end
	    @player.update(move_x)

	    if @player.is_jumping?
	    	if solid_overhead?(@player.x, @player.y)
	    		@player.reset_jump
	    	end
	    end

	    @slash.each { |slash| slash.move }

	    @slash.reject! { |slash| slash.max_range? }

    	@enemy.each do |enem|
    		enem.update
	    	dist = @player.x - enem.x
				d = dist.abs
				y_enem = @player.y.to_i - enem.y.to_i
	    	if d < 128 and !@player.dead? and y_enem >= -8 and y_enem <= 8
	    		enem.in_chase
					dist < 0 ? enem.dir = :left : enem.dir = :right
	    	else
	    		enem.out_chase
	    	end

	    	dist = distance(@player.x, @player.y, enem.x, enem.y)
	    	if dist < 32 and @has_punched
	    		enem.struck
	    	elsif dist < 8 and enem.life > 0
	    		@player.bitten
	    	end
	    	@slash.each do |slash|
	    		dist = distance(slash.x, slash.y, enem.x, enem.y - 16)
	    		if dist < 32
	    			enem.struck
	    		end
	    	end
	   		if enem.dead?
	    		@enemy.delete(enem)
	    		@enemy_count += 1
	    	end
	    end

	    @entitie.reject! do |en|
	    	dist = distance(@player.x, @player.y, en.x, en.y)
	    	if dist < 32
	    		@rem_objects -= 1
	    	end
	    end

	    if @rem_objects == 0 and @time > 0.0 and !@level_done
			@level_done = true
			@level_id += 1
		end

		@cam_x = [[@player.x - WIDTH / 2, 0].max, @level[0][0].size * 16 - WIDTH].min
		@cam_y = [[@player.y - HEIGHT / 2, -30].max, @level[0].size * 16 + 55 - HEIGHT].min
	end

	def draw
		@bg.draw(0, -@cam_y, ZOrder::Background)
		@fg.draw(0, 0, ZOrder::Foreground)
		#HUD
		draw_rect(0, 0, WIDTH, 30, 0xaa_000000, ZOrder::UI)
		@font.draw("[R] REINICIAR", 250, 3.5, ZOrder::UI, 0.8, 0.8, @enable_color)
		draw_rect(0, 425, WIDTH, 55, 0xaa_000000, ZOrder::UI)
		#ENERGY
		@energy_sprite.draw(55, 430, ZOrder::UI)
		@font.draw("#{@player.reg_energy}", 115, 430, ZOrder::UI, 1.3, 1.3, 0xff_009900)
		#TIME
		@clock_sprite.draw(235, 430, ZOrder::UI)
		@font.draw("#{@minutes} : #{@zero}#{@seconds.to_i}", 285, 430, ZOrder::UI, 1.3, 1.3, @color)
		#COLLECTIBLE THINGS
		@treasure_sprite.draw(460, 430, ZOrder::UI)
		@font.draw("#{@rem_objects}", 520, 430, ZOrder::UI, 1.3, 1.3, 0xff_ffff00)
		#MAP
		for l in 0...@level.size
			for y in 0...@level[l].size
				for x in 0...@level[l][y].size
					@tileset[@level[l][y][x]].draw((x*16)-@cam_x, (y*16)-@cam_y, l+1)
				end
			end
		end

		@entitie.each { |en| en.draw(@cam_x, @cam_y) }

		@enemy.each { |enem| enem.draw(@cam_x, @cam_y) }

		@player.draw(@cam_x, @cam_y)

		@slash.each { |slash| slash.draw(@cam_x, @cam_y) }

		if @before_begin or @level_done or @timeS_over
			draw_rect(0, 0, WIDTH, HEIGHT, 0xbb_000000, ZOrder::Skin)
			if @before_begin
				@font.draw("ANTES DE COMEÇAR...", 50, 30, ZOrder::Skin, 1.7, 1.7, 0xff_ffff00)
				@font.draw("VOCÊ TERÁ #{(@time-1.0).to_i} SEGUNDOS PARA", 70, 100, ZOrder::Skin, 1, 1)
				@font.draw("COLETAR TODOS OS #{@rem_objects} OBJETOS", 70, 140, ZOrder::Skin, 1, 1)
				@font.draw("QUE ESTÃO DISPOSTOS NESTA CENA.", 70, 180, ZOrder::Skin, 1, 1)
				@font.draw("[ESPAÇO] QUANDO ESTIVER PRONTO", 80, 440, ZOrder::Skin, 1, 1, 0xff_ffff00)
				if @level_id == 0
					@font.draw("INSTRUÇÕES BÁSICAS:", 50, 235, ZOrder::Skin, 1.2, 1.2, 0xff_ffff00)
					@font.draw("[SETAS] MOVIMENTAÇÃO", 70, 280, ZOrder::Skin, 0.92, 0.92)
					@font.draw("[Z] ATAQUE BÁSICO (CURTA DISTÂNCIA)", 70, 320, ZOrder::Skin, 0.92, 0.92, 0xff_00ffff)
					@font.draw("[X] ATAQUE ESPECIAL (LONGA DISTÂNCIA)", 70, 360, ZOrder::Skin, 0.92, 0.92, 0xff_00ff00)
					@font.draw("(CUSTO DE ENERGIA = 30)", 130, 390, ZOrder::Skin, 0.92, 0.92, 0xff_00ff00)
				end
			end
			if @level_done
				@font.draw("Parabéns!", 175, 50, ZOrder::Skin, 1.9, 1.9, 0xff_ffff00)
				@font.draw("Nível Concluído!", 120, 120, ZOrder::Skin, 1.6, 1.6, 0xff_00dd00)
				@font.draw("TEMPO RESTANTE: %.1f" % @seconds, 125, 200, ZOrder::Skin, 1.2, 1.2)
				@font.draw("INIMIGOS ELIMINADOS: #{@enemy_count}", 110, 250, ZOrder::Skin, 1.2, 1.2)
				@font.draw("[S] PROSSEGUIR AO PRÓXIMO NÍVEL", 70, 435, ZOrder::Skin, 1.02, 1.02, 0xff_ffff00)
			end
			if @timeS_over
				@font.draw("TEMPO ESGOTADO!", 80, 50, ZOrder::Skin, 1.85, 1.85, 0xff_ffff00)
				@font.draw("OBJETOS RESTANTES: #{@rem_objects}", 115, 180, ZOrder::Skin, 1.25, 1.25)
				@font.draw("INIMIGOS ELIMINADOS: #{@enemy_count}", 110, 230, ZOrder::Skin, 1.25, 1.25)
				@font.draw("[R] REINICIAR O NÍVEL", 112.5, 350, ZOrder::Skin, 1.4, 1.4, 0xff_ffff00)
				@font.draw("[ESC] FECHAR O JOGO", 115, 410, ZOrder::Skin, 1.4, 1.4, 0xff_ff0000)
			end
		end
		if @the_end
			draw_rect(0, 0, WIDTH, HEIGHT, 0xff_000000, ZOrder::Skin)
			@font.draw("FIM DE JOGO", 140, 50, ZOrder::Skin, 2.1, 2.1, 0xff_ff00ff)
			@font.draw("Parabéns! Você concluiu", 85, 160, ZOrder::Skin, 1.3, 1.3)
			@font.draw("todas as fases deste", 85, 200, ZOrder::Skin, 1.3, 1.3)
			@font.draw("jogo.", 85, 240, ZOrder::Skin, 1.3, 1.3)
			@font.draw("JOGUE SEMPRE =)", 95, 340, ZOrder::Skin, 1.9, 1.9, 0xff_00dd00)
			@font.draw("[A] Começar tudo de novo", 85, 425, ZOrder::Skin, 1.2, 1.2, 0xff_ffff00)
		end
	end

	def button_down(id)
		if @before_begin and id == KbSpace
			@before_begin = false
		end

		unless @before_begin or @level_done
			if !@timeS_over
				if id == KbUp
					@player.jump
				end
				if id == KbZ
					@player.basic_attack
					@has_punched = true
				elsif id == KbX
					if @player.ex_attack
						@slash.push(Slash.new(@player))
						@slashed = true
					end
				end
			end
		end

		if @level_id == 0
			time = 71.0
		elsif @level_id == 1
			time = 101.0
		elsif @level_id == 2
			time = 111.0
		elsif @level_id == 3
			time = 101.0
		elsif @level_id == 4
			time = 96.0
		end
		if id == KbR
			if @timeS_over
				initialize(@actual_level, @level_done, @level_id, false, time)
			elsif !@level_done and !@before_begin and @delay <= 0.0;
				initialize(@actual_level, @level_done, @level_id, false, time)
			end
		elsif @level_done and id == KbS
			@level_done = false
			if @level_id <= 4
				initialize("data/Map00#{@level_id}.map", @level_done, @level_id, true, time)
			else
				@the_end = true
			end
		end
		if @the_end and id == KbA
			@the_end = false
			initialize("data/Map000.map", false, 0, true, 71.0)
		end
	end

	def button_up(id)
		if id == KbZ
			@has_punched = false
		elsif id == KbX
			@slashed = false
		end
	end
end
