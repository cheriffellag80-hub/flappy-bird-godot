extends CharacterBody2D
class_name Player

# Character selection
enum CHARACTER {GOJO, YUJI, SUKUNA}
@export var character_type = CHARACTER.GOJO

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

# Special abilities
var ability_cooldown = 0.0
var is_in_special_mode = false
var special_ability_active = false

# Animation
var is_jumping = false
var facing_right = true

# Combat stats
var punch_damage = 10
var kick_damage = 15
var combo_counter = 0
var combo_timer = 0.0

# Character specific
var gojo_domain_active = false
var yuji_sukuna_mode = false
var sukuna_power_level = 0

func _ready():
	current_health = max_health
	setup_character()

add_to_group("player")

func setup_character():
	match character_type:
		CHARACTER.GOJO:
			$ColorRect.color = Color.CYAN
			$Label.text = "GOJO"
			$Label.add_theme_font_size_override("font_size", 16)
			max_health = 120
			current_health = max_health
			
		CHARACTER.YUJI:
			$ColorRect.color = Color.ORANGE
			$Label.text = "YUJI"
			$Label.add_theme_font_size_override("font_size", 16)
			max_health = 100
			current_health = max_health
			
		CHARACTER.SUKUNA:
			$ColorRect.color = Color.DARK_RED
			$Label.text = "SUKUNA"
			$Label.add_theme_font_size_override("font_size", 16)
			max_health = 130
			current_health = max_health
			punch_damage = 15
			kick_damage = 20

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
	
	# Special abilities
	if Input.is_action_just_pressed("dash"):
		dash()
	
	if Input.is_action_just_pressed("special_ability"):
		use_special_ability()
	
	if Input.is_action_just_pressed("ultimate"):
		use_ultimate_ability()
	
	# Update cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	if ability_cooldown > 0:
		ability_cooldown -= delta
	
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
		if yuji_sukuna_mode:
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
		if yuji_sukuna_mode:
			damage *= 1.5
		
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

func dash():
	"""سرعة فائقة تجعلك غير مرئي للخصم"""
	if ability_cooldown <= 0:
		ability_cooldown = 5.0
		var dash_direction = 1 if facing_right else -1
		
		# Move quickly
		for i in range(10):
			velocity.x = dash_direction * 600
			global_position.x += dash_direction * 30
			
			# Visual effect - fade
			var tween = create_tween()
			tween.tween_property($ColorRect, "modulate:a", 0.3, 0.05)
			await tween.finished
			var tween2 = create_tween()
			tween2.tween_property($ColorRect, "modulate:a", 1.0, 0.05)
			await tween2.finished
			await get_tree().create_timer(0.05).timeout


func use_special_ability():
	"""المهارة الخاصة لكل شخصية"""
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
	"""جوجو يفتح عينيه الزرقاء (Infinity) - حماية كاملة"""
	if ability_cooldown > 0:
		return
	
	ability_cooldown = 8.0
	gojo_domain_active = true
	
	# تأثير بصري - تغيير اللون للأزرق الفاتح
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.SKY_BLUE, 0.3)
	
	# إضاءة قوية
	var glow = PointLight2D.new()
	glow.energy = 2.0
	glow.color = Color.CYAN
	add_child(glow)
	
	# الحماية لمدة 3 ثوان
	await get_tree().create_timer(3.0).timeout
	gojo_domain_active = false
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.CYAN, 0.3)
	glow.queue_free()

func yuji_sukuna_transformation():
	"""يوجي يتحول إلى سوكونا مؤقتاً"""
	if ability_cooldown > 0:
		return
	
	ability_cooldown = 10.0
	yuji_sukuna_mode = true
	
	# تأثير التحول
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.DARK_RED, 0.5)
	
	# زيادة الضرر والسرعة
	var old_speed = speed
	var old_damage_punch = punch_damage
	var old_damage_kick = kick_damage
	
	speed *= 1.5
	punch_damage *= 2
	kick_damage *= 2
	
	# استمرار 5 ثواني
	await get_tree().create_timer(5.0).timeout
	yuji_sukuna_mode = false
	
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.ORANGE, 0.5)
	
	speed = old_speed
	punch_damage = old_damage_punch
	kick_damage = old_damage_kick

func sukuna_cursed_technique():
	"""سوكونا يطلق تقنية لعنة قوية"""
	if ability_cooldown > 0:
		return
	
	ability_cooldown = 7.0
	
	# موجة قوية تضرب كل شيء أمامه
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
	
	# تأثير الانفجار
	var tween = create_tween()
	tween.tween_property(blast_area, "scale", Vector2(2, 2), 0.3)
	var tween2 = create_tween()
	tween2.tween_property(blast_area, "modulate:a", 0.0, 0.3)
	
	# ضرر الخصوم
	var bodies = blast_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"):
			body.take_damage(40)
	
	await get_tree().create_timer(0.3).timeout
	blast_area.queue_free()

func use_ultimate_ability():
	"""المهارة النهائية"""
	if ability_cooldown > 0:
		return
	
	match character_type:
		CHARACTER.GOJO:
			gojo_domain_expansion()
		CHARACTER.YUJI:
			yuji_maximum_output()
		CHARACTER.SUKUNA:
			sukuna_annihilation()

func gojo_domain_expansion():
	"""جوجو - توسيع المجال (Unlimited Void)"""
	ability_cooldown = 15.0
	
	var domain_circle = Circle2D.new()
	domain_circle.radius = 300
	
	# تأثير الفراغ اللانهائي
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.PURPLE, 0.5)
	
	var enemy = get_tree().get_first_node_in_group("enemy")
	if enemy:
		enemy.take_damage(60)
		# شل العدو قليلاً
		var old_speed = enemy.speed
		enemy.speed = 0
		await get_tree().create_timer(2.0).timeout
		enemy.speed = old_speed
	
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.CYAN, 0.5)

func yuji_maximum_output():
	"""يوجي - القوة القصوى"""
	ability_cooldown = 15.0
	
	# تحول كامل مع قوة عظمى
	yuji_sukuna_mode = true
	
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.RED, 0.5)
	
	punch_damage *= 3
	kick_damage *= 3
	speed *= 2
	
	# 6 ثواني من القوة القصوى
	await get_tree().create_timer(6.0).timeout
	yuji_sukuna_mode = false
	
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.ORANGE, 0.5)

func sukuna_annihilation():
	"""سوكونا - الإبادة الكاملة (Malevolent Shrine)"""
	ability_cooldown = 15.0
	
	# هجوم ساحق
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.DARK_RED, 0.3)
	
	var enemy = get_tree().get_first_node_in_group("enemy")
	if enemy:
		enemy.take_damage(80)  # ضرر عالي جداً
	
	var tween2 = create_tween()
	tween2.tween_property($ColorRect, "color", Color.RED, 0.3)

func take_damage(damage: int):
	if gojo_domain_active:
		damage = int(damage * 0.2)  # تقليل الضرر عند تفعيل Infinity
	
	current_health -= damage
	if current_health <= 0:
		die()
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.YELLOW, 0.1)
	await tween.finished
	
	# Restore original color
	match character_type:
		CHARACTER.GOJO:
			tween = create_tween()
			tween.tween_property($ColorRect, "color", Color.CYAN, 0.1)
		CHARACTER.YUJI:
			if not yuji_sukuna_mode:
				tween = create_tween()
				tween.tween_property($ColorRect, "color", Color.ORANGE, 0.1)
		CHARACTER.SUKUNA:
			tween = create_tween()
			tween.tween_property($ColorRect, "color", Color.DARK_RED, 0.1)

func die():
	queue_free()

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
