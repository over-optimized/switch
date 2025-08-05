# Switch - Basic Rules (Initial Implementation)

**Setup**:

- 2+ players
- Deal 7 cards to each player (or 5 cards if 4+ players)
- Flip top card from remaining deck to start the discard pile

**Gameplay**:

- Players take turns in order
- On your turn, you must either:
  1. Play a card that matches the suit OR rank of the top discard card
  2. Draw a card from the deck if you can't play (or choose not to play)
- Turn passes to next player
- Win condition: First player to play their last card legally wins

## Core Addon functionality

Key Features Implemented:

1. Variable Hand Size: 7 cards for 2-3 players, 5 cards for 4+ players
2. Match Suit or Rank: Players must play cards matching the top discard card
3. Optional Draw: Players can choose to draw instead of playing (when allowed)
4. Turn Ends After Draw: Drawing a card ends the player's turn
5. Deck Reshuffling: When deck runs out, reshuffle from discard pile (keeping top card)
6. Emergency Pickup: If can't reshuffle, player picks up entire discard pile
7. Win Condition: First to play last card wins

## Trick cards

1. Ace
2. 2
3. 3
4. 5♥
5. 7
6. 8
7. Jack

### 2s - "Pick Up Two" Cards ✅

**When played**: Forces next player to either:

