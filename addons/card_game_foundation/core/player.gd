# addons/card_game_foundation/core/player.gd
class_name Player
extends RefCounted

## Represents a player in a card game
## Can be human or AI controlled

signal card_played(player: Player, card: Card)
signal turn_started(player: Player)
signal turn_ended(player: Player)

enum PlayerType { HUMAN, AI }

@export var id: String
@export var name: String
@export var player_type: PlayerType
@export var is_active: bool = false
@export var score: int = 0
@export var properties: Dictionary = {}

var hand: Hand
var played_cards: Deck  # Cards played this round/trick

func _init(p_id: String, p_name: String, p_type: PlayerType = PlayerType.HUMAN):
	id = p_id
	name = p_name
	player_type = p_type
	hand = Hand.new(id)
	played_cards = Deck.new("Played Cards - " + name)
	
	# Connect hand signals
	hand.card_played.connect(_on_card_played)

## Deal cards to this player
func deal_cards(cards: Array[Card]) -> void:
	hand.add_cards(cards)

## Deal a single card to this player
func deal_card(card: Card) -> void:
	hand.add_card(card)

## Play a card from hand
func play_card(card: Card) -> Card:
	var played_card = hand.play_card(card)
	if played_card:
		played_cards.add_card(played_card)
		card_played.emit(self, played_card)
	return played_card

## Play a card by index
func play_card_at(index: int) -> Card:
	var played_card = hand.play_card_at(index)
	if played_card:
		played_cards.add_card(played_card)
		card_played.emit(self, played_card)
	return played_card

## Start this player's turn
func start_turn() -> void:
	is_active = true
	turn_started.emit(self)

## End this player's turn
func end_turn() -> void:
	is_active = false
	turn_ended.emit(self)

## Add points to score
func add_score(points: int) -> void:
	score += points

## Set score to specific value
func set_score(new_score: int) -> void:
	score = new_score

## Reset score to zero
func reset_score() -> void:
	score = 0

## Get all valid moves for this player (to be overridden by game rules)
func get_valid_moves() -> Array[Card]:
	return hand.cards.duplicate()

## Check if player can play a specific card (to be overridden by game rules)
func can_play_card(card: Card) -> bool:
	return hand.has_card(card)

## Get property value with default fallback
func get_property(key: String, default_value = null):
	return properties.get(key, default_value)

## Set a custom property
func set_property(key: String, value) -> void:
	properties[key] = value

## Clear played cards (usually done at end of trick/round)
func clear_played_cards() -> void:
	played_cards.clear()

## Get the last card played by this player
func get_last_played_card() -> Card:
	return played_cards.peek_top()

## Check if player has any cards left
func has_cards() -> bool:
	return not hand.is_empty()

## Get number of cards in hand
func get_hand_size() -> int:
	return hand.size()

## Sort hand using specified method
func sort_hand(sort_type: String = "suit_and_rank") -> void:
	match sort_type:
		"suit_and_rank":
			hand.sort_by_suit_and_rank()
		"rank":
			hand.sort_by_rank()
		"suit":
			hand.sort_by_suit()

## Reset player for new game
func reset_for_new_game() -> void:
	hand.clear()
	played_cards.clear()
	reset_score()
	is_active = false
	properties.clear()

## Get string representation
func to_string() -> String:
	var type_str = "Human" if player_type == PlayerType.HUMAN else "AI"
	return "%s (%s) - Score: %d, Cards: %d" % [name, type_str, score, get_hand_size()]

## Signal handler for when card is played from hand
func _on_card_played(card: Card) -> void:
	# This is handled by play_card methods above
	pass
