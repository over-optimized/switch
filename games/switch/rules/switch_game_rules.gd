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

# Additional run tracking properties
var run_sequence: Array[int] = []  # Track the actual sequence played
var run_started_by: Player = null
var cards_played_in_current_turn: Array[Card] = []

# Add these properties to track mirror state
var mirrored_suit: Card.Suit = Card.Suit.NONE
var mirrored_rank: int = 0
var is_top_card_mirrored: bool = false

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
			return _is_valid_normal_play_with_mirroring(card, top_card)
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

## Normal play validation with mirroring support
func _is_valid_normal_play_with_mirroring(card: Card, top_card: Card) -> bool:
	# Universal cards (can be played on anything when not active trick)
	if _is_universal_card(card):
		return true

	# Special case: 5♥ can be played on any 5 or any ♥
	if _is_five_of_hearts(card):
		var effective_rank = get_effective_rank()
		var effective_suit = get_effective_suit()
		return effective_rank == 5 or effective_suit == Card.Suit.HEARTS

	# Normal matching using effective rank/suit
	var effective_rank = get_effective_rank()
	var effective_suit = get_effective_suit()

	return card.rank == effective_rank or card.suit == effective_suit

## Check if card is universal (Ace, 7)
func _is_universal_card(card: Card) -> bool:
	return card.rank == 1 or card.rank == 7  # Ace or 7

## Active 2s validation
func _is_valid_during_active_twos(card: Card) -> bool:
	return card.rank == 2 or _is_two_of_hearts(card)  # Any 2 or 2♥ (which counters 5♥)

## Active run validation with complete sequence checking
func _is_valid_during_run(card: Card) -> bool:
	# Special case: Aces can only be played on King or other Aces during runs
	if card.rank == 1:  # Ace
		return run_target_rank == 13 or run_target_rank == 1  # King or Ace

	# Normal run rules: current rank or next sequential rank
	var valid_ranks = [run_target_rank]

	# Add next sequential rank if not at end of sequence
	if run_target_rank < 13:  # Not King
		valid_ranks.append(run_target_rank + 1)
	elif run_target_rank == 13:  # King
		valid_ranks.append(1)  # King -> Ace

	return card.rank in valid_ranks

## Active 5♥ validation
func _is_valid_during_five_hearts(card: Card) -> bool:
	return _is_two_of_hearts(card)  # Only 2♥ can counter 5♥

## Apply a move and update game state
func apply_move(player: Player, card: Card, game_data: Dictionary) -> Dictionary:
	if not player or not card:
		push_error("Invalid player or card in apply_move")
		return game_data

	# Reset mirror state if playing non-7 card
	if card.rank != 7:
		is_top_card_mirrored = false
		mirrored_rank = 0
		mirrored_suit = Card.Suit.NONE

	# Reset Ace chosen suit if playing non-Ace card
	if card.rank != 1:
		chosen_suit = Card.Suit.NONE

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
	run_sequence = [3]
	run_started_by = player
	cards_played_in_current_turn.clear()
	cards_played_in_current_turn.append(card)

	run_started.emit(3)
	print("RUN STARTED: %s started run with %s" % [player.name, card.name])

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
	var target_card = _get_card_to_mirror()

	if target_card:
		# Mirror the target card's rank and suit
		mirrored_rank = target_card.rank
		mirrored_suit = target_card.suit
		is_top_card_mirrored = true

		print("7 MIRROR: %s mirrors %s (becomes %d%s)" % [
			card.name,
			target_card.name,
			mirrored_rank,
			_get_suit_symbol(mirrored_suit)
		])
	else:
		push_warning("7 played but no card to mirror")
		# Fallback - 7 just becomes itself
		mirrored_rank = 7
		mirrored_suit = card.suit
		is_top_card_mirrored = false

## Get the card that 7 should mirror
func _get_card_to_mirror() -> Card:
	# Mirror the card that was played before the 7
	# Skip over any other 7s to find the original card

	for i in range(played_cards_stack.size() - 2, -1, -1):  # Start from second-to-last
		var card = played_cards_stack[i]
		if card && card.rank != 7:  # Found non-7 card
			return card

	# If all previous cards are 7s, mirror the very first card
	if not played_cards_stack.is_empty():
		return played_cards_stack[0]

	return null

