class Player
	attr_reader :x, :y, :dir

	def initialize(map, kind, x, y)
		@map = map
		@kind = kind
		@x = x
		@y = y - 32
		@spawn_x = x
		@spawn_y = y

		#====== Behavior Sprites =======
		@idle = Image.load_tiles("graphics/sprites/char#{@kind}/walk/char#{@kind}_walk(1).png", 32, 32)
		@running = Image.load_tiles("graphics/sprites/char#{@kind}/run/char#{@kind}_run.png", 32, 32)
		@jumping = Image.load_tiles("graphics/sprites/char#{@kind}/jump/char#{@kind}_jump.png", 32, 32)
		@dying = Image.load_tiles("graphics/sprites/dying/blood64.png", 64, 64)
		#===============================

		#==== Attacking Sprites =====
		@punching = Image.load_tiles("graphics/sprites/char#{@kind}/punch/char#{@kind}_punch.png", 40, 32)
		@slashing = Image.load_tiles("graphics/sprites/char#{@kind}/slash/char#{@kind}_slash.png", 32, 32)
		#============================

		#==== Movement vars ====
		@dir = :right
		@vel_x = 1
		@moving = false
		@vel_y = 0
		@jumped = false
		@jumped_times = 0
		#=======================

		#==== Attack vars ====
		@attack = 0
		@attacking = false
		@has_punched = false
		@max_energy = 100
		@energy = @max_energy
		#=====================

		#==== Char Stats vars ====
		@life = 1
		@dead = false
		@death = @dying.size
		#=========================
	end

	def jump
		if !@map.no_ground?(@x, @y) or @jumped_times < 2
			@jumped_times += 1
			@jumped = true
			@vel_y = -20
		end
	end

	def is_jumping?
		@vel_y < 0
	end

	def reset_jump
		@vel_y = 0
	end

	def basic_attack
		if @jumped == false and @moving == false
			@attacking = true
			@attack = 3
		end
	end

	def ex_attack
		if @jumped == false and @moving == false and @energy >= 30 and @dead == false
			@attacking = true
			@attack = -4
			@energy -= 30
			true
		else
			false
		end
	end

	def reg_energy
		if @energy < 0
			@energy = 0
		end
		if @energy < @max_energy
			@energy += 0.1
		end
		@energy.to_i
	end

	def bitten
		@life = 0
	end

	def dead?
		@dead
	end

	def respawn
		@x = @spawn_x
		@y = @spawn_y
		@dead = false
	end

	def update(move_x)
		if move_x == 0 and @attacking == false
	      @current_sprite = @idle
	      @attacking = false
	      @moving = false
	      @jumped = false
	    elsif
	      @current_sprite = @running
	      @moving = true
	      @attacking = false
	    end
		if @map.no_ground?(@x, @y)
			@current_sprite = @jumping
		end
		if move_x == 0
			if @attack > 0
				@current_sprite = @punching
				@attack -= 0.5
				if @attack < 0
					@attack = 0
				end
			elsif @attack < 0
				@current_sprite = @slashing
				@attack += 0.5
				if @attack > 0
					@attack = 0
				end
			end
		end

		if @vel_y <= 20
			@vel_y += 1
		end

		if @map.need_fix?(@x, @y)
			@y -= 1
		end

	    if move_x > 0 and @dead == false
	      @dir = :right
	      move_x.times { @x += @vel_x }
	    elsif move_x < 0 and @dead == false
	      @dir = :left
	      (-move_x).times { @x -= @vel_x }
	    end

	    if @vel_y > 0
	      @vel_y.times { if @map.no_ground?(@x, @y) then @y += 0.3 end }
	    end
	    if @vel_y < 0 and @dead == false
	      (-@vel_y).times { @y -= 0.3 }
	    end

	    if !@map.no_ground?(@x, @y)
	    	@jumped_times = 0
	    	@jumped = false
  		else
  			@jumped = true
  		end

  		if @map.spiked?(@x, @y) or @life == 0
  			@dead = true
  			@attack = 0
  			if @death > 0
  				@current_sprite = @dying
  				@death -= 0.15
  			else
  				respawn
  				@death = @dying.size
  				@life = 1
  			end
  		end
  	end

	def draw(cam_x, cam_y)
		if @dir == :right
			if @current_sprite.size == @dying.size
	    		offset_x = -32
	    		offset_y = 40
	    	else
	      		offset_x = -16
	      		offset_y = 32
	   		end
	   		factor_x = 1
	    else
	    	if @current_sprite.size == @dying.size
	    		offset_x = 32
	    		offset_y = 40
	    	else
		      	offset_x = 16
		      	offset_y = 32
		  	end
		  	factor_x = -1
	    end

    	frame = milliseconds / 80 % @current_sprite.size
    	@current_sprite[frame].draw((@x + offset_x) - cam_x, (@y - offset_y) - cam_y, ZOrder::Player, factor_x)
	end
end
