extends KinematicBody2D

var speed = 800
var velocity := Vector2()
var damage = 15

func set_up(direction):
	velocity = Vector2(speed, 0).rotated(direction)

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_Area2D_body_entered(body):
	if "Zombie" in body.name:
		body.take_damage(damage)
		queue_free()