## Get effective suit for matching (accounts for mirroring and Ace choices)
func get_effective_suit() -> Card.Suit:
	var top_card = get_active_top_card()
	if not top_card:
		return Card.Suit.NONE

	# Check if top card is mirrored (7)
	if is_top_card_mirrored:
		return mirrored_suit

	# Check if top card is an Ace with chosen suit
	if top_card.rank == 1 && chosen_suit != Card.Suit.NONE:
		return chosen_suit

	# Normal card suit
	return top_card.suit

## Get effective rank for matching (accounts for mirroring)
func get_effective_rank() -> int:
	var top_card = get_active_top_card()
	if not top_card:
		return 0

	# Check if top card is mirrored (7)
	if is_top_card_mirrored:
		return mirrored_rank

	# Normal card rank
	return top_card.rank

## Helper function to get suit symbol for display
func _get_suit_symbol(suit: Card.Suit) -> String:
	match suit:
		Card.Suit.HEARTS:
			return "♥"
		Card.Suit.DIAMONDS:
			return "♦"
		Card.Suit.CLUBS:
			return "♣"
		Card.Suit.SPADES:
			return "♠"
		_:
			return "?"

## Handle 8 effects (reverse direction)
func _handle_eight(card: Card, player: Player) -> void:
	# Each 8 toggles direction
	turn_direction = TurnDirection.RIGHT if turn_direction == TurnDirection.LEFT else TurnDirection.LEFT
	direction_changed.emit(turn_direction)

## Handle Jack effects (skip next player)
func _handle_jack(card: Card, player: Player) -> void:
	# Jacks will be handled in turn order logic
	pass

## Handle cards during active run (includes sequence tracking)
func _handle_run_card(card: Card, player: Player) -> void:
	cards_played_in_current_turn.append(card)

	if card.rank == run_target_rank:
		# Same rank - continue run at same level
		print("RUN CONTINUE: %s played another %d" % [player.name, card.rank])

	elif card.rank == run_target_rank + 1 or (run_target_rank == 13 and card.rank == 1):
		# Next rank - advance run
		var old_rank = run_target_rank
		run_target_rank = card.rank
		run_sequence.append(card.rank)

		print("RUN ADVANCE: %s advanced from %d to %d" % [player.name, old_rank, card.rank])

		# Check if run has ended (reached Ace)
		if card.rank == 1:  # Ace ends the run
			_end_run(true)

	elif card.rank == 1 and run_target_rank in [13, 1]:
		# Ace on King or Ace (legal)
		if run_target_rank == 13:  # King -> Ace advances
			run_target_rank = 1
			run_sequence.append(1)
			print("RUN ADVANCE: %s played Ace to end run" % player.name)
		else:  # Ace -> Ace continues
			print("RUN CONTINUE: %s played another Ace" % player.name)

		_end_run(true)

	else:
		# This should not happen if validation worked correctly
		push_error("Invalid run card played: %s (target rank: %d)" % [card.name, run_target_rank])
		_handle_invalid_run_sequence(player, card)

## Handle invalid run sequences with proper penalties
func _handle_invalid_run_sequence(player: Player, invalid_card: Card) -> void:
	print("INVALID RUN: %s played %s when %d was required" % [
		player.name, invalid_card.name, run_target_rank
	])

	# Calculate penalty: invalid cards + run penalty + 2 stupid cards
	var cards_to_return = cards_played_in_current_turn.size()
	var run_penalty = run_target_rank
	var stupid_penalty = 2
	var total_penalty = cards_to_return + run_penalty + stupid_penalty

	# Return the invalid cards to player's hand first
	for card in cards_played_in_current_turn:
		if played_cards_stack.has(card):
			played_cards_stack.erase(card)
			player.hand.add_card(card)

	# Apply additional penalty
	var additional_penalty = run_penalty + stupid_penalty
	if not apply_penalty_to_player(player, additional_penalty):
		push_error("Failed to apply invalid run penalty")

	print("RUN PENALTY: %s returns %d cards and picks up %d more" % [
		player.name, cards_to_return, additional_penalty
	])

	# End the run
	_end_run(false)

