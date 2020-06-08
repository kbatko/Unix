import pygame
import time
import random
import os

pygame.font.init()

WIDTH, HEIGHT = 750, 750
WINDOW = pygame.display.set_mode((WIDTH,HEIGHT))
pygame.display.set_caption("Space Shooter")


#load assets
RED_SPACE_SHIP  = pygame.image.load(os.path.join("assets","pixel_ship_red_small.png"))
BLUE_SPACE_SHIP  = pygame.image.load(os.path.join("assets","pixel_ship_blue_small.png"))
GREEN_SPACE_SHIP  = pygame.image.load(os.path.join("assets","pixel_ship_green_small.png"))
YEALOW_SPACE_SHIP  = pygame.image.load(os.path.join("assets","pixel_ship_yellow.png"))
RED_LASER =  pygame.image.load(os.path.join("assets","pixel_laser_red.png"))
BLUE_LASER =  pygame.image.load(os.path.join("assets","pixel_laser_blue.png"))
GREEN_LASER =  pygame.image.load(os.path.join("assets","pixel_laser_green.png"))
YEALOW_LASER =  pygame.image.load(os.path.join("assets","pixel_laser_yellow.png"))
BACKGROUND = pygame.transform.scale(pygame.image.load(os.path.join("assets","background-black.png")), (WIDTH, HEIGHT))


class Laser:
	def __init__(self, x, y, img):
		self.x = x
		self.y = y
		self.img = img
		self.mask = pygame.mask.from_surface(self.img)

	def draw(self, window):
		window.blit(self.img, (self.x, self.y))

	def move(self, velocity):
		self.y += velocity

	def off_screen(self, height):
		return not (self.y <= height and self.y >= 0)

	def collision(self, obj):
		return collide(self, obj)

class Ship:
	COOLDOWN = 30

	def __init__(self, x, y, health=100):
		self.x = x
		self.y = y
		self.health = health
		self.ship_img = None
		self.laser_img = None
		self.lasers = []
		self.cool_down_counter = 0

	def draw(self, window):
		window.blit(self.ship_img, (self.x, self.y))
		for laser in self.lasers:
			laser.draw(window)

	def get_width(self):
		return self.ship_img.get_width()

	def get_height(self):
		return self.ship_img.get_height()
	
	# check if not shooting too fast
	def cooldown(self):
		if self.cool_down_counter >= self.COOLDOWN:
			self.cool_down_counter = 0
		elif self.cool_down_counter > 0:
			self.cool_down_counter += 1

	# initiate laser
	def shoot(self):
		if self.cool_down_counter == 0:
			laser = Laser(self.x, self.y, self.laser_img)
			self.lasers.append(laser)
			self.cool_down_counter = 1

	# move lasers and check collision
	def move_lasers(self, velocity, obj):
		self.cooldown()
		for laser in self.lasers: 
			laser.move(velocity)
			if laser.off_screen(HEIGHT):
				self.lasers.remove(laser)
			elif laser.collision(obj):
				obj.health -= 10
				self.lasers.remove(laser)

class Player(Ship):
	def __init__(self, x, y, health=100):
		super().__init__(x, y, health)
		self.ship_img = YEALOW_SPACE_SHIP
		self.laser_img = YEALOW_LASER
		self.mask = pygame.mask.from_surface(self.ship_img)
		self.max_health = health

	# move lasers and check collision
	def move_lasers(self, velocity, objs):
		self.cooldown()
		for laser in self.lasers: 
			laser.move(velocity)
			if laser.off_screen(HEIGHT):
				self.lasers.remove(laser)
			else:
				for obj in objs:
					if laser.collision(obj):
						objs.remove(obj)
						if laser in self.lasers:
							self.lasers.remove(laser)
						return 1

	def draw(self, window):
		super().draw(window)
		self.healthbar(window)

	# draw healthbar
	def healthbar(self, window):
		pygame.draw.rect(window, (255,0,0), (self.x, self.y + self.ship_img.get_height() + 10, self.ship_img.get_width(), 10))
		pygame.draw.rect(window, (0,255,0), (self.x, self.y + self.ship_img.get_height() + 10, self.ship_img.get_width() * (self.health/self.max_health), 10))

