# Week 3 Implementation: Scene Suggestion Engine + Writing Goals

**Date**: 2026-03-29
**Branch**: milestone-5-phase2-ai-analytics
**Status**: 🚀 Active Implementation

---

## Week 3 Overview

**Duration**: 5 working days
**Features**: 2 high-value features
**Focus**: AI foundation + Analytics foundation

### Features This Week
1. **Scene Suggestion Engine** (Days 1-3) - AI-powered scene continuation suggestions
2. **Writing Goals & Streaks** (Days 4-5) - Daily/weekly word count goals with streak tracking

---

## Feature 1: Scene Suggestion Engine (Days 1-3)

### Day 1: Foundation & Data Models

#### Morning Tasks
- [ ] **Create Data Models**
  - [ ] `SceneSuggestion` model (suggestedText, relevanceScore, rationale, alternativeApproaches)
  - [ ] `SceneSuggestionRequest` model (currentScene, previousScenes, genre, tone, characters)
  - [ ] Add to `lib/models/` directory
  - [ ] Write unit tests for models

#### Afternoon Tasks
- [ ] **Create SceneSuggestionService**
  - [ ] Extend `AIChatService` for scene-specific AI calls
  - [ ] Implement `compressContext` for scene history management
  - [ ] Add method: `Future<List<SceneSuggestion>> generateSceneSuggestions(SceneSuggestionRequest request)`
  - [ ] Add error handling and timeout logic

---

### Day 2: AI Integration & Prompts

#### Morning Tasks
- [ ] **Add Scene-Specific Prompts**
  - [ ] Create scene suggestion prompts in `WritingPromptService`
  - [ ] Implement prompts for different genres (fantasy, romance, sci-fi, mystery, etc.)
  - [ ] Add tone adaptation prompts (serious, humorous, dark, etc.)
  - [ ] Create prompt templates for scene continuation

#### Afternoon Tasks
- [ ] **Implement Suggestion Ranking**
  - [ ] Add relevance scoring algorithm
  - [ ] Implement coherence checking with previous scenes
  - [ ] Add creativity scoring for uniqueness
  - [ ] Create suggestion filtering and sorting logic

---

### Day 3: UI & Testing

#### Morning Tasks
- [ ] **Build Scene Suggestion UI**
  - [ ] Create `SceneSuggestionWidget` for displaying suggestions
  - [ ] Implement suggestion acceptance/rejection buttons
  - [ ] Add suggestion modification interface
  - [ ] Create loading states for AI generation
  - [ ] Add error states and retry logic

#### Afternoon Tasks
- [ ] **Testing & Integration**
  - [ ] Write unit tests for `SceneSuggestionService`
  - [ ] Write integration tests for AI calls
  - [ ] Write widget tests for `SceneSuggestionWidget`
  - [ ] Test with different genres and tones
  - [ ] Test suggestion quality and relevance
  - [ ] Add localization support (7 languages)
  - [ ] Ensure accessibility (screen reader support)

---

## Feature 2: Writing Goals & Streaks (Days 4-5)

### Day 4: Foundation & Service

#### Morning Tasks
- [ ] **Create Data Models**
  - [ ] `WritingGoal` model (id, type, targetWordCount, startDate, endDate, dailyProgress)
  - [ ] `GoalType` enum (daily, weekly, monthly, total)
  - [ ] `DailyProgress` model (date, wordsWritten, goalAchieved, writingTimeMinutes)
  - [ ] Add to `lib/models/` directory
  - [ ] Write unit tests for models

#### Afternoon Tasks
- [ ] **Create WritingGoalsService**
  - [ ] Implement local-first goal storage (SharedPreferences)
  - [ ] Add method: `Future<void> setGoal(WritingGoal goal)`
  - [ ] Add method: `Future<List<WritingGoal>> getGoals()`
  - [ ] Add method: `Future<void> updateDailyProgress(String goalId, int wordsWritten)`
  - [ ] Implement streak calculation logic
  - [ ] Add goal achievement detection
  - [ ] Write unit tests for service

