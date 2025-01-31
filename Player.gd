extends CharacterBody2D

@export var Missile : PackedScene
@export var cooldown = 0.25
var can_shoot = true
@export var pHealth = 10

func _ready():
	$CoolDown.wait_time = cooldown 
	$Barrel/Fire.animation = "load"


var wheel_base = 70
var steering_angle = 15
var engine_power = 900
var friction = -55
var drag = -0.06
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 2.5
var traction_slow = 10

var acceleration = Vector2.ZERO
var steer_direction


func _physics_process(delta):
	Global.health = pHealth
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	if pHealth <= 0:
		get_tree().change_scene_to_file("res://lose.tscn")

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
func get_input():
	var turn = Input.get_axis("steer_left", "steer_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
# Comment out below if you want to stop but NOT reverse
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
# Uncomment below if you want braking to stop, but NOT reverse
	#if Input.is_action_pressed("brake"):
		#if velocity.x > 0:
			#acceleration = transform.x * braking
	if Input.is_action_just_pressed("shoot"):
		shoot() 
	
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.7
	var front_wheel = position + transform.x * wheel_base / 2.7
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
#	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$Barrel/Fire.play("fire")
	$CoolDown.start()
	var M = Missile.instantiate()
	owner.add_child(M)
	M.transform = $Barrel/Muzzle.global_transform
	$CoolDown.start()

func _on_cool_down_timeout():
	can_shoot = true

func _on_fire_animation_finished():
	if $Barrel/Fire.animation == "fire":
		$Barrel/Fire.animation = "load"

func hit():
	pHealth -= 1
	print(pHealth)

func heal():
	if pHealth < 10:
		pHealth += 1 
		print(pHealth)