class Enemy(Ship):
	COLOR_MAP = {
			"red": (RED_SPACE_SHIP, RED_LASER),
			"green": (GREEN_SPACE_SHIP, GREEN_LASER),
			"blue": (BLUE_SPACE_SHIP, BLUE_LASER)
				}

	def __init__(self, x, y, color,  health=100):
		super().__init__(x, y, health)
		self.ship_img, self.laser_img = self.COLOR_MAP[color]
		self.mask = pygame.mask.from_surface(self.ship_img)

	def move(self, velocity):
		self.y += velocity

	# initiate laser
	def shoot(self):
		if self.cool_down_counter == 0:
			laser = Laser(self.x-20, self.y, self.laser_img)
			self.lasers.append(laser)
			self.cool_down_counter = 1

def collide(obj1, obj2):
	offset_x = obj2.x - obj1.x
	offset_y = obj2.y - obj1.y
	return obj1.mask.overlap(obj2.mask, (offset_x, offset_y)) != None

#main loop
def main():
	run = True
	lost = False
	lost_count = 0
	points = 0
	FPS = 60
	level = 0
	lives = 5
	main_font = pygame.font.SysFont("comicsans", 50)
	lost_font = pygame.font.SysFont("comicsans", 60)

	enemies = []
	wave_length = 0
	enemy_velocity = 1

	player_velocity = 5
	laser_velocity = 5
	player = Player(300,650)
	clock = pygame.time.Clock()

	def redraw_window():
		WINDOW.blit(BACKGROUND, (0,0))
		#draw level and lives
		level_label = main_font.render(f"Level: {level}", 1, (255,255,255))
		lives_label = main_font.render(f"Lives: {lives}", 1, (255,255,255))
		points_label = main_font.render(f"Points: {points}", 1, (255,255,255))

		for enemy in enemies:
			enemy.draw(WINDOW)

		player.draw(WINDOW)

		if lost:
			lost_label = lost_font.render("You Lost!!", 1, (255,255,255))
			WINDOW.blit(lost_label, (WIDTH/2 - lost_label.get_width()/2, 350))

		WINDOW.blit(points_label, (10,10))
		WINDOW.blit(lives_label, (10,50))
		WINDOW.blit(level_label, (WIDTH - level_label.get_width() - 10, 10))

		pygame.display.update()

	while run:
		redraw_window()
		clock.tick(FPS)

		if lives <= 0 or player.health <= 0:
			lost = True
			lost_count += 1

		#if lost show only message and stops game
		if lost:
			if lost_count > FPS * 3:
				run = False
			else:
				continue
		
		if len(enemies) == 0:
			level += 1
			wave_length += 5
			for i in range(wave_length):
				enemy = Enemy(random.randrange(50, WIDTH - 100), random.randrange(-1500*level/5, -100), random.choice(["red","blue","green"]))
				enemies.append(enemy)	

		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				quit()

		keys = pygame.key.get_pressed()
		if (keys[pygame.K_a] or keys[pygame.K_LEFT]) and player.x - player_velocity > 0: # left
			player.x -= player_velocity
		if (keys[pygame.K_d] or keys[pygame.K_RIGHT]) and player.x + player_velocity + player.get_width() < WIDTH: # rigth
			player.x += player_velocity
		if (keys[pygame.K_w] or keys[pygame.K_UP]) and player.y - player_velocity > 0: # up
			player.y -= player_velocity
		if (keys[pygame.K_s] or keys[pygame.K_DOWN]) and player.y + player_velocity + player.get_height() + 15 < HEIGHT: #down
			player.y += player_velocity
		if keys[pygame.K_SPACE]:
			player.shoot()

		for enemy in enemies[:]:
			enemy.move(enemy_velocity)
			enemy.move_lasers(laser_velocity, player)

			#change of enemy shoot
			if random.randrange(0, 2*FPS) == 1:
				enemy.shoot()

			if collide(enemy, player):
				player.health -= 10
				enemies.remove(enemy)
			elif enemy.y + enemy.get_height() > HEIGHT:
				lives -= 1
				enemies.remove(enemy)

		if player.move_lasers(-laser_velocity, enemies) == 1:
			points += 100

def main_menu():
	title_font = pygame.font.SysFont("comicsans", 70)
	run = True
	while run:
		WINDOW.blit(BACKGROUND, (0,0))
		title_label = title_font.render("Press the mouse to begin...", 1, (255,255,255))
		WINDOW.blit(title_label, (WIDTH/2 - title_label.get_width()/2, 350))
		pygame.display.update()

		for event in pygame.event.get():
			if event.type == pygame.QUIT:
				run = False
			if event.type == pygame.MOUSEBUTTONDOWN:
				main()
	pygame.quit()

main_menu()