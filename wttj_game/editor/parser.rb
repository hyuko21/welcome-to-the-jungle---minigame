class Parser
	def parse_data(width, height)
		level = []
		layer0_raw = File.read('editor/layer0.txt')
		layer1_raw = File.read('editor/layer1.txt')

		layer0_data = layer0_raw.scan(/\d+/)
		layer1_data = layer1_raw.scan(/\d+/)

		layer0_data.collect! &:to_i
		layer1_data.collect! &:to_i

		level[0] = []
		level[1] = []
		for y in 0...height
			level[0][y] = []
			level[1][y] = []			
			for x in 0...width
				# Layer 0
				level[0][y][x] = layer0_data[y*width + x] - 1
				level[0][y][x] = 0 if level[0][y][x] > 999
				level[0][y][x] = 0 if level[0][y][x] < 0

				# Layer 1
				level[1][y][x] = layer1_data[y*width + x] - 1
				level[1][y][x] = 0 if level[0][y][x] > 999
				level[1][y][x] = 0 if level[0][y][x] < 0
			end
		end
		return level
	end
end