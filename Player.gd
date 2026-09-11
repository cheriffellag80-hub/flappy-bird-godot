extends CharacterBody2D
class_name Player

# Movement
@export var speed = 200.0
@export var jump_force = -300.0
@export var gravity = 800.0

# Combat
@export var max_health = 100
var current_health
var is_attacking = false
var attack_cooldown = 0.0
var attack_speed = 0.3

# Animation
var is_jumping = false
var facing_right = true

# Combat stats
var punch_damage = 10
var kick_damage = 15
var combo_counter = 0
var combo_timer = 0.0

func _ready():
	current_health = max_health
	$ColorRect.color = Color.BLUE

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Movement input
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Horizontal movement
	velocity.x = input_vector.x * speed
	
	# Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
	
	# Flip sprite direction
	if input_vector.x > 0:
		facing_right = true
		scale.x = 1
	elif input_vector.x < 0:
		facing_right = false
		scale.x = -1
	
	# Combat
	if Input.is_action_just_pressed("ui_accept"):
		punch()
	
	if Input.is_action_just_pressed("ui_select"):
		kick()
	
	# Update cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_counter = 0
	
	move_and_slide()

func punch():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed
		combo_counter += 1
		combo_timer = 1.0
		
		var damage = punch_damage + (combo_counter * 2)
		
		# Create attack area
		var attack_area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(60, 40)
		collision_shape.shape = shape
		attack_area.add_child(collision_shape)
		add_child(attack_area)
		
		if facing_right:
			attack_area.position.x = 40
		else:
			attack_area.position.x = -40
		
		# Detect hits
		var bodies = attack_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemy") and body != self:
				body.take_damage(damage)
		
		# Remove attack area after short time
		await get_tree().create_timer(0.2).timeout
		attack_area.queue_free()
		is_attacking = false

func kick():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed * 1.2
		combo_counter += 1
		combo_timer = 1.0
		
		var damage = kick_damage + (combo_counter * 3)
		
		# Create attack area (larger for kick)
		var attack_area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(80, 50)
		collision_shape.shape = shape
		attack_area.add_child(collision_shape)
		add_child(attack_area)
		
		if facing_right:
			attack_area.position.x = 50
		else:
			attack_area.position.x = -50
		
		# Detect hits
		var bodies = attack_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemy") and body != self:
				body.take_damage(damage)
		
		# Remove attack area after short time
		await get_tree().create_timer(0.3).timeout
		attack_area.queue_free()
		is_attacking = false

func take_damage(damage: int):
	current_health -= damage
	if current_health <= 0:
		die()
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.RED, 0.1)
	tween.tween_property($ColorRect, "color", Color.BLUE, 0.1)

func die():
	queue_free()

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
