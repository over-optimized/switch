# Switch - Complete Game Rules

## Basic Setup & Gameplay

**Setup**:
- 2+ players
- Deal 7 cards to each player (or 5 cards if 4+ players)
- Flip top card from remaining deck to start the played cards stack

**Gameplay**:
- Players take turns in numbered order (Player 1 → Player 2 → Player 3, etc.)
- Initial direction: Left (ascending player numbers)
- On your turn, you must either:
  1. Play a card that matches the suit OR rank of the active top card
  2. Draw a card from the deck if you can't play (or choose not to play)
- Turn passes to next player
- **Win condition**: First player to play their last card legally wins

**Multiple Card Play**: At any point, you may play multiple cards of the same rank in a single turn (always optional, never mandatory)

**Deck Management**: When deck runs out, move the active top card aside and shuffle the remaining played cards to form a new deck

## Quick Reference - Trick Cards

| Card | Effect | Stacking | State After Play | During Runs |
|------|--------|----------|------------------|-------------|
| 2 | Next player +2 cards or play 2 | Yes (accumulates) | Dead | Illegal (no wraparound) |
| 3 | Start run sequence | Yes (multiple 3s) | Active until run ends | N/A (starts runs) |
| 5♥ | +5 cards penalty (only counter: 2♥) | No (unique card) | Dead | Just rank 5 |
| 7 | Mirror rank and suit of last card | Yes (multiple 7s) | Dead | Just rank 7 |
| 8 | Reverse direction | Yes (odd=reverse, even=same) | Dead | Just rank 8 |
| Jack | Skip next player | Yes (accumulates skips) | Dead | Just rank Jack |
| King | Run continuation/termination | No special stacking | Depends on context | Sequential rank only |
| Ace | Change suit (choose new suit) | Yes (counter-Ace battles) | Dead | Only on King or Ace |

## Detailed Trick Card Rules

### 7s - "Mirror" Cards

**Effect**: Mirrors the rank and suit of the last card played (for matching purposes only)
- Can be played on any suit/rank (universal like Aces)  
- Does NOT copy special effects - only rank and suit for next player's matching
- Becomes the mirrored card for game state purposes

**Examples**:
- Last card was 2♠: Playing 7 becomes 2♠ (next player must match 2 or ♠)
- Last card was 5♥: Playing 7 becomes 5♥ (next player must match 5 or ♥)
- Last card was K♣: Playing 7 becomes K♣ (next player must match K or ♣)

**Active Trick Cards**: Cannot counter active penalties
- Cannot stop 2s accumulation (not a real 2)
- Cannot counter 5♥ penalty (not a real 2♥)
- Simply becomes that rank/suit for matching after penalty is served

**Stacking**: Multiple 7s can be played, each mirroring the previous card

**Strategic Use**:
- Emergency play when you can't match current suit/rank
- Setup favorable rank/suit combinations for your remaining cards
- Bridge between incompatible cards in your hand

**During runs**: Treated as rank 7 only (no mirror power)

**After played**: Becomes dead, but game state reflects the mirrored rank/suit

### 5♥ - "Pick Up Five" Card

**When played**: Forces next player to pick up 5 cards
- Can only be played on a 5 (any suit) OR on any ♥ (hearts)
- **Only counter**: 2♥ (Two of Hearts)

**Chaining with 2s**:
- Can be played on 2♥ to chain penalties
- 2♥ can be played on 5♥ to counter and continue 2s chain
- Examples:
  - 2♠ → 2♥ → 5♥ = 9 cards penalty total
  - 5♥ → 2♥ → 2♣ = 9 cards penalty total

**During runs**: Treated as rank 5 only (no special power)

**After penalty served**: Becomes dead, next player resumes normal play

### 2s - "Pick Up Two" Cards

