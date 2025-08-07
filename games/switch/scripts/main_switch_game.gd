# Main script for SwitchMain.tscn
extends Control

# References to UI elements
@onready var main_menu_scene = preload("res://games/switch/scenes/MainMenu.tscn")
@onready var game_area_scene = preload("res://games/switch/scenes/GameArea.tscn")
var main_menu: Panel
var game_area: Panel
var player_hands: Control
var played_stack: Control
var deck: Control
var turn_indicator: Label
var play_button: Button
var draw_button: Button
var switch_button: Button

# Game logic references
var game_manager: GameManager
var game_rules: SwitchGameRules
var players: Array[Player] = []

func _ready():
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	game_area = game_area_scene.instantiate()
	add_child(game_area)
	main_menu.visible = true
	game_area.visible = false
	player_hands = game_area.get_node("PlayerHands")
	played_stack = game_area.get_node("PlayedStack")
	deck = game_area.get_node("Deck")
	turn_indicator = game_area.get_node("TurnIndicator")
	play_button = game_area.get_node("ActionButtons/PlayButton")
	draw_button = game_area.get_node("ActionButtons/DrawButton")
	switch_button = game_area.get_node("ActionButtons/SwitchButton")
	_connect_menu_buttons()

func _connect_menu_buttons():
	main_menu.get_node("StartButton").pressed.connect(_on_start_game)
	main_menu.get_node("SettingsButton").pressed.connect(_on_settings)
	main_menu.get_node("RulesButton").pressed.connect(_on_view_rules)
	main_menu.get_node("ExitButton").pressed.connect(_on_exit)

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