---

### Day 5: UI & Integration

#### Morning Tasks
- [ ] **Build Writing Goals UI**
  - [ ] Create `WritingGoalsScreen` for goal management
  - [ ] Implement goal setting interface (type, target, date range)
  - [ ] Create progress display widget (circular progress, streak counter)
  - [ ] Add goal achievement celebration animation
  - [ ] Implement notification system for goal achievements
  - [ ] Add loading and error states

#### Afternoon Tasks
- [ ] **Integration & Testing**
  - [ ] Integrate with chapter editor for word count tracking
  - [ ] Connect to existing user progress tracking
  - [ ] Write widget tests for goals UI
  - [ ] Test streak calculation accuracy
  - [ ] Test goal achievement detection
  - [ ] Add localization support (7 languages)
  - [ ] Ensure accessibility (screen reader support)
  - [ ] Test offline functionality

---

## Quality Gates

### Code Quality
- [ ] **0 Lint Errors**
  - Run `make lint` and fix all issues
  - Ensure code follows project style guide

### Testing
- [ ] **85%+ Test Coverage**
  - Write comprehensive unit tests
  - Write integration tests for AI features
  - Write widget tests for UI components
  - Run `make test` and verify coverage

### Documentation
- [ ] **Code Documentation**
  - Add doc comments to all public APIs
  - Document complex algorithms
  - Add usage examples in comments

---

## Risk Management

### Potential Issues
1. **AI Suggestion Quality**: May need prompt tuning
   - **Mitigation**: Implement feedback mechanism, iterate on prompts
2. **Streak Calculation**: Edge cases (midnight boundaries, timezones)
   - **Mitigation**: Comprehensive testing, clear documentation
3. **Performance**: AI generation may be slow
   - **Mitigation**: Implement caching, show loading indicators

### Fallback Plans
- If AI suggestions are low quality: Add manual scene templates
- If streak calculation is buggy: Simplify to daily streaks only
- If UI is complex: Create simpler MVP first, iterate later

---

## Success Criteria

### Scene Suggestion Engine
- ✅ Generates 3-5 scene continuation suggestions
- ✅ Maintains character consistency with previous scenes
- ✅ Adapts to genre and tone preferences
- ✅ Provides rationale for each suggestion
- ✅ Allows writer to accept, modify, or reject suggestions
- ✅ Works offline (with cached suggestions)
- ✅ Localized for 7 languages
- ✅ Accessible (WCAG AA compliance)

### Writing Goals & Streaks
- ✅ Set daily, weekly, monthly, and total goals
- ✅ Track words written per session
- ✅ Calculate and display writing streaks
- ✅ Show progress towards goals
- ✅ Celebrate goal achievements
- ✅ Works offline
- ✅ Localized for 7 languages
- ✅ Accessible (WCAG AA compliance)

---

## Week 3 Deliverables

### Code Files
- `lib/models/scene_suggestion.dart`
- `lib/models/writing_goal.dart`
- `lib/services/scene_suggestion_service.dart`
- `lib/services/writing_goals_service.dart`
- `lib/features/ai_scene_suggestion/` (new feature directory)
- `lib/features/writing_goals/` (new feature directory)

### Test Files
- `test/models/scene_suggestion_test.dart`
- `test/models/writing_goal_test.dart`
- `test/services/scene_suggestion_service_test.dart`
- `test/services/writing_goals_service_test.dart`
- `test/features/ai_scene_suggestion/` (widget tests)
- `test/features/writing_goals/` (widget tests)

### Documentation
- Updated ROADMAP.md with Week 3 progress
- Technical notes in STATE.md
- Any AI prompt tuning learnings

---

## Next Week Preview

**Week 4**: Character Consistency Checker + Progress Dashboard
- Days 1-3: Character Consistency Checker
- Days 4-5: Progress Dashboard

---

**Week 3 Status**: 🚀 **Ready to Start**

**Estimated Completion**: 2026-04-04 (end of Week 3)
