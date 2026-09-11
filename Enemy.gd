extends CharacterBody2D
class_name Enemy

# Movement
@export var speed = 150.0
@export var gravity = 800.0
@export var detection_range = 300.0
@export var attack_range = 80.0

# Combat
@export var max_health = 80
var current_health
var attack_cooldown = 0.0
var attack_speed = 0.4
var punch_damage = 8
var kick_damage = 12

# AI
var player: Node2D = null
var facing_right = true
var is_attacking = false

func _ready():
	current_health = max_health
	add_to_group("enemy")
	$ColorRect.color = Color.RED
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player < detection_range:
			# Chase player
			if player.global_position.x > global_position.x:
				velocity.x = speed
				facing_right = true
				scale.x = 1
			else:
				velocity.x = -speed
				facing_right = false
				scale.x = -1
			
			# Attack if in range
			if distance_to_player < attack_range:
				if randf() > 0.7:
					if randf() > 0.5:
						punch()
					else:
						kick()
				velocity.x = 0
		else:
			# Return to idle
			velocity.x = lerp(velocity.x, 0.0, delta)
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	move_and_slide()

func punch():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed
		
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
			if body.is_in_group("player"):
				body.take_damage(punch_damage)
		
		await get_tree().create_timer(0.2).timeout
		attack_area.queue_free()
		is_attacking = false

func kick():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed * 1.2
		
		# Create attack area
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
			if body.is_in_group("player"):
				body.take_damage(kick_damage)
		
		await get_tree().create_timer(0.3).timeout
		attack_area.queue_free()
		is_attacking = false

func take_damage(damage: int):
	current_health -= damage
	if current_health <= 0:
		die()
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.YELLOW, 0.1)
	tween.tween_property($ColorRect, "color", Color.RED, 0.1)

func die():
	queue_free()
