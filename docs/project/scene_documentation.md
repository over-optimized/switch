# Scene Documentation

## Overview

This document describes the purpose and usage of each scene in the Switch card game project.

## Scene Types

### Test Scenes

Scenes designed for testing and debugging the card game implementation.

### Game Scenes

Scenes that provide actual gameplay functionality.

## Scene Descriptions

### `/games/switch/scenes/SwitchGameTest.tscn`

**Purpose**: Interactive manual testing of Switch game mechanics

**Script**: `test_switch_game.gd`

**Usage**:

- Run scene to start an automated test game
- Press **SPACE/ENTER** to advance turns manually
- Press **ESCAPE** to view current game state
- Watch console output for detailed game events

**Features**:

- Creates 2-player test game with debug deck
- Automatically makes moves for testing
- Provides detailed logging of all game events
- Shows hand contents and valid moves
- Handles trick card effects with user feedback

**When to Use**:

- Manual testing of new features
- Debugging specific game scenarios
- Verifying trick card behaviors
- Understanding game flow

---

### `/games/switch/scenes/SwitchTestSuite.tscn`

**Purpose**: Automated comprehensive testing of all game components

**Script**: `switch_test_suite.gd`

**Usage**:

- Run scene to execute full test suite automatically
- Check console output for test results
- Review test summary for pass/fail statistics

**Test Categories**:

1. **Card Creation** - Basic card properties and methods
2. **Deck Operations** - Adding, drawing, shuffling cards
3. **Hand Operations** - Player hand management
4. **Player Creation** - Player objects and properties
5. **Switch Deck Factory** - Deck creation and card properties
6. **Game Setup** - Initialization and validation
7. **Card Dealing** - Proper distribution of cards
8. **Basic Card Matching** - Suit and rank matching rules
9. **Ace Functionality** - Universal card behavior
10. **Penalty Cards** - 2s and 5♥ identification

**When to Use**:

- Before committing code changes
- After implementing new features
- Regression testing
- Continuous integration validation

## Scene Structure Patterns

### Test Scene Pattern

```gdscript
extends Node

var test_components: Array = []
var test_results: Dictionary = {}

func _ready():
    setup_test_environment()
    run_tests()
    display_results()

func setup_test_environment():
    # Initialize game components for testing

func run_tests():
    # Execute test scenarios

func display_results():
    # Show results to user
```

### Interactive Test Pattern

```gdscript
extends Node

var game_manager: GameManager
var game_rules: GameRules

func _ready():
    setup_game()

func _input(event):
    # Handle user input for manual testing

func setup_game():
    # Initialize game for interactive testing
```

## Input Handling

### Standard Input Mappings

- **ui_accept** (Space/Enter) - Advance/confirm action
- **ui_cancel** (Escape) - Cancel/show state
- **ui_up/down/left/right** - Navigate options (future)

### Custom Input Actions

Define these in Project Settings > Input Map if needed:

- **draw_card** - Force card draw
- **play_card** - Play selected card
- **show_hand** - Display current hand
- **auto_play** - Enable/disable AI assistance

## Debugging Features

### Console Output Levels

- **INFO** - Basic game events (turns, moves)
- **DEBUG** - Detailed state information
- **ERROR** - Invalid operations and failures
- **TEST** - Test execution and results

### Visual Debugging

- Hand display in labels
- Game state visualization
- Card property inspection
- Turn order indication

## Future Scene Types

### Planned Scenes

- **SwitchMainMenu.tscn** - Main menu and game options
- **SwitchGameplay.tscn** - Full gameplay with UI
- **SwitchMultiplayer.tscn** - Network multiplayer support
- **CardVisualizer.tscn** - Visual card representation
- **DeckEditor.tscn** - Custom deck creation

### Scene Naming Conventions

- **Test scenes**: `[Game]Test.tscn`, `[Game]TestSuite.tscn`
- **Gameplay scenes**: `[Game]Gameplay.tscn`, `[Game]Menu.tscn`
- **Utility scenes**: `CardVisualizer.tscn`, `DeckEditor.tscn`

## Best Practices

### Scene Organization

- Keep test scenes in `/scenes/` directory
- Use descriptive names that indicate purpose
- Include version numbers for major iterations
- Group related scenes in subdirectories if needed

### Script Attachment

- Always attach scripts to scene root nodes
- Use consistent script naming: `scene_name.gd`
- Include comprehensive scene documentation in script headers
- Use typed variables and proper error handling

### Node Structure

- Keep node trees simple and flat when possible
- Use meaningful node names
- Group UI elements under Control nodes
- Separate logic nodes from display nodes

### Signal Usage

- Connect signals in script rather than editor when possible
- Use descriptive signal names
- Document signal parameters
- Implement proper signal cleanup in `_exit_tree()`

## Testing Workflow

### Manual Testing Process

1. Run `SwitchGameTest.tscn`
2. Verify basic game setup
3. Test specific scenarios manually
4. Check console for errors/warnings
5. Document any issues found

### Automated Testing Process

1. Run `SwitchTestSuite.tscn`
2. Review test output for failures
3. Investigate failed tests
4. Fix issues and re-run tests
5. Ensure all tests pass before deployment
