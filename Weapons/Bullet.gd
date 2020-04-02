extends KinematicBody2D

var SPEED = 800
var velocity := Vector2()
var DAMAGE = 15
var TYPE = "enemy"

func set_up(direction, speed, damage, type):
	SPEED = speed
	DAMAGE = damage
	TYPE = type
	velocity = Vector2(SPEED, 0).rotated(direction)

func _physics_process(delta):
	if TYPE == "player":
		$AnimationPlayer.play("playerbullet")
	else:
		$AnimationPlayer.play("enemybullet")
	move_and_collide(velocity * delta)

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(DAMAGE)
		queue_free()
	if "Tree" in body.name:
		queue_free()
	if "Player" in body.name:
		body.take_damage()
		queue_free()
