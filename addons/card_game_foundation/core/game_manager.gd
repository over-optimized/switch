# addons/card_game_foundation/core/game_manager.gd
class_name GameManager
extends Node

## Manages the overall game flow, turns, and state
## Works with GameRules to enforce game-specific logic

signal game_started
signal game_ended(winner: Player)
signal turn_changed(current_player: Player)
signal move_made(player: Player, card: Card)
signal invalid_move(player: Player, card: Card)

enum GameState { 
	NOT_STARTED, 
	IN_PROGRESS, 
	PAUSED, 
	ENDED 
}

@export var current_state: GameState = GameState.NOT_STARTED
@export var current_player_index: int = 0
@export var round_number: int = 0

var players: Array[Player] = []
var current_player: Player
var deck: Deck
var discard_pile: Deck
var game_rules: GameRules
var game_data: Dictionary = {}  # Store game-specific state

func _ready():
	discard_pile = Deck.new("Discard Pile")

## Initialize the game with players and rules
func setup_game(p_players: Array[Player], p_deck: Deck, p_rules: GameRules) -> bool:
	if current_state != GameState.NOT_STARTED:
		push_error("Game already in progress")
		return false
	
	players = p_players
	deck = p_deck  
	game_rules = p_rules
	
	# Validate setup
	if not game_rules.validate_game_setup(players, deck):
		return false
	
	# Connect player signals
	for player in players:
		player.card_played.connect(_on_player_card_played)
		player.turn_started.connect(_on_player_turn_started)
		player.turn_ended.connect(_on_player_turn_ended)
	
	# Connect game rules signals
	game_rules.game_won.connect(_on_game_won)
	game_rules.round_ended.connect(_on_round_ended)
	game_rules.invalid_move_attempted.connect(_on_invalid_move_attempted)
	
	return true

## Start the game
func start_game() -> void:
	if current_state != GameState.NOT_STARTED:
		push_error("Cannot start game in current state")
		return
	
	current_state = GameState.IN_PROGRESS
	round_number = 1
	
	# Let game rules handle initial setup
	game_rules.setup_game(players, deck)
	
	# Start first turn
	current_player_index = 0
	_start_next_turn()
	
	game_started.emit()

## Make a move for the current player
func make_move(card: Card) -> bool:
	if current_state != GameState.IN_PROGRESS:
		push_error("Game not in progress")
		return false
	
	if not current_player:
		push_error("No current player")
		return false
	
	# Check if move is valid
	if not game_rules.is_valid_move(current_player, card, game_data):
		invalid_move.emit(current_player, card)
		return false
	
	# Apply the move
	var played_card = current_player.play_card(card)
	if not played_card:
		push_error("Failed to play card")
		return false
	
	# Update game state through rules
	game_data = game_rules.apply_move(current_player, played_card, game_data)
	
	# Handle special card effects
	game_data = game_rules.handle_special_card_effects(played_card, current_player, game_data)
	
	move_made.emit(current_player, played_card)
	
	# Check if game is over
	if game_rules.is_game_over(game_data):
		_end_game()
		return true
	
	# Move to next turn
	_end_current_turn()
	
	return true

## Pause the game
func pause_game() -> void:
	if current_state == GameState.IN_PROGRESS:
		current_state = GameState.PAUSED

## Resume the game
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.IN_PROGRESS

## End the current turn and move to next player
func _end_current_turn() -> void:
	if current_player:
		current_player.end_turn()
	
	_advance_to_next_player()
	_start_next_turn()

## Advance to the next player
func _advance_to_next_player() -> void:
	var turn_order = game_rules.get_turn_order(players, game_data)
	
	# Find current player in turn order
	var current_index = turn_order.find(current_player)
	if current_index >= 0:
		current_player_index = (current_index + 1) % turn_order.size()
		current_player = turn_order[current_player_index]
	else:
		# Fallback to simple index-based rotation
		current_player_index = (current_player_index + 1) % players.size()
		current_player = players[current_player_index]

## Start the next player's turn
func _start_next_turn() -> void:
	current_player = players[current_player_index]
	current_player.start_turn()
	turn_changed.emit(current_player)

## End the game and determine winner
func _end_game() -> void:
	current_state = GameState.ENDED
	
	var winners = game_rules.get_winner(players, game_data)
	var winner = winners[0] if not winners.is_empty() else null
	
	# End all player turns
	for player in players:
		if player.is_active:
			player.end_turn()
	
	game_ended.emit(winner)

## Get the current game state
func get_game_state() -> Dictionary:
	return {
		"state": current_state,
		"current_player": current_player.id if current_player else "",
		"round_number": round_number,
		"scores": _get_all_scores(),
		"game_data": game_data
	}

## Get all player scores
func _get_all_scores() -> Dictionary:
	var scores = {}
	for player in players:
		scores[player.id] = player.score
	return scores

## Get valid moves for current player
func get_valid_moves_for_current_player() -> Array[Card]:
	if not current_player or current_state != GameState.IN_PROGRESS:
		return []
	
	return game_rules.get_valid_moves(current_player, game_data)

## Reset game for a new round
func reset_game() -> void:
	current_state = GameState.NOT_STARTED
	current_player_index = 0
	round_number = 0
	current_player = null
	game_data.clear()
	
	for player in players:
		player.reset_for_new_game()
	
	if deck:
		deck.clear()
	
	discard_pile.clear()

## Signal handlers
func _on_player_card_played(player: Player, card: Card) -> void:
	# Handled by make_move method
	pass

func _on_player_turn_started(player: Player) -> void:
	print("%s's turn started" % player.name)

func _on_player_turn_ended(player: Player) -> void:
	print("%s's turn ended" % player.name)

func _on_game_won(winner: Player) -> void:
	print("Game won by %s!" % winner.name)

func _on_round_ended(scores: Dictionary) -> void:
	round_number += 1
	print("Round %d ended. Scores: %s" % [round_number, scores])

func _on_invalid_move_attempted(player: Player, card: Card) -> void:
	print("Invalid move: %s tried to play %s" % [player.name, card.name])
