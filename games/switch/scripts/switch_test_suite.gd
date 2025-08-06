# scripts/switch_test_suite.gd
# Comprehensive test suite for Switch card game
extends Node

var test_framework: CardGameTestFramework

func _ready():
	test_framework = CardGameTestFramework.new()
	run_all_tests()

func run_all_tests():
	print("Starting Switch Game Test Suite...")
	
	# Core component tests
	test_card_creation()
	test_deck_operations()
	test_hand_operations()
	test_player_creation()
	
	# Factory tests
	test_switch_deck_factory()
	
	# Game setup tests
	test_game_setup()
	test_card_dealing()
	
	# Game rules tests
	test_basic_card_matching()
	test_ace_functionality()
	test_penalty_cards()
	
	# Print final results
	test_framework.print_summary()

## Test basic Card creation and properties
func test_card_creation():
	test_framework.start_test("Card Creation")
	
	var card = Card.new("test_1", "A♥", Card.Suit.HEARTS, 1)
	
	test_framework.assert_not_null(card, "Card created successfully")
	test_framework.assert_equal("test_1", card.id, "Card ID set correctly")
	test_framework.assert_equal("A♥", card.name, "Card name set correctly")
	test_framework.assert_equal(Card.Suit.HEARTS, card.suit, "Card suit set correctly")
	test_framework.assert_equal(1, card.rank, "Card rank set correctly")
	test_framework.assert_equal(Card.CardColor.RED, card.get_color(), "Hearts are red")

## Test Deck operations
func test_deck_operations():
	test_framework.start_test("Deck Operations")
	
	var deck = Deck.new("Test Deck")
	test_framework.assert_equal(0, deck.size(), "New deck is empty")
	
	# Add some cards
	var card1 = Card.new("c1", "A♥", Card.Suit.HEARTS, 1)
	var card2 = Card.new("c2", "2♠", Card.Suit.SPADES, 2)
	
	deck.add_card(card1)
	deck.add_card(card2)
	
	test_framework.assert_equal(2, deck.size(), "Deck has 2 cards after adding")
	test_framework.assert_equal(card2, deck.peek_top(), "Top card is the last added")
	test_framework.assert_equal(card1, deck.peek_bottom(), "Bottom card is the first added")
	
	# Test drawing
	var drawn_card = deck.draw_card()
	test_framework.assert_equal(card2, drawn_card, "Drew the top card")
	test_framework.assert_equal(1, deck.size(), "Deck has 1 card after drawing")

## Test Hand operations
func test_hand_operations():
	test_framework.start_test("Hand Operations")
	
	var hand = Hand.new("player1", 7)
	test_framework.assert_equal("player1", hand.owner_id, "Hand owner set correctly")
	test_framework.assert_equal(7, hand.max_size, "Hand max size set correctly")
	
	var cards = [
		Card.new("c1", "A♥", Card.Suit.HEARTS, 1),
		Card.new("c2", "2♠", Card.Suit.SPADES, 2),
		Card.new("c3", "3♣", Card.Suit.CLUBS, 3)
	]
	
	hand.add_cards(cards)
	test_framework.assert_equal(3, hand.size(), "Hand has 3 cards")
	test_framework.assert_true(hand.has_card(cards[0]), "Hand contains first card")

## Test Player creation and basic operations
func test_player_creation():
	test_framework.start_test("Player Creation")
	
	var player = Player.new("p1", "Alice", Player.PlayerType.HUMAN)
	
	test_framework.assert_not_null(player, "Player created successfully")
	test_framework.assert_equal("p1", player.id, "Player ID set correctly")
	test_framework.assert_equal("Alice", player.name, "Player name set correctly")
	test_framework.assert_equal(Player.PlayerType.HUMAN, player.player_type, "Player type set correctly")
	test_framework.assert_equal(0, player.get_hand_size(), "New player has empty hand")
	test_framework.assert_false(player.is_active, "New player is not active")

## Test Switch deck factory
func test_switch_deck_factory():
	test_framework.start_test("Switch Deck Factory")
	
	var deck = SwitchDeckFactory.create_switch_deck()
	
	test_framework.assert_not_null(deck, "Switch deck created")
	test_framework.assert_equal(52, deck.size(), "Switch deck has 52 cards")
	
	# Test debug deck
	var debug_deck = SwitchDeckFactory.create_debug_deck()
	test_framework.assert_not_null(debug_deck, "Debug deck created")
	test_framework.assert_true(debug_deck.size() > 0, "Debug deck has cards")
	
	# Check for specific cards
	var ace_hearts = debug_deck.find_card_by_id("hearts_1")
	test_framework.assert_not_null(ace_hearts, "Ace of Hearts exists in debug deck")
	
	var five_hearts = debug_deck.find_card_by_id("hearts_5")
	test_framework.assert_not_null(five_hearts, "5 of Hearts exists in debug deck")
	test_framework.assert_true(five_hearts.get_property("is_five_hearts", false), "5♥ marked as special")

