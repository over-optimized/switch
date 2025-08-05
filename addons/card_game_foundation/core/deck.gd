# addons/card_game_foundation/core/deck.gd
class_name Deck
extends Resource

## A collection of cards with common deck operations
## Can represent main deck, discard pile, or any card collection

signal card_drawn(card: Card)
signal card_added(card: Card)
signal deck_shuffled
signal deck_empty

@export var cards: Array[Card] = []
@export var name: String = "Deck"

func _init(p_name: String = "Deck"):
	name = p_name

## Add a card to the top of the deck
func add_card(card: Card) -> void:
	cards.append(card)
	card_added.emit(card)

## Add a card at a specific position
func add_card_at(card: Card, position: int) -> void:
	position = clamp(position, 0, cards.size())
	cards.insert(position, card)
	card_added.emit(card)

## Add multiple cards to the deck
func add_cards(new_cards: Array[Card]) -> void:
	for card in new_cards:
		add_card(card)

## Draw a card from the top of the deck
func draw_card() -> Card:
	if is_empty():
		deck_empty.emit()
		return null
	
	var card = cards.pop_back()
	card_drawn.emit(card)
	return card

## Draw multiple cards from the deck
func draw_cards(count: int) -> Array[Card]:
	var drawn_cards: Array[Card] = []
	for i in range(min(count, cards.size())):
		var card = draw_card()
		if card:
			drawn_cards.append(card)
	return drawn_cards

## Peek at the top card without removing it
func peek_top() -> Card:
	if is_empty():
		return null
	return cards.back()

## Peek at the bottom card without removing it
func peek_bottom() -> Card:
	if is_empty():
		return null
	return cards.front()

## Shuffle the deck
func shuffle() -> void:
	cards.shuffle()
	deck_shuffled.emit()

## Check if the deck is empty
func is_empty() -> bool:
	return cards.is_empty()

## Get the number of cards in the deck
func size() -> int:
	return cards.size()

## Clear all cards from the deck
func clear() -> void:
	cards.clear()

## Find a card by its ID
func find_card_by_id(id: String) -> Card:
	for card in cards:
		if card.id == id:
			return card
	return null

## Remove a specific card from the deck
func remove_card(card: Card) -> bool:
	var index = cards.find(card)
	if index >= 0:
		cards.remove_at(index)
		return true
	return false

## Remove a card by its ID
func remove_card_by_id(id: String) -> Card:
	var card = find_card_by_id(id)
	if card and remove_card(card):
		return card
	return null

## Get all cards matching certain criteria
func find_cards_by_suit(suit: Card.Suit) -> Array[Card]:
	var matching_cards: Array[Card] = []
	for card in cards:
		if card.suit == suit:
			matching_cards.append(card)
	return matching_cards

func find_cards_by_rank(rank: int) -> Array[Card]:
	var matching_cards: Array[Card] = []
	for card in cards:
		if card.rank == rank:
			matching_cards.append(card)
	return matching_cards

## Sort the deck using card's compare_to method
func sort_cards() -> void:
	cards.sort_custom(func(a: Card, b: Card): return a.compare_to(b) < 0)

## Create a copy of this deck
func duplicate_deck() -> Deck:
	var new_deck = Deck.new(name)
	for card in cards:
		new_deck.add_card(card.duplicate_card())
	return new_deck

## Get a string representation of the deck
func to_string() -> String:
	return "%s: %d cards" % [name, size()]
