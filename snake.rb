require 'ruby2d'

#snake static vars
set title: "Snake"
set background: "navy"
set width: 800, height: 600
set fps_cap: 20
TILE_SIZE=25
TILES_X= Window.width / TILE_SIZE
TILES_Y= Window.height / TILE_SIZE

class Snake
	#input from keyboard to class
	attr_writer :direction
	
	def initialize
		@positions = [[10, 10], [11, 10], [12, 10]]
		@direction = 'right'
		@growing = false
	end
	
	def draw
		@positions.each do |position|
			Square.new(x: position[0] * TILE_SIZE, y: position[1] * TILE_SIZE, size: TILE_SIZE - 1, color: 'white')
		end
	end
	
	def move
		if !@growing
			@positions.shift
		end
		
		case @direction
			when 'down'
				@positions.push([head[0], head[1] + 1])
			when 'up'
				@positions.push([head[0], head[1] - 1])
			when 'left'
				@positions.push([head[0] - 1, head[1]])
			when 'right'
				@positions.push([head[0] + 1, head[1]])
		end
		@growing = false
	end
	
	def next_move(x, y)
		[x % TILES_X, y % TILES_Y]	
	end
	
	def head
		@positions.last
	end
	
	def x
		head[0]
	end
	
	def y
		head[1]
	end
	
	def space_occuped_by_snake
		@positions
	end
	
	def grow
		@growing = true
	end
	
	def can_change_dir?(new_direction)
		case @direction
			when 'up' then new_direction != 'down'
			when 'down' then new_direction != 'up'
			when 'left' then new_direction != 'right'
			when 'right' then new_direction !=  'left'
		end
	end
	
	def hit_itself?
		@positions.uniq.length != @positions.length
	end
end

class Game
	def initialize(space_occuped_by_snake)
		@score = 0
		@ended = false
		loop do
			@apple_x = 1+rand(TILES_X-2)
			@apple_y = 1+rand(TILES_Y-2)
			if !space_occuped_by_snake.include?([@apple_x,@apple_y])
				break
			end
		end
		@borders = []
		for i in 0...TILES_Y
			@borders.push([0,i])
			@borders.push([TILES_X-1,i])
		end
		for i in 0...TILES_X
			@borders.push([i,0])
			@borders.push([i,TILES_Y-1])
		end
	end
	
	def draw
		unless game_over?
			@borders.each do |position|
				Square.new(x: position[0] * TILE_SIZE, y: position[1] * TILE_SIZE, size: TILE_SIZE, color: 'black')
			end
			Square.new(x: @apple_x * TILE_SIZE, y: @apple_y * TILE_SIZE,size: TILE_SIZE, color: 'red')
			Text.new("Score:  #{@score}", color: "white", x: 0, y: 0, size: 25)
		end
		if game_over?
			Text.new("Game OVER!", color: "white", x: 300, y: (Window.height / 2) - TILE_SIZE / 2, size: 25)
			Text.new("You score:  #{@score} points.", color: "white", x: 265, y: (Window.height / 2) + TILE_SIZE / 2, size: 25)
			Text.new("Press R to restart or X to exit", color: "white", x: 0, y: 575, size: 25)
		end
	end
	
	def snake_hit_apple?(x, y)
		@apple_x == x && @apple_y == y
	end
	
	def snake_hit_border?(x, y)
		@borders.include?([x,y])
			
	end
	
	def create_new_apple(space_occuped_by_snake)
		@score += 1
		loop do
			@apple_x = 1+rand(TILES_X-2)
			@apple_y = 1+rand(TILES_Y-2)
			if !space_occuped_by_snake.include?([@apple_x,@apple_y])
				break
			end
		end 
	end
	
	def end
		@ended = true
	end
	
	def game_over?
		@ended
	end
end


snake = Snake.new
game = Game.new(snake.space_occuped_by_snake)

update do
	clear
	
	unless game.game_over?
		snake.move
		snake.draw
	end
	
	game.draw
	
	if game.snake_hit_apple?(snake.x, snake.y)
		snake.grow
		game.create_new_apple(snake.space_occuped_by_snake)
	end
	
	if snake.hit_itself? or game.snake_hit_border?(snake.x, snake.y)
		game.end
	end
end

on :key_down do |event|
	if event.key == 'w' or event.key == 'up'
		if snake.can_change_dir?('up')
			snake.direction = 'up'
		end
	end
	if event.key == 's' or event.key == 'down'
		if snake.can_change_dir?('down')
			snake.direction = 'down'
		end
	end
	if event.key == 'a' or event.key == 'left'
		if snake.can_change_dir?('left')
			snake.direction = 'left'
		end
	end
	if event.key == 'd' or event.key == 'right'
		if snake.can_change_dir?('right')
			snake.direction = 'right'
		end
	end
	if event.key == 'r' and game.game_over?
		snake = Snake.new
		game = Game.new(snake.space_occuped_by_snake)
	end
	if event.key == 'x'
		exit 0
	end
end

show