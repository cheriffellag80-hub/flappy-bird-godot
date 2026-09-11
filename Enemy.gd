extends CharacterBody2D
class_name Enemy

# Character selection
enum CHARACTER {GOJO, YUJI, SUKUNA}
@export var character_type = CHARACTER.SUKUNA

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

# Abilities
var ability_cooldown = 0.0
var sukuna_mode = false

# AI
var player: Node2D = null
var facing_right = true
var is_attacking = false
var gojo_domain_active = false

func _ready():
	current_health = max_health
	add_to_group("enemy")
	setup_character()
	player = get_tree().get_first_node_in_group("player")

func setup_character():
	match character_type:
		CHARACTER.GOJO:
			$ColorRect.color = Color.CYAN
			$Label.text = "GOJO"
			max_health = 120
			current_health = max_health
			
		CHARACTER.YUJI:
			$ColorRect.color = Color.ORANGE
			$Label.text = "YUJI"
			max_health = 100
			current_health = max_health
			
		CHARACTER.SUKUNA:
			$ColorRect.color = Color.DARK_RED
			$Label.text = "SUKUNA"
			max_health = 130
			current_health = max_health
			punch_damage = 15
			kick_damage = 20

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
					
				# استخدام المهارات الخاصة
				if randf() > 0.85 and ability_cooldown <= 0:
					use_special_ability()
				
				velocity.x = 0
		else:
			# Return to idle
			velocity.x = lerp(velocity.x, 0.0, delta)
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if ability_cooldown > 0:
		ability_cooldown -= delta
	
	move_and_slide()

func punch():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed
		
		var damage = punch_damage
		if sukuna_mode:
			damage *= 1.5
		
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
				body.take_damage(damage)
		
		await get_tree().create_timer(0.2).timeout
		attack_area.queue_free()
		is_attacking = false

func kick():
	if attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = attack_speed * 1.2
		
		var damage = kick_damage
		if sukuna_mode:
			damage *= 1.5
		
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
				body.take_damage(damage)
		
		await get_tree().create_timer(0.3).timeout
		attack_area.queue_free()
		is_attacking = false

func use_special_ability():
	"""استخدام المهارة الخاصة"""
	if ability_cooldown > 0:
		return
	
	match character_type:
		CHARACTER.GOJO:
			gojo_infinity()
		CHARACTER.YUJI:
			yuji_sukuna_transformation()
		CHARACTER.SUKUNA:
			sukuna_cursed_technique()

func gojo_infinity():
	"""جوجو - حماية من اللانهاية"""
	ability_cooldown = 8.0
	gojo_domain_active = true
	
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.SKY_BLUE, 0.3)
	
	await get_tree().create_timer(3.0).timeout
	gojo_domain_active = false
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.CYAN, 0.3)

func yuji_sukuna_transformation():
	"""يوجي - تحول سوكونا"""
	ability_cooldown = 10.0
	sukuna_mode = true
	
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.DARK_RED, 0.5)
	
	var old_speed = speed
	var old_damage = punch_damage
	
	speed *= 1.5
	punch_damage *= 2
	
	await get_tree().create_timer(5.0).timeout
	sukuna_mode = false
	
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.ORANGE, 0.5)
	
	speed = old_speed
	punch_damage = old_damage

func sukuna_cursed_technique():
	"""سوكونا - تقنية لعنة"""
	ability_cooldown = 7.0
	
	var blast_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 150
	collision_shape.shape = shape
	blast_area.add_child(collision_shape)
	add_child(blast_area)
	
	if facing_right:
		blast_area.position.x = 100
	else:
		blast_area.position.x = -100
	
	var tween = create_tween()
	tween.tween_property(blast_area, "scale", Vector2(2, 2), 0.3)
	
	var bodies = blast_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			body.take_damage(40)
	
	await get_tree().create_timer(0.3).timeout
	blast_area.queue_free()

func take_damage(damage: int):
	if gojo_domain_active:
		damage = int(damage * 0.2)
	
	current_health -= damage
	if current_health <= 0:
		die()
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.YELLOW, 0.1)
	await tween.finished

func die():
	queue_free()
