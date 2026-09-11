extends Node
class_name GameManager

var player: Player
var enemy: Enemy
var game_over = false
var winner = ""

func _ready():
	player = get_tree().get_first_node_in_group("player")
	enemy = get_tree().get_first_node_in_group("enemy")
	
	# Update UI with instructions
	$CanvasLayer/InstructionsLabel.text = "Z: Punch | X: Kick | C: Dash | V: Special | B: Ultimate"

func _process(delta):
	if player and enemy:
		# Update UI
		$CanvasLayer/PlayerHealthLabel.text = "%s HP: %d/%d" % [player.$Label.text, player.current_health, player.max_health]
		$CanvasLayer/EnemyHealthLabel.text = "%s HP: %d/%d" % [enemy.$Label.text, enemy.current_health, enemy.max_health]
		$CanvasLayer/ComboLabel.text = "Combo: %d" % [player.combo_counter]
		
		# Show ability cooldowns
		var player_cooldown = int(player.ability_cooldown)
		var enemy_cooldown = int(enemy.ability_cooldown)
		
		if player.ability_cooldown > 0:
			$CanvasLayer/PlayerCooldownLabel.text = "Cooldown: %ds" % player_cooldown
		else:
			$CanvasLayer/PlayerCooldownLabel.text = "Ready!"
		
		if enemy.ability_cooldown > 0:
			$CanvasLayer/EnemyCooldownLabel.text = "Cooldown: %ds" % enemy_cooldown
		else:
			$CanvasLayer/EnemyCooldownLabel.text = "Ready!"
		
		# Check win conditions
		if player.current_health <= 0 and not game_over:
			game_over = true
			winner = "Enemy"
			$CanvasLayer/GameOverLabel.text = "GAME OVER! %s Wins!" % enemy.$Label.text
			$CanvasLayer/GameOverLabel.visible = true
		elif enemy.current_health <= 0 and not game_over:
			game_over = true
			winner = "Player"
			$CanvasLayer/GameOverLabel.text = "YOU WIN! %s is victorious!" % player.$Label.text
			$CanvasLayer/GameOverLabel.visible = true

func restart_game():
	get_tree().reload_current_scene()
