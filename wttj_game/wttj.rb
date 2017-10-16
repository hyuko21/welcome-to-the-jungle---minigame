$: << File.dirname(__FILE__)

require 'rubygems'
require 'gosu'
include Gosu
require 'scripts/gameWindow.rb'
require 'scripts/map.rb'
require 'scripts/player.rb'
require 'scripts/slash.rb'
require 'scripts/startScreen.rb'
require 'scripts/charScreen.rb'
require 'scripts/collectibleThings.rb'
require 'scripts/enemy.rb'

module ZOrder
	Background, Map, Player, Foreground, UI, Skin = *0..5
end

WIDTH, HEIGHT = 640, 480
GAME_FONT = "#44v2.ttf"
$window = GameWindow.new
$window.show
