extends KinematicBody2D

var SPEED = 800
var velocity := Vector2()
var DAMAGE = 15

func set_up(direction, speed, damage):
	SPEED = speed
	DAMAGE = damage
	velocity = Vector2(SPEED, 0).rotated(direction)

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(DAMAGE)
		queue_free()
