# addons/card_game_foundation/core/hand.gd
class_name Hand
extends Deck

## Represents a player's hand of cards
## Extends Deck with hand-specific functionality

signal hand_sorted
signal card_played(card: Card)

@export var max_size: int = -1  # -1 for unlimited
@export var owner_id: String = ""

func _init(p_owner_id: String = "", p_max_size: int = -1):
	super("Hand")
	owner_id = p_owner_id
	max_size = p_max_size

## Override add_card to respect hand size limits
func add_card(card: Card) -> void:
	if max_size > 0 and cards.size() >= max_size:
		push_warning("Hand is at maximum capacity (%d cards)" % max_size)
		return
	super.add_card(card)

## Play a card from the hand (removes it)
func play_card(card: Card) -> Card:
	if remove_card(card):
		card_played.emit(card)
		return card
	return null

## Play a card by index
func play_card_at(index: int) -> Card:
	if index < 0 or index >= cards.size():
		return null
	
	var card = cards[index]
	cards.remove_at(index)
	card_played.emit(card)
	return card

## Sort hand by suit and rank
func sort_by_suit_and_rank() -> void:
	sort_cards()
	hand_sorted.emit()

## Sort hand by rank only
func sort_by_rank() -> void:
	cards.sort_custom(func(a: Card, b: Card): return a.rank < b.rank)
	hand_sorted.emit()

## Sort hand by suit only
func sort_by_suit() -> void:
	cards.sort_custom(func(a: Card, b: Card): return a.suit < b.suit)
	hand_sorted.emit()

## Check if hand contains a specific card
func has_card(card: Card) -> bool:
	return cards.has(card)

## Check if hand contains card with specific ID
func has_card_id(id: String) -> bool:
	return find_card_by_id(id) != null

## Get all playable cards based on a condition
func get_playable_cards(condition: Callable) -> Array[Card]:
	var playable: Array[Card] = []
	for card in cards:
		if condition.call(card):
			playable.append(card)
	return playable

## Check if hand is at maximum capacity
func is_full() -> bool:
	return max_size > 0 and cards.size() >= max_size

## Get remaining capacity
func get_remaining_capacity() -> int:
	if max_size <= 0:
		return -1  # Unlimited
	return max_size - cards.size()

## Get cards by suit
func get_cards_by_suit(suit: Card.Suit) -> Array[Card]:
	return find_cards_by_suit(suit)

## Get cards by rank
func get_cards_by_rank(rank: int) -> Array[Card]:
	return find_cards_by_rank(rank)

## Get highest rank card in hand
func get_highest_card() -> Card:
	if is_empty():
		return null
	
	var highest = cards[0]
	for card in cards:
		if card.rank > highest.rank:
			highest = card
	return highest

## Get lowest rank card in hand
func get_lowest_card() -> Card:
	if is_empty():
		return null
	
	var lowest = cards[0]
	for card in cards:
		if card.rank < lowest.rank:
			lowest = card
	return lowest

## Check for pairs, triplets, etc.
func get_rank_counts() -> Dictionary:
	var counts = {}
	for card in cards:
		counts[card.rank] = counts.get(card.rank, 0) + 1
	return counts

## Check for suit counts
func get_suit_counts() -> Dictionary:
	var counts = {}
	for card in cards:
		counts[card.suit] = counts.get(card.suit, 0) + 1
	return counts

## Get string representation with cards
func to_string() -> String:
	var card_names = []
	for card in cards:
		card_names.append(card.name)
	return "Hand (%s): [%s]" % [owner_id, ", ".join(card_names)]