- Play any 2 (suit doesn't matter), OR
- Pick up 2 cards per 2 in the stack

**Stacking**: Multiple 2s accumulate (2 cards per 2 played)

- Example: Player A plays 2♠, Player B plays 2♥, Player C must pick up 4 cards OR play another 2

#### After penalty served:

- Top card is still the 2 but becomes "inactive/dead"
- 2 becomes "dead" - next player can play any 2 OR match the suit
- Next player can play another 2 OR match the suit of the 2
- Turn ends immediately after picking up cards
- No penalty for next player (trick is inactive)

#### Stacking Rules:

- Any 2 can be played on any 2
- Each 2 adds 2 cards to the penalty
- Players can play multiple 2s from their hand in one turn (tactical choice)

#### Tactical Elements:

- Playing fewer 2s than you have can be strategic
- Forces risk assessment: "Does next player have a 2?"

#### Key Implementation Notes:

- Track penalty accumulation across multiple 2s
- State transition: Active → Dead after penalty served
- Multiple 2s can be played in single turn

### Aces - "Suit Changer" Cards ✅

#### When played:

- Can be played on any suit (universal card)
- Player chooses the new suit for the top card
- Changes game state to the chosen suit

#### Play Rules:

- Can be played on any inactive trick card or normal card
- Cannot be played on active trick cards (like active 2s)
- Player chooses new suit via UI popup

#### Restrictions:

- Cannot counter active 2s - must pick up or play a 2
- (Presumably can be played on dead 2s to change suit?)

#### Strategic Value:

- Get rid of Ace when you have no matching cards
- Set up favorable suit for your remaining cards
- Block opponents if you can guess their suits

#### After Ace Played:

- Next player must match the chosen suit OR play another Ace
- Multiple Aces can be played in one turn (tactical stacking)

#### Strategic Depth:

- Counter-Ace tactics: Play multiple to ensure your suit choice sticks
- End-game planning: Set up suits that match your remaining cards
- Risk assessment: "Does opponent have an Ace to counter mine?"

#### Pattern Recognition:

- Aces respect active trick states (can't bypass 2s)
- Universal play ability (like wild cards)
- Player choice mechanic (suit selection)

#### UI Flow:

- Ace played → added to discard stack
- Suit selection popup appears
- Player chooses new suit
- Visual: Original suit crossed out, new suit shown beside it
- Game continues with new suit requirement

#### Key Implementation Notes:

- Aces respect active/inactive trick states
- Suit change is permanent until another Ace or trick card
- Multiple Aces = tactical suit battle

#### Ace Visual Logic ✅

- When Ace is top card: Show original suit crossed out + new chosen suit
- When normal card played on Ace: No special visual needed (4♠ naturally shows spades)
- Ace on Ace visualization: Add to future considerations list
- This keeps the UI clean and intuitive - only show the suit change info when it's relevant (i.e., when the Ace is the active top card).

#### 📝 Updated Future Features List:

- Quick play interruption mechanics
- Timer-based turn penalties
- Special game modes vs Classic mode
- UI mistake forgiveness system (one pass per player)
- Ace-on-Ace visual history/progression display

### Runs - Sequential Rank Chains ✅

#### Starting a Run:

- Play 3(s) following normal suit/rank matching rules
- Once played, game mechanics change to "run mode"
- Can play multiple 3s to start (3♠,3♥,3♦ all at once)
- Great for dumping many cards quickly

#### Run Rules:

- Next player must play the same rank OR next sequential rank
- Can chain multiple consecutive ranks in one turn (3,4,5,6...)
- Can play multiple cards of the same rank
- Suits don't matter during runs
- Can choose which suit to leave on top when playing multiples

#### Run Examples:

- Player 1: 3♠ → Player 2 must play 3 or 4
- Player 1: 3♠,4♥,5♣ → Player 2 must play 5 or 6
- Player 1: 5♠,5♥,5♦ → Can choose which 5 stays on top

#### Penalty System:

- Can't continue run → Pick up cards equal to the target rank
- Example: Run ends on 5 → Pick up 5 cards

#### Run Termination:

- After penalty served → Run becomes inactive
- Next player plays normal suit/rank matching
- Runs can go 3→4→5→...→King→Ace
- Runs end at Ace (3→4→5→...→King→Ace)
- Future consideration: Extend beyond Ace in special modes

#### Trick Cards in Runs:

- Any trick card played during a run is treated as inactive
- Only the rank matters, special abilities ignored

#### Run Continuation Rules:

- No gaps allowed - must be perfectly sequential
- Invalid gap attempt = severe penalty (invalid cards + run penalty + 2 stupid cards)
- Must account for every rank in sequence

#### Strategic Elements:

- Card dumping opportunity - especially after picking up entire discard pile
- Reverse psychology - player with most cards might be closest to winning
- Finishing tactic - end run on inactive state to force opponent to pick up 1 card (can't finish on empty hand)

#### Penalty Examples:

- Run ends on 7 → Pick up 7 cards
- Invalid sequence (3,4,6) → Pick up played cards + 3 + 2 stupid cards = 8 total!

#### Implementation Notes:

- Need sequence validation logic
- Track run state and current required rank
- Handle multiple cards per rank in single play
- Severe penalty system for invalid sequences

### Run Finish Scenario:

#### Situation:

- Player A plays 3 (starts run)
- Player B has 1 card left: a 4

#### Player B's options:

- **Play the 4**: Satisfies the run BUT since it's played during an active run, it's treated as a trick card

  - **Result**: Must pick up 1 card (can't finish on trick card)
  - ~~Now has 2 cards total~~ One card remaining as card pick up occurs after card played

- **Don't play the 4**: Forced to pick up 3 cards from run penalty

- **Result**: Now has 4 cards total

#### After Player B picks up:

- Run becomes inactive
- Player A can potentially finish if their last card matches the suit/rank of the top card (the 4) AND is not a trick card

**Key Rule**: Any card played during an active run is considered a trick card, regardless of its normal status.

### Run Finish Mechanics ✅

#### Player B's Optimal Choice:

- Play the 4 + announce "last card, can't finish" → Pick up 1 card
- Alternative: Don't play, pick up 3 cards (keeps 4, but worse position)

#### Run State Rules:

- During active run: ALL cards are treated as trick cards
- After run ends: Top card becomes "dead" regardless of its normal rank
- Dead cards can be matched by suit/rank normally

### "Last Card" Announcement Rule 📝

#### Real-world rule:

- Must announce "last card" when playing second-to-last card
- Failure to announce + next player plays → 2 stupid cards penalty
- Requires other players to notice and call it out

#### Virtual Adaptation Challenges:

- No natural "announcement" moment in digital UI
- Automatic detection vs manual announcement
- How to simulate the "other players noticing" aspect

#### Potential Virtual Solutions (for future consideration):

1. Auto-announcement: System announces when player reaches last card
2. Manual button: "Last Card" button that players must click
3. Challenge system: Other players can "challenge" if they think someone forgot
4. Timer-based: Penalty if you don't announce within X seconds of having 1 card
5. Honor system: Trust players to self-announce

### 📝 Updated Future Features List:

- Quick play interruption mechanics
- Timer-based turn penalties
- Special game modes vs Classic mode
- UI mistake forgiveness system (one pass per player)
- Ace-on-Ace visual history/progression display
- **"Cut Throat" Mode**: Automatic penalties, no mercy for mistakes
- **"Casual" Mode**: Manual announcements, challenge buttons, forgiveness mechanics

This is a really smart way to accommodate different player preferences - some want the authentic, strict experience while others prefer a more forgiving, social experience.

The "Last Card" announcement is a perfect example of how these modes would differ:

- **Cut Throat**: Auto-detect, instant penalty
- **Casual**: Manual announce button, optional challenges

### 8s - "Reverse Direction" Cards ✅

#### Stacking & State:

- Player chooses how many 8s to play in one turn
- After played, 8s become "dead" immediately
- Odd 8s = direction change, Even 8s = same player continues

**Default Direction**: Left (clockwise around table)
**Direction Persistence**: New direction maintained until another 8 is played
**State**: 8s become dead after played, but direction change remains active

**Examples with 4 players** (A→B→C→D):

- **Normal**: A→B→C→D→A...
- **After one 8**: A→D→C→B→A... (reversed, stays this way)
- **After another 8**: Back to A→B→C→D→A... (reversed again)

#### Implementation Notes:

- Track current direction as game state
- Only 8s can change direction (permanent until next 8)
- Direction independent of 8s becoming dead

This gives 8s a unique dual nature:

- Immediate tactical effect (extra turns via stacking)
- Persistent strategic effect (direction change)

#### During Runs:

8s are just rank 8 cards (no special power)
Can only be played on 7 or 8 in the sequence
Follow normal run rules

#### Sneaky Finish Example:

1. Player plays two 8s → gets another turn (even number)
2. Announces "last card"
3. Plays 4♠ to finish → Game over!

This is incredibly clever because:

- Opponents expect turn to pass after 8s
- Double reversal gives unexpected extra turn
- Perfect setup for surprise finish
- Uses the "last card" announcement timing strategically

### Jacks - "Skip Next Player" Cards ✅

**Basic Effect**: Skip the next player in turn order

#### Player Count Scaling:

- 2 players: 1 Jack = skip opponent = you go again
- 3 players: 2 Jacks = skip both opponents = you go again
- 4 players: 3 Jacks = skip all opponents = you go again
- N players: (N-1) Jacks = skip everyone = you go again

#### Stacking Strategy:

- Can play multiple Jacks to control exactly how many players to skip
- Strategic choice: Skip some players vs skip back to yourself

#### Combination Tactics:

- 8s + Jacks: Ultimate turn control
  - Use 8s to set favorable direction
  - Use Jacks to skip opponents
  - Chain for multiple consecutive turns
- Perfect setup for surprise finishes

#### State & Runs:

- Become dead after played (like 8s)
- During runs: Just rank Jack (no special power)

#### Direction Interaction:

- Skips follow current game direction
- If 8 changed direction to right, Jack skips player to your right
- Direction + skip = precise turn control

#### Strategic Combinations:

- **8s set direction** → **Jacks control skipping** → Ultimate turn manipulation
- Example: Reverse direction with 8, then skip "new next player" with Jack

#### Turn Control Matrix (4 players):

- Normal direction: A→B→C→D
- After 8: A→D→C→B (reversed)
- Jack after 8: A skips D, goes to C

This creates incredibly sophisticated turn control! Players can:

1. Set optimal direction with 8s
2. Skip inconvenient players with Jacks
3. Chain multiple turns for devastating finishes

The interaction between 8s and Jacks makes both cards exponentially more powerful when used together.
