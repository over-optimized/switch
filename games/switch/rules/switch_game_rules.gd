# addons/card_game_foundation/games/switch/switch_game_rules.gd
class_name SwitchGameRules extends GameRules

## Switch card game implementation
## Handles all Switch-specific rules and trick cards

enum GamePhase { NORMAL, ACTIVE_TWOS, ACTIVE_RUN, ACTIVE_FIVE_HEARTS }
enum TurnDirection { LEFT, RIGHT }

# Game state tracking
var current_phase: GamePhase = GamePhase.NORMAL
var turn_direction: TurnDirection = TurnDirection.LEFT
var played_cards_stack: Array[Card] = []
var active_penalty: int = 0
var run_target_rank: int = 0
var chosen_suit: Card.Suit = Card.Suit.NONE

signal suit_choice_required(player: Player, ace_card: Card)
signal penalty_applied(player: Player, amount: int)
signal run_started(starting_rank: int)
signal run_ended(successful: bool)
signal direction_changed(new_direction: TurnDirection)

## Setup the game with Switch-specific rules
func setup_game(players: Array[Player], deck: Deck) -> void:
	print("=== SETUP_GAME DEBUG ===")
	print("Players count: %d" % players.size())
	print("Deck size before dealing: %d" % deck.size())

	# Deal cards based on player count
	var cards_per_player = 7 if players.size() <= 3 else 5
	print("Cards per player: %d" % cards_per_player)

	deck.shuffle()
	print("Deck shuffled")

	# Deal cards to players
	for i in range(players.size()):
		var player = players[i]
		print("Dealing to player %s..." % player.name)

		var cards_to_deal = deck.draw_cards(cards_per_player)
		print("  Drew %d cards from deck" % cards_to_deal.size())
		print("  Deck size after drawing: %d" % deck.size())

		player.deal_cards(cards_to_deal)
		print("  Player %s now has %d cards" % [player.name, player.get_hand_size()])

		# Debug: Print the actual cards
		var card_names = []
		for card in player.hand.cards:
			if card:
				card_names.append(card.name)
		print("  Cards: [%s]" % ", ".join(card_names))

	# Start played cards stack with first card
	print("Drawing first card for played stack...")
	var first_card = deck.draw_card()
	if first_card:
		print("First card: %s" % first_card.name)
		played_cards_stack.append(first_card)

		# Handle starting with trick card
		_handle_starting_card(first_card)
	else:
		print("ERROR: No first card available!")

	print("Final deck size: %d" % deck.size())
	print("=== SETUP_GAME DEBUG END ===\n")

## Get the active top card for matching
func get_active_top_card() -> Card:
	if played_cards_stack.is_empty():
		return null
	return played_cards_stack.back()

## Check if a move is valid
func is_valid_move(player: Player, card: Card, game_data: Dictionary) -> bool:
	if not player or not card:
		return false

	if not player.has_cards() or not player.hand.has_card(card):
		return false

	var top_card = get_active_top_card()
	if not top_card:
		return true  # First card is always valid

	return _is_card_playable(card, top_card)

## Check if a specific card can be played on the current top card
func _is_card_playable(card: Card, top_card: Card) -> bool:
	match current_phase:
		GamePhase.NORMAL:
			return _is_valid_normal_play(card, top_card)
		GamePhase.ACTIVE_TWOS:
			return _is_valid_during_active_twos(card)
		GamePhase.ACTIVE_RUN:
			return _is_valid_during_run(card)
		GamePhase.ACTIVE_FIVE_HEARTS:
			return _is_valid_during_five_hearts(card)

	return false

## Normal play validation
func _is_valid_normal_play(card: Card, top_card: Card) -> bool:
	# Universal cards (can be played on anything when not active trick)
	if _is_universal_card(card):
		return true

	# Special case: 5♥ can be played on any 5 or any ♥
	if _is_five_of_hearts(card):
		return top_card.rank == 5 or top_card.suit == Card.Suit.HEARTS

	# Normal matching: suit or rank
	return card.matches_suit(top_card) or card.matches_rank(top_card)

## Check if card is universal (Ace, 7)
func _is_universal_card(card: Card) -> bool:
	return card.rank == 1 or card.rank == 7  # Ace or 7

## Active 2s validation
func _is_valid_during_active_twos(card: Card) -> bool:
	return card.rank == 2 or _is_two_of_hearts(card)  # Any 2 or 2♥ (which counters 5♥)

## Active run validation
func _is_valid_during_run(card: Card) -> bool:
	# Must be current rank or next sequential rank
	return card.rank == run_target_rank or card.rank == run_target_rank + 1

## Active 5♥ validation
func _is_valid_during_five_hearts(card: Card) -> bool:
	return _is_two_of_hearts(card)  # Only 2♥ can counter 5♥

