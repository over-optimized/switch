# addons/card_game_foundation/factories/standard_deck_factory.gd
class_name StandardDeckFactory
extends RefCounted

## Factory class for creating standard 52-card decks
## Easily extensible for custom deck types

static func create_standard_deck() -> Deck:
	var deck = Deck.new("Standard 52-Card Deck")
	
	# Define rank names
	var rank_names = {
		1: "Ace", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7",
		8: "8", 9: "9", 10: "10", 11: "Jack", 12: "Queen", 13: "King"
	}
	
	# Create cards for each suit
	for suit in [Card.Suit.HEARTS, Card.Suit.DIAMONDS, Card.Suit.CLUBS, Card.Suit.SPADES]:
		for rank in range(1, 14):
			var suit_name = Card.Suit.keys()[suit].capitalize()
			var rank_name = rank_names[rank]
			var card_name = "%s of %s" % [rank_name, suit_name]
			var card_id = "%s_%d" % [Card.Suit.keys()[suit].to_lower(), rank]
			
			var card = Card.new(card_id, card_name, suit, rank)
			deck.add_card(card)
	
	return deck

static func create_pinochle_deck() -> Deck:
	var deck = Deck.new("Pinochle Deck")
	
	# Pinochle uses 9, 10, J, Q, K, A (ranks 9-14, with Ace high)
	var rank_names = {
		9: "9", 10: "10", 11: "Jack", 12: "Queen", 13: "King", 14: "Ace"
	}
	
	# Two copies of each card
	for copy in range(2):
		for suit in [Card.Suit.HEARTS, Card.Suit.DIAMONDS, Card.Suit.CLUBS, Card.Suit.SPADES]:
			for rank in [9, 10, 11, 12, 13, 14]:
				var suit_name = Card.Suit.keys()[suit].capitalize()
				var rank_name = rank_names[rank]
				var card_name = "%s of %s" % [rank_name, suit_name]
				var card_id = "%s_%d_%d" % [Card.Suit.keys()[suit].to_lower(), rank, copy + 1]
				
				var card = Card.new(card_id, card_name, suit, rank)
				deck.add_card(card)
	
	return deck

static func create_uno_deck() -> Deck:
	var deck = Deck.new("Uno Deck")
	
	# Uno has colored cards (0-9) and special cards
	var colors = ["red", "yellow", "green", "blue"]
	
	# Number cards (0-9)
	for color in colors:
		# One 0 card per color
		var zero_card = Card.new("%s_0" % color, "%s 0" % color.capitalize(), Card.Suit.NONE, 0)
		zero_card.set_property("color", color)
		deck.add_card(zero_card)
		
		# Two of each 1-9 per color
		for number in range(1, 10):
			for copy in range(2):
				var card_id = "%s_%d_%d" % [color, number, copy + 1]
				var card_name = "%s %d" % [color.capitalize(), number]
				var card = Card.new(card_id, card_name, Card.Suit.NONE, number)
				card.set_property("color", color)
				deck.add_card(card)
		
		# Special cards (2 of each per color)
		var special_cards = ["Skip", "Reverse", "Draw Two"]
		for special in special_cards:
			for copy in range(2):
				var card_id = "%s_%s_%d" % [color, special.to_lower().replace(" ", "_"), copy + 1]
				var card_name = "%s %s" % [color.capitalize(), special]
				var card = Card.new(card_id, card_name, Card.Suit.NONE, 20 + special_cards.find(special))
				card.set_property("color", color)
				card.set_property("special", special.to_lower().replace(" ", "_"))
				deck.add_card(card)
	
	# Wild cards (4 each)
	for i in range(4):
		var wild_card = Card.new("wild_%d" % (i + 1), "Wild", Card.Suit.NONE, 50)
		wild_card.set_property("color", "wild")
		wild_card.set_property("special", "wild")
		deck.add_card(wild_card)
		
		var wild_draw_four = Card.new("wild_draw_four_%d" % (i + 1), "Wild Draw Four", Card.Suit.NONE, 51)
		wild_draw_four.set_property("color", "wild")
		wild_draw_four.set_property("special", "wild_draw_four")
		deck.add_card(wild_draw_four)
	
	return deck

static func create_custom_deck(card_definitions: Array[Dictionary]) -> Deck:
	var deck = Deck.new("Custom Deck")
	
	for definition in card_definitions:
		var card = Card.new(
			definition.get("id", ""),
			definition.get("name", ""),
			definition.get("suit", Card.Suit.NONE),
			definition.get("rank", 0)
		)
		
		# Add any custom properties
		if definition.has("properties"):
			for key in definition.properties:
				card.set_property(key, definition.properties[key])
		
		deck.add_card(card)
	
	return deck
