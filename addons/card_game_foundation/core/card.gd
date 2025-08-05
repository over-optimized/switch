# addons/card_game_foundation/core/card.gd
class_name Card
extends Resource

## Base card class that can represent any playing card
## Extensible for different card game types

enum Suit { HEARTS, DIAMONDS, CLUBS, SPADES, NONE }
enum CardColor { RED, BLACK, NONE }

@export var id: String = ""
@export var name: String = ""
@export var suit: Suit = Suit.NONE
@export var rank: int = 0  # 1-13 for standard cards, or custom values
@export var face_texture: Texture2D
@export var back_texture: Texture2D
@export var properties: Dictionary = {}  # For game-specific properties

func _init(p_id: String = "", p_name: String = "", p_suit: Suit = Suit.NONE, p_rank: int = 0):
	id = p_id
	name = p_name
	suit = p_suit
	rank = p_rank

## Get the color of the card based on suit
func get_color() -> CardColor:
	match suit:
		Suit.HEARTS, Suit.DIAMONDS:
			return CardColor.RED
		Suit.CLUBS, Suit.SPADES:
			return CardColor.BLACK
		_:
			return CardColor.NONE

## Check if this card matches another card by suit
func matches_suit(other_card: Card) -> bool:
	return suit == other_card.suit

## Check if this card matches another card by rank
func matches_rank(other_card: Card) -> bool:
	return rank == other_card.rank

## Check if this card matches another card by color
func matches_color(other_card: Card) -> bool:
	return get_color() == other_card.get_color()

## Get a human-readable string representation
func to_string() -> String:
	var suit_name = Suit.keys()[suit] if suit != Suit.NONE else "NONE"
	return "%s (%s %d)" % [name, suit_name, rank]

## Get property value with default fallback
func get_property(key: String, default_value = null):
	return properties.get(key, default_value)

## Set a custom property
func set_property(key: String, value):
	properties[key] = value

## Compare cards for sorting (by suit then rank)
func compare_to(other_card: Card) -> int:
	if suit != other_card.suit:
		return suit - other_card.suit
	return rank - other_card.rank

## Create a copy of this card
func duplicate_card() -> Card:
	var new_card = Card.new(id, name, suit, rank)
	new_card.face_texture = face_texture
	new_card.back_texture = back_texture
	new_card.properties = properties.duplicate()
	return new_card
