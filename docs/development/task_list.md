# Development Task List

## Current Sprint: Core Fixes 🔥

### Active Issues

- [x] **FIX: Card dealing not working**

  - Status: Fixed
  - Priority: Critical
  - Description: Players showing empty hands despite deck having cards
  - Investigation: Added debug logging to setup_game()

- [ ] **FIX: Turn advancement system**
  - Status: Next
  - Priority: High
  - Description: Implement proper skip/direction handling
  - Dependencies: Card dealing fix

### Immediate Tasks (This Week)

#### Monday

- [ ] Debug and fix card dealing issue
- [ ] Run comprehensive test suite
- [ ] Verify basic game setup works

#### Tuesday

- [ ] Implement proper turn advancement
- [ ] Add Jack skip functionality
- [ ] Test direction reversal with 8s

#### Wednesday

- [ ] Fix penalty application timing
- [ ] Implement penalty delay system
- [ ] Test 2s and 5♥ interactions

#### Thursday

- [ ] Complete 7s mirror functionality
- [ ] Add mirror state persistence
- [ ] Test mirroring in different phases

#### Friday

- [ ] Code review and cleanup
- [ ] Update documentation
- [ ] Plan next sprint

## Next Sprint: Core Mechanics 🚀

### Run System Implementation

- [ ] **Full sequence validation**

  - Estimate: 2 days
  - Priority: High
  - Description: Implement 3→4→5...→K→A sequence checking

- [ ] **Run termination handling**

  - Estimate: 1 day
  - Priority: High
  - Description: Proper Ace termination and King→Ace transitions

- [ ] **Run failure penalties**
  - Estimate: 1 day
  - Priority: Medium
  - Description: Pick up cards equal to current rank on failure

### Draw Card Mechanics

- [ ] **Basic draw functionality**

  - Estimate: 2 days
  - Priority: High
  - Description: Allow players to draw cards when stuck

- [ ] **Deck management**
  - Estimate: 1 day
  - Priority: Medium
  - Description: Handle reshuffling when deck is empty

### Multiple Card Play

- [ ] **Same rank selection**

  - Estimate: 2 days
  - Priority: Medium
  - Description: Allow playing multiple cards of same rank

- [ ] **Suit selection logic**
  - Estimate: 1 day
  - Priority: Medium
  - Description: Choose which suit stays on top

## Future Sprints: Polish & Features ✨

### Sprint 3: Game Polish

- [ ] Game end detection and scoring
- [ ] "Switch!" announcement system
- [ ] Visual improvements and animations
- [ ] Sound effects integration

### Sprint 4: Advanced Features

- [ ] AI player implementation
- [ ] Custom game settings
- [ ] Statistics tracking
- [ ] Multiple game modes

### Sprint 5: UI/UX

- [ ] Menu system
- [ ] Settings screen
- [ ] Help/tutorial system
- [ ] Visual themes

## Backlog Items 📋

### Technical Debt

- [ ] **Code organization** - Move Switch files to proper directories
- [ ] **Type safety** - Add more type annotations
- [ ] **Error handling** - Improve error recovery
- [ ] **Performance** - Optimize card operations

### Documentation

- [ ] **API documentation** - Document all public methods
- [ ] **Setup guide** - Project setup instructions
- [ ] **Contributing guide** - How to add new features
- [ ] **Deployment guide** - How to build and release

### Testing

- [ ] **Integration tests** - Full game scenarios
- [ ] **Performance tests** - Large deck handling
- [ ] **Edge case tests** - Unusual situations
- [ ] **Manual test scripts** - Guided testing procedures

## Completed Tasks ✅

### Week 1 (Completed)

- [x] Created basic card game foundation
- [x] Implemented Card, Deck, Hand, Player classes
- [x] Set up GameManager and GameRules architecture
- [x] Created Switch-specific deck factory
- [x] Built test framework
- [x] Added automated test suite
- [x] Fixed compilation errors in switch_game_rules.gd
- [x] Added null safety improvements
- [x] Created comprehensive documentation

## Task Management

### Priority Levels

- 🔴 **Critical** - Blocking issues, must fix immediately
- 🟠 **High** - Important features, next in queue
- 🟡 **Medium** - Nice to have, can be delayed
- 🟢 **Low** - Future considerations

### Status Tracking

- ⏳ **Todo** - Not started
- 🚧 **In Progress** - Currently working on
- 🔍 **In Review** - Completed, awaiting review
- ✅ **Done** - Completed and tested
- ❌ **Cancelled** - No longer needed

### Time Estimates

- Small task: 2-4 hours
- Medium task: 4-8 hours (1 day)
- Large task: 1-3 days
- Epic: 1+ weeks

## Weekly Planning

### Monday Planning

- Review previous week's progress
- Prioritize current week's tasks
- Identify blockers and dependencies
- Update time estimates

### Wednesday Check-in

- Review progress on current tasks
- Adjust priorities if needed
- Address any blockers
- Plan remainder of week

### Friday Retrospective

- Review completed work
- Document lessons learned
- Update task estimates
- Plan next week's focus

## Issue Tracking

### Current Blockers

1. **Card dealing bug** - Preventing basic testing
2. **Turn system incomplete** - Affects all gameplay testing

### Risk Items

1. **Run system complexity** - May take longer than estimated
2. **UI framework choice** - Need to decide on visual approach
3. **Testing coverage** - Need more edge case scenarios

### Dependencies

- Turn system depends on card dealing fix
- Penalty system depends on turn system
- UI features depend on core mechanics
- Multiplayer depends on stable single-player

## Communication

### Daily Updates

Post progress updates in project channel:

- What was completed yesterday
- What's planned for today
- Any blockers or help needed

### Weekly Summary

Every Friday, summarize:

- Tasks completed this week
- Goals for next week
- Any architectural decisions made
- Updated project timeline

### Milestone Reviews

At each major milestone:

- Demo current functionality
- Review code quality metrics
- Update project roadmap
- Gather feedback and adjust plans
