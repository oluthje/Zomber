extends Node2D

var Heart = preload("res://HUD/Health/Heart.tscn")

var player_health = 0

var space = 32
var pos_offset = 16
var heart_x = 0
var full_heart_num = 0
var half_heart_num = 0

func _ready():
	player_health = Item.player_health
	draw_hearts()

func _physics_process(delta):
	if Item.update_player_health:
		draw_hearts()
		Item.update_player_health = false
	
	if Item.player_health != player_health:
		lose_half_heart()
		player_health = Item.player_health

func lose_half_heart():
	print("health lost")
	var hearts = get_children()
	var heart_index = hearts.size()
	if not heart_index - 1 < 0:
		hearts[heart_index - 1].lose_heart()

func draw_hearts():
	player_health = Item.player_health
	
	heart_x = 0
	full_heart_num = 0
	half_heart_num = 0
	
	for i in get_children():
		i.queue_free()
		
	set_heart_nums()
	
	for i in range(full_heart_num):
		var heart = Heart.instance()
		heart.setup("full")
		add_child(heart)
		heart_x = i * space
		heart.position = Vector2(heart_x + pos_offset, pos_offset)
		
	if half_heart_num == 1:
		var heart = Heart.instance()
		heart.setup("half")
		add_child(heart)
		if Item.player_health != 1:
			heart_x += space
		heart.position = Vector2(heart_x + pos_offset, pos_offset)
			
func set_heart_nums():
	var full_hearts = int(Item.player_health/2)
	if full_hearts*2 == Item.player_health:
		full_heart_num = int(Item.player_health/2)
	else:
		full_heart_num = int(Item.player_health/2)
		half_heart_num = 1