## Test game setup process
func test_game_setup():
	test_framework.start_test("Game Setup")
	
	# Create components
	var player1 = Player.new("p1", "Alice", Player.PlayerType.HUMAN)
	var player2 = Player.new("p2", "Bob", Player.PlayerType.HUMAN)
	var players = [player1, player2]
	
	var deck = SwitchDeckFactory.create_debug_deck()
	var rules = SwitchGameRules.new()
	
	var game_manager = GameManager.new()
	
	# Test setup validation
	var setup_success = game_manager.setup_game(players, deck, rules)
	test_framework.assert_true(setup_success, "Game setup succeeds with valid input")
	
	# Test invalid setups
	var empty_players: Array[Player] = []
	var empty_deck = Deck.new("Empty")
	
	var invalid_setup1 = rules.validate_game_setup(empty_players, deck)
	test_framework.assert_false(invalid_setup1, "Setup fails with no players")
	
	var invalid_setup2 = rules.validate_game_setup(players, empty_deck)
	test_framework.assert_false(invalid_setup2, "Setup fails with empty deck")

## Test card dealing process
func test_card_dealing():
	test_framework.start_test("Card Dealing")
	
	# Create a controlled test environment
	var player1 = Player.new("p1", "Alice", Player.PlayerType.HUMAN)
	var player2 = Player.new("p2", "Bob", Player.PlayerType.HUMAN)
	var players = [player1, player2]
	
	# Create a deck with known size
	var test_specs = [
		{"rank": 1, "suit": Card.Suit.HEARTS, "count": 4},  # 4 Aces
		{"rank": 2, "suit": Card.Suit.SPADES, "count": 4},  # 4 Twos
		{"rank": 3, "suit": Card.Suit.CLUBS, "count": 4},   # 4 Threes
		{"rank": 4, "suit": Card.Suit.DIAMONDS, "count": 3} # 3 Fours
	]
	var deck = SwitchDeckFactory.create_test_deck(test_specs)
	var initial_deck_size = deck.size()
	
	print("Created test deck with %d cards" % initial_deck_size)
	
	var rules = SwitchGameRules.new()
	rules.set_main_deck(deck)
	rules.set_players(players)
	
	# Manually call setup to test dealing
	rules.setup_game(players, deck)
	
	# Check that cards were dealt correctly
	var expected_cards_per_player = 7  # 2 players, so 7 cards each
	test_framework.assert_equal(expected_cards_per_player, player1.get_hand_size(), "Player 1 has correct hand size")
	test_framework.assert_equal(expected_cards_per_player, player2.get_hand_size(), "Player 2 has correct hand size")
	
	# Check that deck size decreased appropriately (14 cards to players + 1 for play stack)
	var expected_remaining = initial_deck_size - (expected_cards_per_player * 2) - 1
	test_framework.assert_equal(expected_remaining, deck.size(), "Deck size correct after dealing")
	
	# Check that top card exists
	var top_card = rules.get_active_top_card()
	test_framework.assert_not_null(top_card, "Active top card exists")

## Test basic card matching rules
func test_basic_card_matching():
	test_framework.start_test("Basic Card Matching")
	
	var ace_hearts = Card.new("ah", "A♥", Card.Suit.HEARTS, 1)
	var two_hearts = Card.new("2h", "2♥", Card.Suit.HEARTS, 2)
	var two_spades = Card.new("2s", "2♠", Card.Suit.SPADES, 2)
	var three_clubs = Card.new("3c", "3♣", Card.Suit.CLUBS, 3)
	
	# Test suit matching
	test_framework.assert_true(ace_hearts.matches_suit(two_hearts), "Same suit cards match")
	test_framework.assert_false(ace_hearts.matches_suit(two_spades), "Different suit cards don't match")
	
	# Test rank matching
	test_framework.assert_true(two_hearts.matches_rank(two_spades), "Same rank cards match")
	test_framework.assert_false(two_hearts.matches_rank(three_clubs), "Different rank cards don't match")

## Test Ace functionality
func test_ace_functionality():
	test_framework.start_test("Ace Functionality")
	
	var player = Player.new("p1", "Alice", Player.PlayerType.HUMAN)
	var ace_hearts = Card.new("ah", "A♥", Card.Suit.HEARTS, 1)
	var two_spades = Card.new("2s", "2♠", Card.Suit.SPADES, 2)
	
	var rules = SwitchGameRules.new()
	
	# Aces should be universal (playable on any card during normal play)
	var can_play_ace = rules._is_valid_normal_play(ace_hearts, two_spades)
	test_framework.assert_true(can_play_ace, "Ace can be played on any card")

## Test penalty card functionality
func test_penalty_cards():
	test_framework.start_test("Penalty Cards")
	
	var rules = SwitchGameRules.new()
	
	# Test 5♥ identification
	var five_hearts = Card.new("5h", "5♥", Card.Suit.HEARTS, 5)
	var five_spades = Card.new("5s", "5♠", Card.Suit.SPADES, 5)
	
	test_framework.assert_true(rules._is_five_of_hearts(five_hearts), "5♥ identified correctly")
	test_framework.assert_false(rules._is_five_of_hearts(five_spades), "5♠ is not 5♥")
	
	# Test 2♥ identification
	var two_hearts = Card.new("2h", "2♥", Card.Suit.HEARTS, 2)
	var two_spades = Card.new("2s", "2♠", Card.Suit.SPADES, 2)
	
	test_framework.assert_true(rules._is_two_of_hearts(two_hearts), "2♥ identified correctly")
	test_framework.assert_false(rules._is_two_of_hearts(two_spades), "2♠ is not 2♥")
