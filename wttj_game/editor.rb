$: << File.dirname(__FILE__)

require 'gosu'
require 'rubygems'
include Gosu

require 'editor/editorWindow.rb'
require 'editor/mapEditor.rb'
require 'editor/parser.rb'

$window = EditorWindow.new
$window.show