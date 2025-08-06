# addons/card_game_foundation/games/switch/switch_deck_factory.gd
class_name SwitchDeckFactory
extends RefCounted

## Factory for creating Switch-compatible decks
## Creates standard 52-card deck with Switch-specific properties

static func create_switch_deck() -> Deck:
	var deck = Deck.new("Switch Deck")

	# Define rank names and values
	var rank_names = {
		1: "A", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7",
		8: "8", 9: "9", 10: "10", 11: "J", 12: "Q", 13: "K"
	}

	# Define suit symbols and names
	var suit_info = {
		Card.Suit.HEARTS: {"symbol": "♥", "name": "Hearts", "color": "red"},
		Card.Suit.DIAMONDS: {"symbol": "♦", "name": "Diamonds", "color": "red"},
		Card.Suit.CLUBS: {"symbol": "♣", "name": "Clubs", "color": "black"},
		Card.Suit.SPADES: {"symbol": "♠", "name": "Spades", "color": "black"}
	}

	# Create cards for each suit
	for suit in [Card.Suit.HEARTS, Card.Suit.DIAMONDS, Card.Suit.CLUBS, Card.Suit.SPADES]:
		for rank in range(1, 14):
			var suit_data = suit_info[suit]
			var rank_name = rank_names[rank]

			# Card display name (e.g., "A♥", "5♠", "K♦")
			var card_name = "%s%s" % [rank_name, suit_data.symbol]

			# Unique ID for the card
			var card_id = "%s_%d" % [Card.Suit.keys()[suit].to_lower(), rank]

			var card = Card.new(card_id, card_name, suit, rank)

			# Add Switch-specific properties
			card.set_property("is_trick_card", _is_trick_card(rank, suit))
			card.set_property("trick_type", _get_trick_type(rank, suit))
			card.set_property("suit_symbol", suit_data.symbol)
			card.set_property("suit_name", suit_data.name)
			card.set_property("color", suit_data.color)
			card.set_property("rank_name", rank_name)

			# Special properties for specific cards
			if rank == 5 and suit == Card.Suit.HEARTS:
				card.set_property("is_five_hearts", true)
				card.set_property("penalty_amount", 5)
			elif rank == 2:
				card.set_property("penalty_amount", 2)
				card.set_property("can_counter_five_hearts", suit == Card.Suit.HEARTS)

			deck.add_card(card)

	return deck

## Check if a card is a trick card in Switch
static func _is_trick_card(rank: int, suit: Card.Suit) -> bool:
	match rank:
		1, 2, 3, 7, 8, 11:  # Ace, 2, 3, 7, 8, Jack
			return true
		5:  # 5 is only trick if it's hearts
			return suit == Card.Suit.HEARTS
		_:
			return false

## Get the trick type for a card
static func _get_trick_type(rank: int, suit: Card.Suit) -> String:
	match rank:
		1:
			return "suit_changer"
		2:
			return "penalty_two"
		3:
			return "run_starter"
		5:
			if suit == Card.Suit.HEARTS:
				return "penalty_five"
		7:
			return "mirror"
		8:
			return "reverse"
		11:
			return "skip"

	return "normal"

## Create a test deck with specific cards for debugging
static func create_test_deck(card_specs: Array) -> Deck:
	var deck = Deck.new("Test Deck")

	for spec in card_specs:
		var rank = spec.get("rank", 1)
		var suit = spec.get("suit", Card.Suit.HEARTS)
		var count = spec.get("count", 1)

		for i in range(count):
			var suit_symbol = ["♥", "♦", "♣", "♠"][suit]
			var rank_name = _get_rank_name(rank)
			var card_name = "%s%s" % [rank_name, suit_symbol]
			var card_id = "%s_%d_%d" % [Card.Suit.keys()[suit].to_lower(), rank, i]

			var card = Card.new(card_id, card_name, suit, rank)
			card.set_property("is_trick_card", _is_trick_card(rank, suit))
			card.set_property("trick_type", _get_trick_type(rank, suit))

			deck.add_card(card)

	return deck

static func _get_rank_name(rank: int) -> String:
	match rank:
		1: return "A"
		11: return "J"
		12: return "Q"
		13: return "K"
		_: return str(rank)

## Helper function to create a deck with specific card distribution for testing
static func create_debug_deck() -> Deck:
	# Create a small deck good for testing Switch mechanics
	var specs = [
		{"rank": 1, "suit": Card.Suit.HEARTS, "count": 1},    # Ace of Hearts
		{"rank": 2, "suit": Card.Suit.HEARTS, "count": 1},    # 2 of Hearts (counters 5♥)
		{"rank": 2, "suit": Card.Suit.SPADES, "count": 1},    # 2 of Spades
		{"rank": 3, "suit": Card.Suit.CLUBS, "count": 2},     # 3s to start runs
		{"rank": 4, "suit": Card.Suit.DIAMONDS, "count": 2},  # 4s for run continuation
		{"rank": 5, "suit": Card.Suit.HEARTS, "count": 1},    # 5 of Hearts (special)
		{"rank": 5, "suit": Card.Suit.SPADES, "count": 1},    # Regular 5
		{"rank": 7, "suit": Card.Suit.CLUBS, "count": 1},     # Mirror card
		{"rank": 8, "suit": Card.Suit.DIAMONDS, "count": 1},  # Reverse
		{"rank": 11, "suit": Card.Suit.HEARTS, "count": 1},   # Jack (skip)
		{"rank": 13, "suit": Card.Suit.SPADES, "count": 1},   # King
		# Add some normal cards for variety
		{"rank": 6, "suit": Card.Suit.HEARTS, "count": 2},
		{"rank": 9, "suit": Card.Suit.DIAMONDS, "count": 2},
		{"rank": 10, "suit": Card.Suit.CLUBS, "count": 2},
	]

	return create_test_deck(specs)
