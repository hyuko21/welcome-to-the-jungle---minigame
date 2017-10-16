class EditorWindow < Window
	def initialize
		super 1024, 768, false
		self.caption = "Map Editor"
		$map = MapEditor.new
	end

	def update
		$map.update
	end

	def draw
		$map.draw
	end

	def needs_cursor?
		return true
	end

	def button_down(id)
		$map.button_down(id)
	end

	def button_up(id)
		$map.button_up(id)
	end

end