## Apply a move and update game state
func apply_move(player: Player, card: Card, game_data: Dictionary) -> Dictionary:
	if not player or not card:
		push_error("Invalid player or card in apply_move")
		return game_data

	played_cards_stack.append(card)

	# Handle card effects
	_handle_card_effect(card, player)

	# Update game data
	game_data["last_played_card"] = card
	game_data["last_player"] = player

	return game_data

## Handle special card effects
func _handle_card_effect(card: Card, player: Player) -> void:
	# During runs, most cards lose their special powers
	if current_phase == GamePhase.ACTIVE_RUN:
		_handle_run_card(card, player)
		return

	match card.rank:
		1:  # Ace
			_handle_ace(card, player)
		2:  # 2
			_handle_two(card, player)
		3:  # 3
			_handle_three(card, player)
		7:  # 7
			_handle_seven(card, player)
		8:  # 8
			_handle_eight(card, player)
		11: # Jack
			_handle_jack(card, player)
		_:
			# Check for 5♥
			if _is_five_of_hearts(card):
				_handle_five_of_hearts(card, player)

## Handle Ace effects
func _handle_ace(card: Card, player: Player) -> void:
	# Aces require suit choice
	suit_choice_required.emit(player, card)
	# Suit will be set via choose_suit() method

## Handle 2 effects
func _handle_two(card: Card, player: Player) -> void:
	if current_phase == GamePhase.ACTIVE_FIVE_HEARTS and _is_two_of_hearts(card):
		# 2♥ counters 5♥, but also continues as a 2
		current_phase = GamePhase.ACTIVE_TWOS
		active_penalty = 2  # Reset penalty to 2 for the 2♥
	elif current_phase == GamePhase.ACTIVE_TWOS:
		# Stack with existing 2s
		active_penalty += 2
	else:
		# Start new 2s sequence
		current_phase = GamePhase.ACTIVE_TWOS
		active_penalty = 2

## Handle 3 effects (start run)
func _handle_three(card: Card, player: Player) -> void:
	current_phase = GamePhase.ACTIVE_RUN
	run_target_rank = 3
	run_started.emit(3)

## Handle 5♥ effects
func _handle_five_of_hearts(card: Card, player: Player) -> void:
	if current_phase == GamePhase.ACTIVE_TWOS:
		# 5♥ can be played on 2♥ to chain
		current_phase = GamePhase.ACTIVE_FIVE_HEARTS
		active_penalty += 5  # Add to existing penalty
	else:
		# Start new 5♥ penalty
		current_phase = GamePhase.ACTIVE_FIVE_HEARTS
		active_penalty = 5

## Handle 7 effects (mirror)
func _handle_seven(card: Card, player: Player) -> void:
	var previous_card = _get_previous_card()
	if previous_card:
		# Mirror the rank and suit (not the effect)
		chosen_suit = previous_card.suit

## Handle 8 effects (reverse direction)
func _handle_eight(card: Card, player: Player) -> void:
	# Each 8 toggles direction
	turn_direction = TurnDirection.RIGHT if turn_direction == TurnDirection.LEFT else TurnDirection.LEFT
	direction_changed.emit(turn_direction)

## Handle Jack effects (skip next player)
func _handle_jack(card: Card, player: Player) -> void:
	# Jacks will be handled in turn order logic
	pass

## Handle cards during active run
func _handle_run_card(card: Card, player: Player) -> void:
	if card.rank == run_target_rank:
		# Same rank - continue run
		pass
	elif card.rank == run_target_rank + 1:
		# Next rank - advance run
		run_target_rank = card.rank

		# Check if run has ended (reached Ace)
		if card.rank == 1:  # Ace ends the run
			_end_run(true)
	else:
		# Invalid run card - shouldn't happen if validation worked
		push_error("Invalid run card played: %s" % card.name)

## Get the card played before the current top card
func _get_previous_card() -> Card:
	if played_cards_stack.size() < 2:
		return null
	return played_cards_stack[played_cards_stack.size() - 2]

## End the current run
func _end_run(successful: bool) -> void:
	current_phase = GamePhase.NORMAL
	run_target_rank = 0
	run_ended.emit(successful)

## Choose suit for Ace
func choose_suit(suit: Card.Suit) -> void:
	chosen_suit = suit

## Get valid moves for a player
func get_valid_moves(player: Player, game_data: Dictionary) -> Array[Card]:
	var valid_moves: Array[Card] = []
	var top_card = get_active_top_card()

	if not top_card:
		return player.hand.cards.duplicate()  # All cards valid for first play

	for card in player.hand.cards:
		if _is_card_playable(card, top_card):
			valid_moves.append(card)

	return valid_moves

