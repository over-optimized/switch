# Switch Game Comparison & Inspirations

## Overview

This document compares the rules and features of the Switch card game implemented in this project with the traditional British Switch rules, as well as similar and inspirational games such as Crazy Eights and Uno. It also outlines the plan to support a classic/traditional mode and references competitors and variants.

---

## 1. Comparison: Project Switch vs. Traditional British Switch

### Similarities

- **Matching by Suit or Rank:** Both require players to play a card matching the suit or rank of the top card.
- **Special Cards:** 2s (pick up two), 8s (reverse), Jacks (skip), and Aces (change suit) are present in both.
- **Multiple Card Play:** Playing multiple cards of the same rank in one turn is allowed.
- **Runs:** Sequential runs starting with 3s are supported (common house rule).
- **Last Card Announcement:** Announcing "last card" is standard and planned for future implementation.

### Differences & Unique Features

- **5♥ Card:** Forces next player to pick up 5 cards, countered only by 2♥. Not standard in classic Switch.
- **7s as "Mirror" Cards:** 7s mirror the previous card's rank and suit for matching, a unique mechanic.
- **Stacking/Chaining:** Stacking of 2s and Jacks for penalties/skips is supported (sometimes a house rule).
- **Formalized Runs:** Detailed run rules, including penalties for breaking sequence and special handling for Kings/Aces.
- **Game States & Terminology:** More formalized, with clear definitions for "dead" and "active" trick cards.
- **Advanced Features:** Planned modes (Cut Throat, Casual), UI forgiveness, timer-based penalties, etc.

---

## 2. Similar & Inspirational Games

### Crazy Eights

- **Mechanics:** Match suit/rank, play special cards (e.g., 8 reverses direction).
- **Differences:** Fewer trick cards, less complex stacking and run mechanics.

### Uno

- **Mechanics:** Commercial version of Crazy Eights with custom cards (Skip, Reverse, Draw Two, Wild).
- **Differences:** Uses a proprietary deck, more action cards, and color-based matching.

### Other Variants

- **Mau Mau:** European variant similar to Switch and Crazy Eights.
- **Black Jack Switch:** Unrelated, but sometimes confused due to name.

---

## 3. Competitors & Commercial Games

- **Uno (Mattel):** Most popular commercial variant, global reach.
- **Phase 10:** Another Mattel game, sequence-based play.
- **Skip-Bo:** Focuses on sequencing and stacking.

---

## 4. Planned Features & Modes

- **Classic/Traditional Mode:** Option to play with only standard British Switch rules (no 5♥ or 7 mirror mechanics).
- **Configurable Rules:** Allow toggling of house rules and advanced features.
- **Game Modes:** Cut Throat, Casual, timer-based, and more.
- **Last Card Announcement:** UI and logic support for mandatory announcements.

---

## 5. References & Further Reading

- [Wikipedia: Switch (card game)](<https://en.wikipedia.org/wiki/Switch_(card_game)>)
- [Wikipedia: Crazy Eights](https://en.wikipedia.org/wiki/Crazy_Eights)
- [Wikipedia: Uno (card game)](<https://en.wikipedia.org/wiki/Uno_(card_game)>)

---

## Changelog

- Initial version created for project documentation and feature planning.
