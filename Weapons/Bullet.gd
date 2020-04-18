extends KinematicBody2D

var BulletEffect = preload("res://Weapons/BulletHitEffect.tscn")

var SPEED = 800
var velocity := Vector2()
var DAMAGE = 15
var TYPE = "enemy"
var DIRECTION = 0

func set_up(direction, speed, damage, type):
	SPEED = speed
	DAMAGE = damage
	TYPE = type
	DIRECTION = direction
	velocity = Vector2(SPEED, 0).rotated(direction)

func _physics_process(delta):
	if TYPE == "player":
		$AnimationPlayer.play("playerbullet")
	else:
		$AnimationPlayer.play("enemybullet")
	move_and_collide(velocity * delta)
	if_should_free_bullet()
	
func if_should_free_bullet():
	var distance = 5000
	var pos = get_global_position()
	if abs(pos.x) > distance or abs(pos.y) > distance:
		queue_free()

func spawn_bullet_effect():
	var bullet_effect = BulletEffect.instance()
	bullet_effect.set_global_position(get_global_position())
	bullet_effect.set_rotation(DIRECTION + deg2rad(180))
	get_parent().add_child(bullet_effect)

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies") and TYPE != "enemy":
		body.take_damage(DAMAGE, DIRECTION)
		queue_free()
	if "Player" in body.name and TYPE != "player":
		body.take_damage(DAMAGE, DIRECTION)
		queue_free()
	if body.is_in_group("mineable"):
		body.take_damage(DAMAGE/3)
		queue_free()
	if "Tree" in body.name:
		body.take_damage(false)
		queue_free()

func _on_Area2D_area_entered(area):
	if "RiotShield" in area.name:
		area.take_damage(DAMAGE)
		spawn_bullet_effect()
		queue_free()