## End the current run with proper cleanup
func _end_run(successful: bool) -> void:
	var final_rank = run_target_rank
	var sequence_length = run_sequence.size()

	print("RUN ENDED: %s, final rank %d, sequence length %d" % [
		"Successfully" if successful else "Failed",
		final_rank,
		sequence_length
	])

	# Reset run state
	current_phase = GamePhase.NORMAL
	run_target_rank = 0
	run_sequence.clear()
	run_started_by = null
	cards_played_in_current_turn.clear()

	run_ended.emit(successful)

	# If run failed, top card becomes dead
	if not successful:
		var top_card = get_active_top_card()
		if top_card:
			print("RUN CLEANUP: %s becomes dead card" % top_card.name)

## Get the card played before the current top card
func _get_previous_card() -> Card:
	if played_cards_stack.size() < 2:
		return null
	return played_cards_stack[played_cards_stack.size() - 2]

## Get run status information for display
func get_run_status() -> Dictionary:
	if current_phase != GamePhase.ACTIVE_RUN:
		return {"active": false}

	return {
		"active": true,
		"current_rank": run_target_rank,
		"sequence": run_sequence.duplicate(),
		"started_by": run_started_by.name if run_started_by else "Unknown",
		"sequence_display": _format_run_sequence(),
		"next_valid_ranks": _get_next_valid_run_ranks()
	}

## Format run sequence for display
func _format_run_sequence() -> String:
	if run_sequence.is_empty():
		return ""

	var names = []
	for rank in run_sequence:
		names.append(_get_rank_name(rank))

	return " → ".join(names)

## Helper to get rank name for display
func _get_rank_name(rank: int) -> String:
	match rank:
		1: return "A"
		11: return "J"
		12: return "Q"
		13: return "K"
		_: return str(rank)

## Get valid ranks that can be played next in run
func _get_next_valid_run_ranks() -> Array[int]:
	var valid_ranks = [run_target_rank]  # Current rank always valid

	# Add next sequential rank
	if run_target_rank < 13:  # Not King
		valid_ranks.append(run_target_rank + 1)
	elif run_target_rank == 13:  # King
		valid_ranks.append(1)  # King -> Ace

	return valid_ranks

## Handle multiple cards played in one turn during runs
func can_play_multiple_cards_in_run(cards: Array[Card]) -> bool:
	if cards.is_empty():
		return false

	# All cards must be same rank or valid sequence
	var first_card = cards[0]

	# Check if all same rank
	var all_same_rank = true
	for card in cards:
		if card.rank != first_card.rank:
			all_same_rank = false
			break

	if all_same_rank:
		# All same rank - check if it's valid for current run
		return _is_valid_during_run(first_card)

	# Check if it's a valid sequence
	return _is_valid_run_sequence(cards)

## Validate a sequence of cards for run play
func _is_valid_run_sequence(cards: Array[Card]) -> bool:
	if cards.is_empty():
		return false

	# Sort cards by rank to check sequence
	var sorted_cards = cards.duplicate()
	sorted_cards.sort_custom(func(a, b): return a.rank < b.rank)

	# First card must be playable in current run
	if not _is_valid_during_run(sorted_cards[0]):
		return false

	# Check sequence is consecutive
	for i in range(1, sorted_cards.size()):
		var expected_rank = sorted_cards[i-1].rank + 1

		# Handle King -> Ace transition
		if sorted_cards[i-1].rank == 13 and sorted_cards[i].rank == 1:
			continue

		if sorted_cards[i].rank != expected_rank:
			return false

	return true

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

## Check if player can finish game on current card
func can_finish_on_card(player: Player, card: Card) -> bool:
	# Can't finish on trick card during active run
	if current_phase == GamePhase.ACTIVE_RUN:
		return false

	# Can't finish on any trick card (except in special circumstances)
	if card.get_property("is_trick_card", false):
		return false

	return true

