extends Node2D

var total_time = 5

onready var center = Vector2(0, 0)
onready var label = get_node("Label")
var radius = 7.5
var angle_from = 0
var angle_to = 0
var color = Color(1.0, 1.0, 1.0)
var line_thickness = 1.5
var drew_once = false

var draw = true

func _ready():
	get_node("Timer").set_wait_time(total_time)
	get_node("Timer").start()

func setup(time):
	total_time = time
	
func cancel_consumption():
	queue_free()
	
func _process(delta):
	if not get_parent().get_node("Player").in_timed_operation:
		cancel_consumption()
	
	if draw:
		var time_left = get_node("Timer").get_time_left()
		var percent = float(time_left)/float(total_time)
		angle_to = 360 * percent
		update()
		
		label.set_text(str(stepify(time_left, 0.1)))

func _draw():
	draw_filled_circle(center, radius + 4, 0, 360, Color(0.13, 0.13, 0.13))
	draw_circle_arc(center, radius, angle_from, angle_to, color)
	
func draw_filled_circle(center, radius, angle_from, angle_to, color):
	var nb_points = 16
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
	
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 16
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, line_thickness, true)
		
func _on_Timer_timeout():
	draw = false
	get_parent().get_node("Player").consumption_time_complete()
