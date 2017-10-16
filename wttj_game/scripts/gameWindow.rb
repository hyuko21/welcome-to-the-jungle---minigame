class GameWindow < Window
	def initialize
		super WIDTH, HEIGHT, false
		self.caption = "Welcome to the Jungle"
		@start_music = Song.new("audio/wttj8bit.ogg")
		@playing_music = Song.new("audio/ttff8bit.ogg")
		@start_music.play
		@startScreen = StartScreen.new
		@mainScreen = true
		@charSelection = false
		@gameStarted = false
	end

	def update
		if @gameStarted
			@start_music.pause
			@playing_music.play
			@map.update
		elsif @charSelection
			@charScreen.update
		elsif @mainScreen
			@startScreen.update
		end
	end

	def draw
		if @gameStarted
			@map.draw
		elsif @charSelection
			@charScreen.draw
		elsif @mainScreen
			@startScreen.draw
		end
	end

	def button_down(id)
		if id == KbS and @mainScreen
			@mainScreen = false
			@charScreen = CharScreen.new
			@charSelection = true
		end
		if @charSelection
			@charScreen.button_down(id)
		end
		if @charSelection and id == KbReturn
			@charSelection = false
			@map = Map.new("data/Map000.map", false, 0, true, 71.0)
			@gameStarted = true
		end
		if @gameStarted
			@map.button_down(id)
		end
		if id == KbEscape
			close
		end
	end

	def button_up(id)
		if @gameStarted
			@map.button_up(id)
		end
	end
end
