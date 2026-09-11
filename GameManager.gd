extends Node
class_name GameManager

var player: Player
var enemy: Enemy
var game_over = false
var winner = ""

func _ready():
	player = get_tree().get_first_node_in_group("player")
	enemy = get_tree().get_first_node_in_group("enemy")

func _process(delta):
	if player and enemy:
		# Update UI
		$CanvasLayer/PlayerHealthLabel.text = "Player HP: %d/%d" % [player.current_health, player.max_health]
		$CanvasLayer/EnemyHealthLabel.text = "Enemy HP: %d/%d" % [enemy.current_health, enemy.max_health]
		$CanvasLayer/ComboLabel.text = "Combo: %d" % [player.combo_counter]
		
		# Check win conditions
		if player.current_health <= 0 and not game_over:
			game_over = true
			winner = "Enemy"
			$CanvasLayer/GameOverLabel.text = "GAME OVER! Enemy Wins!"
			$CanvasLayer/GameOverLabel.visible = true
		elif enemy.current_health <= 0 and not game_over:
			game_over = true
			winner = "Player"
			$CanvasLayer/GameOverLabel.text = "YOU WIN!"
			$CanvasLayer/GameOverLabel.visible = true

func restart_game():
	get_tree().reload_current_scene()
