class Slash
  attr_reader :x, :y

  def initialize(player)
    @x, @y = player.x, player.y - 32
    @start_pos = player.x
    @dir = player.dir

    @sprite = Image.load_tiles("graphics/sprites/swoosh.png", 32, 32)
  end

  def move
    if @dir == :right
      @x += 5
      @factor_x = 1
      @max_range = @start_pos + 200*@factor_x
    else
      @x -= 5
      @factor_x = -1
      @max_range = @start_pos + 200*@factor_x
    end
  end

  def max_range?
    if @factor_x > 0
      @x > @max_range
    else
      @x < @max_range
    end
  end

  def draw(cam_x, cam_y)
    frame = milliseconds / 100 % @sprite.size
    @sprite[frame].draw(@x - cam_x, @y - cam_y, ZOrder::Player, @factor_x, 1)
  end
end
