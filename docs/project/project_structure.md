# Card Game Foundation - Project Structure

## Overview

This project contains a reusable card game framework (addon) and a specific implementation of the Switch card game.

## Directory Structure

### `/addons/card_game_foundation/`

The reusable card game engine addon that can be used for any card game.

#### `/core/`

Core classes that form the foundation of any card game:

- **`card.gd`** - Base card class with suit, rank, and properties
- **`deck.gd`** - Collection of cards with common operations (shuffle, draw, etc.)
- **`hand.gd`** - Player's hand of cards (extends Deck)
- **`player.gd`** - Represents a game player (human or AI)
- **`game_manager.gd`** - Manages overall game flow, turns, and state
- **`game_rules.gd`** - Abstract base class for game-specific rules

#### `/factories/`

Factory classes for creating different types of decks:

- **`standard_deck_factory.gd`** - Creates standard 52-card decks, Uno decks, etc.

#### `/utils/`

Utility classes for the card game framework:

- **`card_game_test_framework.gd`** - Simple testing framework for card games

### `/games/switch/`

Implementation of the Switch card game using the card game foundation.

#### `/rules/`

Switch-specific game logic:

- **`switch_game_rules.gd`** - Implements all Switch rules (extends GameRules)
- **`switch_deck_factory.gd`** - Creates Switch-compatible decks

#### `/scenes/`

Godot scenes for the Switch game:

- **`SwitchGameTest.tscn`** - Interactive test scene for manual gameplay testing
- **`SwitchTestSuite.tscn`** - Automated test suite scene

#### `/scripts/`

Switch-specific scripts:

- **`test_switch_game.gd`** - Manual testing and debugging script
- **`switch_test_suite.gd`** - Automated test suite implementation

### `/docs/`

Project documentation organized by category.

## Design Philosophy

### Addon Structure

The `card_game_foundation` addon is designed to be:

- **Game-agnostic** - Core classes work for any card game
- **Extensible** - Easy to add new card types, rules, or mechanics
- **Reusable** - Can be used in multiple projects
- **Well-tested** - Includes testing framework and utilities

### Game Implementation

Individual games (like Switch) should:

- **Extend base classes** rather than modify them
- **Keep game-specific code separate** from the core addon
- **Include comprehensive tests** using the test framework
- **Document game rules** clearly

## Adding New Card Games

To add a new card game:

1. Create `/games/your_game/` directory
2. Implement `YourGameRules` extending `GameRules`
3. Create game-specific factories if needed
4. Add scenes and test scripts
5. Document the rules in `/docs/rules/`

## File Naming Conventions

- **Classes**: PascalCase (e.g., `SwitchGameRules`)
- **Files**: snake_case (e.g., `switch_game_rules.gd`)
- **Scenes**: PascalCase (e.g., `SwitchGameTest.tscn`)
- **Documentation**: snake_case (e.g., `project_structure.md`)

## Dependencies

### Internal Dependencies

- Switch game depends on card_game_foundation addon
- Test suites depend on CardGameTestFramework
- All games depend on core classes (Card, Deck, Player, etc.)

### External Dependencies

- Godot 4.x engine
- No external plugins required

## Best Practices

### Code Organization

- Keep core addon code generic and extensible
- Use composition over inheritance where possible
- Implement comprehensive error checking and null safety
- Use signals for loose coupling between components

### Testing

- Write tests for all new features
- Use the CardGameTestFramework for consistency
- Test both positive and negative cases
- Include edge case testing

### Documentation

- Document all public methods and classes
- Keep README files updated
- Use examples in documentation
- Maintain changelog for significant updates
