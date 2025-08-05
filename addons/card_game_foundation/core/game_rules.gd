# addons/card_game_foundation/core/game_rules.gd
class_name GameRules
extends RefCounted

## Base class for game-specific rules
## Override these methods to implement specific card games

signal game_won(winner: Player)
signal round_ended(scores: Dictionary)
signal invalid_move_attempted(player: Player, card: Card)

## Setup the game with initial conditions
func setup_game(players: Array[Player], deck: Deck) -> void:
	push_error("setup_game() must be implemented by subclass")

## Check if a move is valid for the current game state
func is_valid_move(player: Player, card: Card, game_data: Dictionary) -> bool:
	push_error("is_valid_move() must be implemented by subclass")
	return false

## Apply a move and return updated game data
func apply_move(player: Player, card: Card, game_data: Dictionary) -> Dictionary:
	push_error("apply_move() must be implemented by subclass")
	return game_data

## Handle special card effects (called after apply_move)
func handle_special_card_effects(card: Card, player: Player, game_data: Dictionary) -> Dictionary:
	# Default implementation does nothing
	return game_data

## Get all valid moves for a player
func get_valid_moves(player: Player, game_data: Dictionary) -> Array[Card]:
	push_error("get_valid_moves() must be implemented by subclass")
	return []

## Get the turn order for players (allows for direction changes, skipping, etc.)
func get_turn_order(players: Array[Player], game_data: Dictionary) -> Array[Player]:
	# Default implementation: return players in original order
	return players

## Check if the game has ended
func is_game_over(game_data: Dictionary) -> bool:
	push_error("is_game_over() must be implemented by subclass")
	return false

## Get the winner(s) of the game
func get_winner(players: Array[Player], game_data: Dictionary) -> Array[Player]:
	push_error("get_winner() must be implemented by subclass")
	return []

## Validate that the game setup is valid
func validate_game_setup(players: Array[Player], deck: Deck) -> bool:
	if players.is_empty():
		push_error("No players provided")
		return false
	
	if not deck or deck.is_empty():
		push_error("No deck provided or deck is empty")
		return false
	
	return true

## Calculate scores for players (optional, depends on game)
func calculate_scores(players: Array[Player]) -> Dictionary:
	var scores = {}
	for player in players:
		scores[player.id] = player.score
	return scores

## Handle end of round (optional)
func handle_round_end(players: Array[Player]) -> void:
	var scores = calculate_scores(players)
	round_ended.emit(scores)