## Check if game is over
func is_game_over(game_data: Dictionary) -> bool:
	for player in get_all_players():
		if not player or player.has_cards():
			continue

		# Player has no cards - check if they finished legally
		var last_card_played = game_data.get("last_played_card")
		if not last_card_played:
			continue

		# Check run finish rule
		if current_phase == GamePhase.ACTIVE_RUN:
			print("RUN FINISH RULE: %s cannot finish during active run" % player.name)
			# Force pickup of 1 card
			apply_penalty_to_player(player, 1)
			return false

		# Check trick card finish rule
		if not can_finish_on_card(player, last_card_played):
			print("TRICK FINISH RULE: %s cannot finish on trick card %s" % [
				player.name, last_card_played.name
			])
			apply_penalty_to_player(player, 1)
			return false

		# Legal finish
		return true

	return false

## Get winner(s)
func get_winner(players: Array[Player], game_data: Dictionary) -> Array[Player]:
	var winners: Array[Player] = []
	for player in players:
		if not player.has_cards():
			winners.append(player)
	return winners

## Get visual representation of current top card state
func get_top_card_display_info() -> Dictionary:
	var top_card = get_active_top_card()
	if not top_card:
		return {}

	var info = {
		"original_name": top_card.name,
		"original_suit": top_card.suit,
		"original_rank": top_card.rank,
		"effective_suit": get_effective_suit(),
		"effective_rank": get_effective_rank(),
		"is_mirrored": is_top_card_mirrored,
		"has_chosen_suit": (top_card.rank == 1 && chosen_suit != Card.Suit.NONE)
	}

	# Create display name based on state
	if is_top_card_mirrored:
		var rank_name = _get_rank_name(mirrored_rank)
		var suit_symbol = _get_suit_symbol(mirrored_suit)
		info["display_name"] = "%s%s (mirrored by 7)" % [rank_name, suit_symbol]
		info["display_description"] = "7 mirroring %s%s" % [rank_name, suit_symbol]
	elif top_card.rank == 1 && chosen_suit != Card.Suit.NONE:
		var suit_symbol = _get_suit_symbol(chosen_suit)
		info["display_name"] = "A%s (chosen suit)" % suit_symbol
		info["display_description"] = "Ace choosing %s" % suit_symbol
	else:
		info["display_name"] = top_card.name
		info["display_description"] = top_card.name

	return info

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

## Calculate next player considering direction, skips, and multiple turns
func get_next_player(current_player: Player, all_players: Array[Player]) -> Player:
	if all_players.is_empty():
		return null

	var current_index = all_players.find(current_player)
	if current_index == -1:
		push_error("Current player not found in player list")
		return null

	var player_count = all_players.size()
	var next_index = current_index

	# Handle Jacks (skip calculation)
	var jacks_played = _count_consecutive_jacks_on_top()
	var players_to_skip = jacks_played

	# Handle 8s (direction and extra turns)
	var eights_played = _count_consecutive_eights_on_top()
	var extra_turns = 0

	if eights_played > 0:
		# Odd number of 8s = direction change + normal progression
		# Even number of 8s = same player gets another turn
		if eights_played % 2 == 0:
			# Even 8s = same player continues
			extra_turns = 1
		# Direction already handled in _handle_eight()

	# If same player gets another turn, return current player
	if extra_turns > 0:
		return current_player

	# Calculate next player index with skips and direction
	var step = 1 if turn_direction == TurnDirection.LEFT else -1
	next_index = (current_index + step * (1 + players_to_skip)) % player_count

	# Handle negative indices for RIGHT direction
	if next_index < 0:
		next_index += player_count

	return all_players[next_index]

## Count consecutive Jacks on top of played stack
func _count_consecutive_jacks_on_top() -> int:
	var count = 0
	for i in range(played_cards_stack.size() - 1, -1, -1):
		var card = played_cards_stack[i]
		if card && card.rank == 11:  # Jack
			count += 1
		else:
			break
	return count

