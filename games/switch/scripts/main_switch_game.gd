# Main script for SwitchMain.tscn
extends Control

# References to UI elements
@onready var main_menu = $MainMenu
@onready var game_area = $GameArea
@onready var player_hands = $GameArea/PlayerHands
@onready var played_stack = $GameArea/PlayedStack
@onready var deck = $GameArea/Deck
@onready var turn_indicator = $GameArea/TurnIndicator
@onready var play_button = $GameArea/ActionButtons/PlayButton
@onready var draw_button = $GameArea/ActionButtons/DrawButton
@onready var switch_button = $GameArea/ActionButtons/SwitchButton

# Game logic references
var game_manager: GameManager
var game_rules: SwitchGameRules
var players: Array = []

func _ready():
	main_menu.visible = true
	game_area.visible = false
	play_button.disabled = true
	draw_button.disabled = true
	switch_button.disabled = true
	_connect_menu_buttons()

func _connect_menu_buttons():
	$MainMenu/StartButton.pressed.connect(_on_start_game)
	$MainMenu/SettingsButton.pressed.connect(_on_settings)
	$MainMenu/RulesButton.pressed.connect(_on_view_rules)
	$MainMenu/ExitButton.pressed.connect(_on_exit)

func _on_start_game():
	main_menu.visible = false
	game_area.visible = true
	_initialize_game()

func _on_settings():
	# TODO: Show settings dialog
	print("Settings button pressed")

func _on_view_rules():
	# TODO: Show rules dialog
	print("View Rules button pressed")

func _on_exit():
	get_tree().quit()

func _initialize_game():
	# Example: 2 human players for now
	players = [Player.new("p1", "Alice", Player.PlayerType.HUMAN), Player.new("p2", "Bob", Player.PlayerType.HUMAN)]
	var deck_instance = SwitchDeckFactory.create_switch_deck()
	game_rules = SwitchGameRules.new()
	game_manager = GameManager.new()
	game_rules.set_main_deck(deck_instance)
	game_rules.set_players(players)
	game_manager.setup_game(players, deck_instance, game_rules)
	_update_ui_for_new_game()

func _update_ui_for_new_game():
	turn_indicator.text = "%s's Turn" % players[0].name
	play_button.disabled = false
	draw_button.disabled = false
	switch_button.disabled = false
	# TODO: Render player hands, played stack, deck

func _on_play_card():
	# TODO: Handle play card action
	pass

func _on_draw_card():
	# TODO: Handle draw card action
	pass

func _on_switch_announce():
	# TODO: Handle "Switch!" announcement
	pass

func _input(event):
	# TODO: Handle keyboard/gamepad input for actions
	pass
