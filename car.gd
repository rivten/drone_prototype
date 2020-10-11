extends KinematicBody2D

export(float) var mass = 1.0
export(float) var friction_coeff = 10.0
export(float) var objective_coeff = 10.0
export(float) var input_force_coeff = 1000.0

var previous_velocity = Vector2(0, 0)
var previous_rotation = 0
var objectif_point = null

func friction_force():
	return -friction_coeff * previous_velocity

func input_force():
	var input_force = Vector2(0, 0)

	if Input.is_key_pressed(KEY_RIGHT):
		input_force += Vector2.RIGHT
	if Input.is_key_pressed(KEY_LEFT):
		input_force += Vector2.LEFT
	if Input.is_key_pressed(KEY_UP):
		input_force += Vector2.UP
	if Input.is_key_pressed(KEY_DOWN):
		input_force += Vector2.DOWN

	input_force *= input_force_coeff
	return input_force

func objective_force():
	if objectif_point == null:
		return Vector2(0, 0)
	else:
		if abs(get_diff_angle()) > PI/8:
			return Vector2(0, 0)
		return objective_coeff * (objectif_point - position)

func get_diff_angle():
	if objectif_point == null:
		return 0
	else:
		return (objectif_point - position).angle() - rotation

func _physics_process(dt):
	# Objective point management
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		objectif_point = get_viewport().get_mouse_position()
	if objectif_point and (objectif_point - position).length() <= 10.0:
		objectif_point = null

	# Newton's Law
	# m*a = sum_forces
	var sum_forces = input_force() + friction_force() + objective_force()
	var acceleration = (1.0 / mass) * sum_forces

	# dv/dt = a
	var velocity = previous_velocity + acceleration * dt

	# Call to Godot's physics engine
	previous_velocity = move_and_slide(velocity)

	# Rotation management
	var rotation_speed = get_diff_angle()
	rotation = previous_rotation + rotation_speed * dt
	previous_rotation = rotation
