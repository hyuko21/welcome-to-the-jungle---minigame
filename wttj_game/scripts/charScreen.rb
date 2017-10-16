class CharScreen
	def initialize
		@bg1 = Image.new("graphics/images/charscreen/jbg1.jpg", :tileable => true)
		@bg2 = Image.new("graphics/images/charscreen/jbg2.jpg", :tileable => true)
		@x1 = 0
		@x2 = @bg1.width-550
		@font = Font.new(60, :name => "graphics/font/#{GAME_FONT}")
		@block_bg = Image.new("graphics/images/charscreen/block_bg.png", false)
		@block_sel = Image.new("graphics/images/charscreen/block_sel.png", false)
		@block_sel_x = 108.5
		@can_right = 2
		@can_left = 0
	end

	def update
		@x1 -= 2
		if @x1 < -743 then @x1 = @bg2.width-550 end

		@x2 -= 2
		if @x2 < -743 then @x2 = @bg1.width-550 end

		if @block_sel_x == 108.5
			$kind = 1
		elsif @block_sel_x == 257.5
			$kind = 2
		else
			$kind = 3
		end
	end

	def draw
		@bg1.draw(@x1, 0, ZOrder::Background)
		@bg2.draw(@x2, 0, ZOrder::Background)
		@block_bg.draw(80, 180, 0)
		@block_sel.draw(@block_sel_x, 198.5, 0)
		@font.draw("Escolha seu Jungler", 65, 50, ZOrder::UI, 1, 1, 0xff_00bb00)
		@font.draw("[ENTER] CONFIRMAR ESCOLHA", 85, 420, ZOrder::UI, 0.7, 0.7, 0xff_ffff00)
	end

	def button_down(id)
		if id == KbRight and @can_right > 0
			@block_sel_x += 149
			@can_right -= 1
			@can_left += 1
		end
		if id == KbLeft and @can_left > 0
			@block_sel_x -= 149
			@can_left -= 1
			@can_right += 1
		end
	end
end
