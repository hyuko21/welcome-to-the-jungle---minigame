class StartScreen
	def initialize
		@bg_night = Image.load_tiles("graphics/images/startscreen/wttj_night.png", 646, 480)
		@bg_afternoon = Image.load_tiles("graphics/images/startscreen/wttj_afternoon.png", 646, 480)
		@bg_raining = Image.load_tiles("graphics/images/startscreen/wttj_raining.png", 646, 480)
		@bg_day = Image.load_tiles("graphics/images/startscreen/wttj_day.png", 640, 480)
		@font = Font.new(60, :name => "graphics/font/#{GAME_FONT}")
		@start = Font.new(30, :name => "graphics/font/#{GAME_FONT}")
		@color = Color.new(0xff_000000)
		@reg = 120
		@flow = 0

		r = rand(3)
		if r == 0
			@current_bg = @bg_night
		elsif r == 1
			@current_bg = @bg_afternoon
		elsif r == 2
			@current_bg = @bg_raining
		else
			@current_bg = @bg_day
		end
	end

	def update
		if @reg == 278
			@flow = 1
		elsif @reg == 90
			@flow = 0
		end

		if @reg < 280 and @flow == 0
			@reg += 2
		else
			@reg -= 2
		end
		@color.alpha = @reg
		@color.red = @reg
		@color.green = @reg
		@color.blue = @reg-255
	end

	def draw
		frame = milliseconds / 80 % @current_bg.size
		@current_bg[frame].draw(0, 0, 0)
		@font.draw("Welcome to the Jungle", 35, 95, ZOrder::UI, 1, 1, 0x77_000000)
		@font.draw("Welcome to the Jungle", 25, 90, ZOrder::UI)
		draw_rect(70, 147.5, 525, 32.5, 0x88_000000, ZOrder::UI)
		@start.draw("Pressione a tecla [S] para iniciar o Jogo", 80, 150, ZOrder::UI, 1, 1, @color)
	end
end
