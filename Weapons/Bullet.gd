extends KinematicBody2D

var SPEED = 800
var velocity := Vector2()
var DAMAGE = 15

func set_up(direction, speed, damage):
	SPEED = speed
	DAMAGE = damage
	velocity = Vector2(SPEED, 0).rotated(direction)
	print(rad2deg(direction))

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_Area2D_body_entered(body):
	if "Zombie" in body.name:
		body.take_damage(DAMAGE)
		queue_free()