**When played**: Forces next player to either:
- Play any 2 (suit doesn't matter), OR  
- Pick up 2 cards per 2 in the stack

**Stacking Rules**:
- Any 2 can be played on any 2
- Each 2 adds 2 cards to the penalty
- Multiple 2s can be played in one turn
- Penalty accumulates: 2♠ + 2♥ + 2♦ = 6 cards to pick up

**After penalty served**:
- All 2s become "dead" 
- Next player can match the suit of the top 2 OR play any 2
- Turn ends immediately after picking up cards

**During runs**: 2s cannot be played legally (runs don't wrap around from Ace to 2)

### Aces - "Suit Changer" Cards  

**When played**:
- Can be played on any suit (universal card)
- Player chooses the new suit for the active top card
- Cannot be played on active trick cards (like active 2s)

**During runs**:
- **Legal**: Only when King or Ace is on top
  - King → Ace: Ends the run successfully
  - Ace → Ace: Continues run termination sequence
- **Illegal but allowed**: Playing Ace on non-King/non-Ace during run
  - Penalty: Return the Ace + pick up King + 2 additional cards + cards equal to current rank

**Stacking**: Multiple Aces can be played for tactical suit battles

**After Ace played**: Next player must match the chosen suit OR play another Ace

### Runs - Sequential Rank Chains (Starting with 3s)

**Starting a Run**:
- Play one or more 3s following normal suit/rank matching rules
- Game enters "run mode" - suits no longer matter
- Multiple 3s can be played to start (great for dumping cards)

**Run Rules**:
- Must play current rank OR next sequential rank (3→4→5→6...→King→Ace)
- Can play multiple cards of the same rank in one turn
- When playing multiples, choose which suit stays on top
- Sequence: 3, 4, 5, 6, 7, 8, 9, 10, Jack, Queen, King, Ace
- **Runs end at Ace** (no wraparound to 2)

**Legal Plays During Runs**:
- Current rank or next sequential rank only
- King: Can play another King or an Ace
- Ace: Can only play another Ace

**Run Termination**:
- **Successful**: Player plays Ace (run ends, Ace becomes dead)
- **Failed**: Player cannot continue sequence
  - Penalty: Pick up cards equal to the current rank
  - Example: Run ends on 7 → pick up 7 cards
  - Special case: Run ends on King → pick up 13 cards

**Invalid Sequence Penalty**:
- Playing non-sequential card during run (e.g., 3,4,6)
- Penalty: Return played cards + pick up cards equal to target rank + 2 additional cards
- Example: 3,4,6 attempt → return all 3 cards + pick up 5 + 2 = 10 cards total

**Trick Cards During Runs**:
- All cards played during active runs are treated as inactive (no special powers)
- Only rank matters for sequence continuation
- Exception: Aces retain limited functionality (King/Ace rule)

**Run Finish Rule**: Any card played during an active run is considered a trick card - players cannot finish the game on a trick card and must pick up 1 card

### 8s - "Reverse Direction" Cards

**Effect**: Reverse turn order direction
- **Odd number of 8s**: Direction changes
- **Even number of 8s**: Same player continues (direction changes twice)

**Direction Examples** (4 players):
- Normal: Player 1 → 2 → 3 → 4 → 1...
- After one 8: Player 1 → 4 → 3 → 2 → 1...
- After another 8: Back to Player 1 → 2 → 3 → 4...

**2-Player Special Case**:
- 1 eight: Other player goes  
- 2 eights: Same player goes again

**State**: 8s become dead immediately after played, but direction change persists until next 8 is played

**During Runs**: Treated as rank 8 only (no direction change power)

### Jacks - "Skip Next Player" Cards

**Effect**: Skip the next player(s) in current turn order

**Scaling by Player Count**:
- 2 players: 1 Jack = skip opponent = you go again
- 3 players: 2 Jacks = skip both opponents = you go again  
- 4 players: 3 Jacks = skip all opponents = you go again
- General: (N-1) Jacks = skip everyone = you go again

**Strategic Stacking**: Can play multiple Jacks to control exactly how many players to skip

**Direction Interaction**: Skips follow current game direction (affected by 8s)

**State**: Become dead after played

**During Runs**: Treated as rank Jack only (no skip power)

### Combination Tactics

**8s + Jacks**: Ultimate turn control
1. Use 8s to set favorable direction
2. Use Jacks to skip specific opponents  
3. Chain for multiple consecutive turns

**Perfect Finish Setup**:
1. Play multiple 8s for extra turn
2. Announce "last card" 
3. Play final card to win

## Game States

**Normal Play**: Match suit or rank of active top card
**Active 2s**: Must play 2 or pick up accumulated penalty
**Active Run**: Must play current rank or next sequential rank
**Dead Trick Card**: Resume normal play (match suit/rank)

## Terminology

**Active Top Card**: The face-up card on top of the played cards stack that determines legal plays
**Dead Card**: A trick card that has been played and lost its special power
**Active Trick Card**: A trick card currently requiring a response (like 2s forcing pickup)
**Played Cards Stack**: The central pile of cards (replaces traditional "discard pile")
**Trick Card**: Any card with special rules (2, 3, 5♥, 7, 8, Jack, Ace)

## Future Features & Considerations

**Game Modes**:
- **Cut Throat Mode**: Automatic penalties, no mercy for mistakes
- **Casual Mode**: Manual announcements, challenge buttons, forgiveness mechanics

**Advanced Features**:
- "Last card" announcement system
- Quick play interruption mechanics  
- Timer-based turn penalties
- UI mistake forgiveness system
- Special visual effects for card combinations

**Missing Trick Cards**: 5♥ and 7 effects to be defined