## Get turn order considering direction and skips
func get_turn_order(players: Array[Player], game_data: Dictionary) -> Array[Player]:
	var ordered_players = players.duplicate()

	if turn_direction == TurnDirection.RIGHT:
		ordered_players.reverse()

	return ordered_players

## Check if game is over
func is_game_over(game_data: Dictionary) -> bool:
	# Game ends when a player has no cards and didn't finish on a trick card
	for player in get_all_players():
		if player and not player.has_cards():
			var last_card = player.get_last_played_card()
			# Can't finish on trick card during active run
			if current_phase == GamePhase.ACTIVE_RUN and last_card:
				# Force pickup of 1 card - use the corrected method name
				apply_penalty_to_player(player, 1)
				return false
			return true

	return false

## Get winner(s)
func get_winner(players: Array[Player], game_data: Dictionary) -> Array[Player]:
	var winners: Array[Player] = []
	for player in players:
		if not player.has_cards():
			winners.append(player)
	return winners

var main_deck: Deck  # Reference to main deck for drawing cards

## Set the main deck reference (called by GameManager)
func set_main_deck(deck: Deck) -> void:
	main_deck = deck

## Apply penalty to player (corrected method name)
func apply_penalty_to_player(player: Player, amount: int) -> bool:
	if not main_deck:
		push_error("No main deck available for penalty")
		return false

	# Check if we need to reshuffle
	if main_deck.size() < amount:
		_reshuffle_deck()

	# Draw cards for penalty
	var penalty_cards = main_deck.draw_cards(amount)
	player.deal_cards(penalty_cards)

	penalty_applied.emit(player, amount)
	return true

## Reshuffle deck from played cards (keeping top card)
func _reshuffle_deck() -> void:
	if played_cards_stack.size() <= 1:
		push_warning("Cannot reshuffle - not enough played cards")
		return

	# Keep top card, reshuffle the rest
	var top_card = played_cards_stack.pop_back()

	# Move played cards back to main deck
	for card in played_cards_stack:
		main_deck.add_card(card)

	# Clear played cards and put top card back
	played_cards_stack.clear()
	played_cards_stack.append(top_card)

	# Shuffle the deck
	main_deck.shuffle()
	print("Deck reshuffled - %d cards available" % main_deck.size())

## Handle starting card effects
func _handle_starting_card(card: Card) -> void:
	# If game starts with trick card, handle appropriately
	match card.rank:
		2:
			current_phase = GamePhase.ACTIVE_TWOS
			active_penalty = 2
		3:
			current_phase = GamePhase.ACTIVE_RUN
			run_target_rank = 3
			run_started.emit(3)
		_:
			if _is_five_of_hearts(card):
				current_phase = GamePhase.ACTIVE_FIVE_HEARTS
				active_penalty = 5

## Process end of turn penalties and phase transitions
func process_turn_end(current_player: Player) -> Player:
	var next_player = current_player  # May change based on penalties

	match current_phase:
		GamePhase.ACTIVE_TWOS:
			# Next player must either play 2 or take penalty
			var valid_moves = get_valid_moves(next_player, {})
			if valid_moves.is_empty():
				# No valid 2s, must take penalty
				apply_penalty_to_player(next_player, active_penalty)
				current_phase = GamePhase.NORMAL
				active_penalty = 0

		GamePhase.ACTIVE_FIVE_HEARTS:
			# Next player must play 2♥ or take penalty
			var valid_moves = get_valid_moves(next_player, {})
			if valid_moves.is_empty():
				# No 2♥, must take penalty
				apply_penalty_to_player(next_player, active_penalty)
				current_phase = GamePhase.NORMAL
				active_penalty = 0

		GamePhase.ACTIVE_RUN:
			# Check if player can continue run
			var valid_moves = get_valid_moves(next_player, {})
			if valid_moves.is_empty():
				# Can't continue run, take penalty
				apply_penalty_to_player(next_player, run_target_rank)
				_end_run(false)

	return next_player

## Utility functions
func _is_five_of_hearts(card: Card) -> bool:
	return card.rank == 5 and card.suit == Card.Suit.HEARTS

func _is_two_of_hearts(card: Card) -> bool:
	return card.rank == 2 and card.suit == Card.Suit.HEARTS

## Validate game setup
func validate_game_setup(players: Array[Player], deck: Deck) -> bool:
	if players.size() < 2:
		push_error("Switch requires at least 2 players")
		return false

	var cards_needed = (7 if players.size() <= 3 else 5) * players.size() + 1
	if deck.size() < cards_needed:
		push_error("Not enough cards in deck for %d players" % players.size())
		return false

	return true

var all_players: Array[Player] = []  # Reference to all players

## Set players reference (called by GameManager)
func set_players(players: Array[Player]) -> void:
	all_players = players

## Get all players (helper for winner checking)
func get_all_players() -> Array[Player]:
	return all_players
