# test_switch_game.gd
# Place this in your main project (not in the addon)
extends Node

var game_manager: GameManager
var switch_rules: SwitchGameRules
var players: Array[Player] = []

func _ready():
	print("=== Switch Game Test ===")
	_setup_test_game()
	_run_test_scenarios()

func _setup_test_game():
	# Create players
	var player1 = Player.new("p1", "Alice", Player.PlayerType.HUMAN)
	var player2 = Player.new("p2", "Bob", Player.PlayerType.HUMAN)
	players = [player1, player2]
	
	# Create deck
	var deck = SwitchDeckFactory.create_debug_deck()
	deck.shuffle()
	
	print("Created deck with %d cards" % deck.size())
	
	# Create game rules
	switch_rules = SwitchGameRules.new()
	
	# Connect signals for debugging
	switch_rules.suit_choice_required.connect(_on_suit_choice_required)
	switch_rules.penalty_applied.connect(_on_penalty_applied)
	switch_rules.run_started.connect(_on_run_started)
	switch_rules.run_ended.connect(_on_run_ended)
	switch_rules.direction_changed.connect(_on_direction_changed)
	
	# Create game manager
	game_manager = GameManager.new()
	add_child(game_manager)
	
	# Setup game
	if game_manager.setup_game(players, deck, switch_rules):
		print("Game setup successful!")
		
		# Pass references to switch rules
		switch_rules.set_main_deck(deck)
		switch_rules.set_players(players)
		
		_print_initial_hands()
	else:
		print("Game setup failed!")

func _print_initial_hands():
	print("\n--- Initial Hands ---")
	for player in players:
		print("%s: %s" % [player.name, _format_hand(player.hand)])
	print("Top card: %s" % switch_rules.get_active_top_card().name)
	print("Game phase: %s" % SwitchGameRules.GamePhase.keys()[switch_rules.current_phase])

func _format_hand(hand: Hand) -> String:
	var card_names = []
	for card in hand.cards:
		card_names.append(card.name)
	return "[%s]" % ", ".join(card_names)

func _run_test_scenarios():
	print("\n=== Testing Basic Mechanics ===")
	
	# Start the game
	game_manager.start_game()
	
	# Test a few moves
	_test_basic_play()
	_test_trick_cards()

func _test_basic_play():
	print("\n--- Testing Basic Play ---")
	
	var current_player = game_manager.current_player
	var valid_moves = game_manager.get_valid_moves_for_current_player()
	
	print("%s's turn" % current_player.name)
	print("Valid moves: %s" % _format_card_array(valid_moves))
	
	if not valid_moves.is_empty():
		var card_to_play = valid_moves[0]
		print("Playing: %s" % card_to_play.name)
		
		if game_manager.make_move(card_to_play):
			print("Move successful!")
			print("New top card: %s" % switch_rules.get_active_top_card().name)
		else:
			print("Move failed!")

func _test_trick_cards():
	print("\n--- Testing Trick Cards ---")
	
	# Try to find and play trick cards
	for player in players:
		for card in player.hand.cards:
			if card.get_property("is_trick_card", false):
				print("Found trick card: %s (%s)" % [card.name, card.get_property("trick_type", "unknown")])

func _format_card_array(cards: Array[Card]) -> String:
	var names = []
	for card in cards:
		names.append(card.name)
	return "[%s]" % ", ".join(names)

# Signal handlers for game events
func _on_suit_choice_required(player: Player, ace_card: Card):
	print("SUIT CHOICE: %s played %s, needs to choose suit" % [player.name, ace_card.name])
	# For testing, just choose Hearts
	switch_rules.choose_suit(Card.Suit.HEARTS)
	print("Chose Hearts")

func _on_penalty_applied(player: Player, amount: int):
	print("PENALTY: %s must pick up %d cards" % [player.name, amount])

func _on_run_started(starting_rank: int):
	print("RUN STARTED: Starting with rank %d" % starting_rank)

func _on_run_ended(successful: bool):
	print("RUN ENDED: %s" % ("Successful" if successful else "Failed"))

func _on_direction_changed(new_direction):
	var direction_name = "Left" if new_direction == SwitchGameRules.TurnDirection.LEFT else "Right"
	print("DIRECTION CHANGED: Now going %s" % direction_name)

# Input handling for interactive testing
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space or Enter
		print("\n--- Manual Turn ---")
		_take_manual_turn()
	elif event.is_action_pressed("ui_cancel"):  # Escape
		print("\n--- Game State ---")
		_print_game_state()

func _take_manual_turn():
	if game_manager.current_state != GameManager.GameState.IN_PROGRESS:
		print("Game not in progress")
		return
	
	var current_player = game_manager.current_player
	var valid_moves = game_manager.get_valid_moves_for_current_player()
	
	print("%s's turn" % current_player.name)
	print("Hand: %s" % _format_hand(current_player.hand))
	print("Valid moves: %s" % _format_card_array(valid_moves))
	
	if valid_moves.is_empty():
		print("No valid moves - would need to draw card")
		return
	
	# For testing, just play the first valid move
	var card_to_play = valid_moves[0]
	print("Auto-playing: %s" % card_to_play.name)
	
	if game_manager.make_move(card_to_play):
		print("Move successful!")
		_print_game_state()
	else:
		print("Move failed!")

func _print_game_state():
	print("=== Current Game State ===")
	print("Phase: %s" % SwitchGameRules.GamePhase.keys()[switch_rules.current_phase])
	print("Direction: %s" % ("Left" if switch_rules.turn_direction == SwitchGameRules.TurnDirection.LEFT else "Right"))
	print("Top card: %s" % switch_rules.get_active_top_card().name)
	
	if switch_rules.active_penalty > 0:
		print("Active penalty: %d cards" % switch_rules.active_penalty)
	
	if switch_rules.current_phase == SwitchGameRules.GamePhase.ACTIVE_RUN:
		print("Run target rank: %d" % switch_rules.run_target_rank)
	
	print("\n--- Player Hands ---")
	for i in range(players.size()):
		var player = players[i]
		var indicator = " <- CURRENT" if player == game_manager.current_player else ""
		print("%s (%d cards): %s%s" % [player.name, player.get_hand_size(), _format_hand(player.hand), indicator])
	
	if game_manager.current_state == GameManager.GameState.ENDED:
		print("\n*** GAME OVER ***")
		var winners = switch_rules.get_winner(players, {})
		if not winners.is_empty():
			print("Winner: %s" % winners[0].name)