## Count consecutive 8s on top of played stack
func _count_consecutive_eights_on_top() -> int:
	var count = 0
	for i in range(played_cards_stack.size() - 1, -1, -1):
		var card = played_cards_stack[i]
		if card && card.rank == 8:  # 8
			count += 1
		else:
			break
	return count

## Enhanced turn processing with proper state management
func process_turn_transition(current_player: Player) -> Dictionary:
	var result = {
		"next_player": null,
		"penalties_applied": false,
		"turn_ended": false,
		"game_phase_changed": false
	}

	# First, handle any pending penalties based on current phase
	match current_phase:
		GamePhase.ACTIVE_TWOS:
			result = _process_active_twos_transition(current_player, result)
		GamePhase.ACTIVE_FIVE_HEARTS:
			result = _process_five_hearts_transition(current_player, result)
		GamePhase.ACTIVE_RUN:
			result = _process_run_transition(current_player, result)
		_:
			# Normal phase - just calculate next player
			result.next_player = get_next_player(current_player, all_players)
			result.turn_ended = true

	return result

## Process transition during active 2s phase
func _process_active_twos_transition(current_player: Player, result: Dictionary) -> Dictionary:
	var next_player = get_next_player(current_player, all_players)

	if not next_player:
		result.next_player = current_player
		return result

	# Check if next player can counter with a 2
	var valid_twos = []
	for card in next_player.hand.cards:
		if card && card.rank == 2:
			valid_twos.append(card)

	# If no 2s available, apply penalty and end phase
	if valid_twos.is_empty():
		if apply_penalty_to_player(next_player, active_penalty):
			result.penalties_applied = true
			current_phase = GamePhase.NORMAL
			active_penalty = 0
			result.game_phase_changed = true

			# After penalty, continue to next player
			result.next_player = get_next_player(next_player, all_players)
		else:
			push_error("Failed to apply penalty")
			result.next_player = next_player
	else:
		# Next player has 2s available, they must choose
		result.next_player = next_player

	result.turn_ended = true
	return result

## Process transition during 5♥ phase
func _process_five_hearts_transition(current_player: Player, result: Dictionary) -> Dictionary:
	var next_player = get_next_player(current_player, all_players)

	if not next_player:
		result.next_player = current_player
		return result

	# Check if next player has 2♥ to counter
	var has_two_hearts = false
	for card in next_player.hand.cards:
		if card && _is_two_of_hearts(card):
			has_two_hearts = true
			break

	# If no 2♥, apply penalty and end phase
	if not has_two_hearts:
		if apply_penalty_to_player(next_player, active_penalty):
			result.penalties_applied = true
			current_phase = GamePhase.NORMAL
			active_penalty = 0
			result.game_phase_changed = true

			# After penalty, continue to next player
			result.next_player = get_next_player(next_player, all_players)
		else:
			push_error("Failed to apply 5♥ penalty")
			result.next_player = next_player
	else:
		# Next player has 2♥ available
		result.next_player = next_player

	result.turn_ended = true
	return result

## Process transition during active run
func _process_run_transition(current_player: Player, result: Dictionary) -> Dictionary:
	var next_player = get_next_player(current_player, all_players)

	if not next_player:
		result.next_player = current_player
		return result

	# Check if next player can continue the run
	var valid_run_cards = []
	for card in next_player.hand.cards:
		if card && _is_valid_during_run(card):
			valid_run_cards.append(card)

	# If no valid run cards, apply run penalty and end run
	if valid_run_cards.is_empty():
		var penalty_amount = run_target_rank
		if apply_penalty_to_player(next_player, penalty_amount):
			result.penalties_applied = true
			_end_run(false)
			result.game_phase_changed = true

			# After penalty, continue to next player
			result.next_player = get_next_player(next_player, all_players)
		else:
			push_error("Failed to apply run penalty")
			result.next_player = next_player
	else:
		# Next player can continue run
		result.next_player = next_player

	result.turn_ended = true
	return result
