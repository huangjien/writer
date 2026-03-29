# Milestone 5 Phase 2: AI + Analytics Implementation Plan

## Date: 2026-03-29
## Status: 🔄 Planning Phase
## Duration: Weeks 3-6 (4 weeks)

---

## Overview

Phase 2 focuses on delivering high-value, user-facing features that differentiate Writer as a premium novel writing application. We'll implement two major themes in parallel:

1. **Advanced AI-Assisted Writing Workflows** - Intelligent writing assistance
2. **Writing Analytics and Progress Tracking** - Data-driven insights

**Technical Feasibility**: ✅ **HIGH CONFIDENCE** (per technical assessment)

---

## Phase 2 Objectives

### Primary Goals
1. **AI-Assisted Writing** - Leverage existing AI infrastructure for intelligent features
2. **Writing Analytics** - Local-first analytics with progress tracking
3. **User Value** - Deliver features that significantly improve writing productivity
4. **Quality** - Maintain 0 lint errors, 85%+ test coverage

### Success Criteria
- ✅ 5+ AI writing features implemented and tested
- ✅ Writing analytics dashboard with progress visualization
- ✅ Word count tracking and goal setting
- ✅ All features localized and accessible
- ✅ 0 lint errors maintained

---

## Theme 1: Advanced AI-Assisted Writing Workflows

### Technical Foundation
**Existing Infrastructure (from technical assessment):**
- ✅ Remote Repository: 11 Skills API endpoints
- ✅ AI Chat Service: Comprehensive AI integration
- ✅ Writing Prompts: 40+ prompts already implemented
- ✅ RAG Search, Vector embeddings, Context compression

**What We Can Build:**
1. **Scene Suggestion Engine** - Extend Deep Agent with scene-specific prompts
2. **Character Consistency Checker** - Use existing character profiling + RAG search
3. **Plot Arc Tracking** - Build on template generation with custom skills
4. **Dialogue Enhancement** - Leverage QA Agent with dialogue-focused prompts
5. **Smart Chapter Outlines** - Extend existing scene/chapter conversion

---

### Feature 1: Scene Suggestion Engine

**Description:** AI-powered scene continuation suggestions based on current context.

**User Story:**
> As a fiction writer, I want AI to suggest scene continuations so that I can overcome writer's block and explore new narrative directions.

**Technical Approach:**
- Extend existing `Deep Agent` with scene-specific prompts
- Use `compressContext` to include previous scene context
- Implement suggestion ranking based on coherence and creativity

**Implementation Steps:**
1. Create `SceneSuggestionService` extending `AIChatService`
2. Add scene-specific prompts to `WritingPromptService`
3. Implement context window management for scene history
4. Build UI widget for suggestion display and selection
5. Add tests for suggestion quality and relevance

**Data Models:**
```dart
class SceneSuggestion {
  final String suggestedText;
  final double relevanceScore;
  final String rationale;
  final List<String> alternativeApproaches;
}

class SceneSuggestionRequest {
  final String currentScene;
  final List<String> previousScenes;
  final String genre;
  final String tone;
  final List<Character> characters;
}
```

**Acceptance Criteria:**
- ✅ Generates 3-5 scene continuation suggestions
- ✅ Maintains character consistency with previous scenes
- ✅ Adapts to genre and tone preferences
- ✅ Provides rationale for each suggestion
- ✅ Allows writer to accept, modify, or reject suggestions

**Estimated Effort:** 2-3 days

---

### Feature 2: Character Consistency Checker

**Description:** Detect inconsistencies in character behavior, appearance, and traits across scenes.

**User Story:**
> As a fiction writer, I want automatic detection of character inconsistencies so that I can maintain believable characters throughout my novel.

**Technical Approach:**
- Leverage existing character profiling (from AI chat enhancement)
- Use RAG search to find character mentions across scenes
- Implement rule-based consistency checking

**Implementation Steps:**
1. Create `CharacterConsistencyService`
2. Extract character profiles from scenes using existing AI endpoints
3. Implement consistency checks:
   - Physical appearance (eye color, height, etc.)
   - Personality traits and behavior patterns
   - Background and history
   - Relationships with other characters
4. Build UI for inconsistency reports
5. Add tests for various inconsistency scenarios

**Data Models:**
```dart
class CharacterInconsistency {
  final String characterName;
  final InconsistencyType type;
  final String location1; // Scene/chapter reference
  final String location2;
  final String description;
  final Severity severity;
  final String suggestion;
}

enum InconsistencyType {
  appearanceMismatch,
  behaviorMismatch,
  historyMismatch,
  relationshipMismatch,
}

enum Severity {
  low,
  medium,
  high,
}
```

**Acceptance Criteria:**
- ✅ Scans entire novel for character mentions
- ✅ Detects appearance inconsistencies (e.g., eye color changes)
- ✅ Detects behavior inconsistencies (e.g., personality changes)
- ✅ Provides location references for detected issues
- ✅ Suggests corrections or clarifications
- ✅ Allows writer to dismiss false positives

**Estimated Effort:** 2-3 days

---

### Feature 3: Plot Arc Tracking

**Description:** Visual plot structure and pacing analysis with narrative arc identification.

**User Story:**
> As a fiction writer, I want to visualize my story's plot structure so that I can identify pacing issues and improve narrative flow.

**Technical Approach:**
- Build on existing template generation capabilities
- Use custom Skills for plot analysis
- Implement scene classification (setup, rising action, climax, resolution)

**Implementation Steps:**
1. Create `PlotArcService` using AI template generation
2. Implement scene classification logic
3. Build plot arc visualization widget
4. Add pacing analysis (fast/slow sections)
5. Export plot structure as PDF
6. Add tests for plot arc accuracy

**Data Models:**
```dart
class PlotArc {
  final List<PlotPoint> plotPoints;
  final PlotStructure structure;
  final PacingAnalysis pacing;
  final List<PlotRecommendation> recommendations;
}

class PlotPoint {
  final String sceneId;
  final PlotPointType type;
  final int emotionalIntensity;
  final String description;
}

enum PlotPointType {
  exposition,
  incitingIncident,
  risingAction,
  climax,
  fallingAction,
  resolution,
}
```

**Acceptance Criteria:**
- ✅ Analyzes entire novel structure
- ✅ Identifies key plot points (inciting incident, climax, etc.)
- ✅ Visualizes emotional intensity across scenes
- ✅ Provides pacing recommendations
- ✅ Export plot structure as PDF
- ✅ Works for novels of any length

**Estimated Effort:** 3-4 days

---

### Feature 4: Dialogue Enhancement

**Description:** Natural dialogue suggestions and improvements with character voice consistency.

**User Story:**
> As a fiction writer, I want AI to improve my dialogue so that characters sound distinct and natural.

**Technical Approach:**
- Leverage QA Agent with dialogue-focused prompts
- Implement character voice analysis
- Provide dialogue improvement suggestions

**Implementation Steps:**
1. Create `DialogueEnhancementService`
2. Implement character voice extraction and analysis
3. Add dialogue improvement suggestions
4. Build UI for displaying dialogue improvements
5. Add tests for various dialogue scenarios

**Data Models:**
```dart
class DialogueImprovement {
  final String originalText;
  final String improvedText;
  final String characterName;
  final List<String> reasons;
  final double confidenceScore;
}
```

**Acceptance Criteria:**
- ✅ Maintains character voice consistency
- ✅ Suggests natural-sounding improvements
- ✅ Provides rationale for changes
- ✅ Allows writer to accept or reject suggestions
- ✅ Works for dialogue with multiple characters

**Estimated Effort:** 2 days

---

### Feature 5: Smart Chapter Outlines

**Description:** AI-assisted chapter planning and restructuring based on content analysis.

**User Story:**
> As a fiction writer, I want AI to suggest chapter outlines so that I can organize my story effectively.

**Technical Approach:**
- Extend existing scene/chapter conversion capabilities
- Use template generation for outline creation
- Implement outline optimization suggestions

**Implementation Steps:**
1. Create `ChapterOutlineService`
2. Analyze existing chapter content
3. Generate optimized chapter outlines
4. Implement chapter restructuring suggestions
5. Build UI for outline display and editing
6. Add tests for outline quality

**Data Models:**
```dart
class ChapterOutline {
  final String chapterId;
  final String title;
  final List<OutlineItem> items;
  final int targetWordCount;
  final int currentWordCount;
}

class OutlineItem {
  final String sceneTitle;
  final String description;
  final List<String> keyPoints;
  final int estimatedWords;
}
```

**Acceptance Criteria:**
- ✅ Analyzes existing chapter content
- ✅ Generates logical chapter outlines
- ✅ Suggests scene reordering
- ✅ Estimates word counts per scene
- ✅ Allows outline customization
- ✅ Exports outline as PDF

**Estimated Effort:** 2-3 days

---

## Theme 2: Writing Analytics and Progress Tracking

### Technical Foundation
**Existing Infrastructure:**
- ✅ `UserProgress` model: scroll offset, TTS index, timestamps
- ✅ Local storage via SharedPreferences
- ✅ Token usage tracking implemented

**What We Can Build:**
1. **Writing Goals** - Word count tracking (local + optional sync)
2. **Progress Dashboard** - Aggregate existing progress data
3. **Writing Statistics** - Words per session, speed calculations
4. **Achievement System** - Milestone celebrations
5. **Export Analytics** - Writing reports (local generation)

---

### Feature 6: Writing Goals & Streaks

**Description:** Daily/weekly word count goals with writing streak tracking.

**User Story:**
> As a fiction writer, I want to set writing goals and track my streaks so that I can maintain consistent writing habits.

**Technical Approach:**
- Build local-first goal tracking with SharedPreferences
- Implement streak calculation logic
- Add optional cloud sync for goal progress

**Implementation Steps:**
1. Create `WritingGoalsService` (local-first)
2. Define data models for goals and progress
3. Implement goal tracking and streak calculation
4. Build UI for goal setting and progress display
5. Add notifications for goal achievement
6. Implement optional cloud sync
7. Add comprehensive tests

**Data Models:**
```dart
class WritingGoal {
  final String id;
  final GoalType type;
  final int targetWordCount;
  final DateTime startDate;
  final DateTime? endDate;
  final List<DailyProgress> dailyProgress;
}

enum GoalType {
  daily,
  weekly,
  monthly,
  total,
}

class DailyProgress {
  final DateTime date;
  final int wordsWritten;
  final bool goalAchieved;
  final int writingTimeMinutes;
}
```

**Acceptance Criteria:**
- ✅ Set daily, weekly, monthly, and total goals
- ✅ Track words written per session
- ✅ Calculate and display writing streaks
- ✅ Show progress towards goals
- ✅ Celebrate goal achievements
- ✅ Optional cloud sync for progress
- ✅ Works offline

**Estimated Effort:** 2-3 days

---

### Feature 7: Progress Dashboard

**Description:** Visual progress across multiple novels with statistics and insights.

**User Story:**
> As a fiction writer managing multiple projects, I want a dashboard showing my progress across all novels so that I can prioritize my work.

**Technical Approach:**
- Aggregate data from UserProgress, WritingGoals, and chapter metadata
- Create visualization widgets for progress display
- Implement filtering and sorting options

**Implementation Steps:**
1. Create `AnalyticsDashboardService`
2. Aggregate progress data from multiple sources
3. Build dashboard UI with progress cards
4. Implement charts and visualizations
5. Add filtering by novel, time period, goal type
6. Export dashboard as PDF
7. Add tests for data accuracy

**Data Models:**
```dart
class DashboardData {
  final List<NovelProgress> novels;
  final WritingStatistics statistics;
  final List<Achievement> achievements;
  final List<GoalProgress> goals;
}

class NovelProgress {
  final String novelId;
  final String title;
  final int totalWords;
  final int chaptersCompleted;
  final int totalChapters;
  final double completionPercentage;
  final DateTime lastWritten;
}

class WritingStatistics {
  final int totalWords;
  final int totalWritingTimeMinutes;
  final double averageWordsPerHour;
  final int currentStreak;
  final int longestStreak;
  final DateTime mostProductiveDay;
}
```

**Acceptance Criteria:**
- ✅ Shows progress for all novels
- ✅ Displays writing statistics
- ✅ Visualizes progress with charts
- ✅ Filterable by novel, date range, goal type
- ✅ Export dashboard as PDF
- ✅ Updates in real-time as user writes
- ✅ Works offline

**Estimated Effort:** 3-4 days

---

### Feature 8: Writing Statistics

**Description:** Detailed writing metrics including words per session, average speed, productivity patterns.

**User Story:**
> As a fiction writer, I want detailed statistics about my writing patterns so that I can understand and improve my productivity.

**Technical Approach:**
- Track writing sessions (start time, end time, words written)
- Calculate statistics (speed, consistency, patterns)
- Identify productivity patterns and trends

**Implementation Steps:**
1. Create `WritingStatisticsService`
2. Implement session tracking
3. Calculate statistics and patterns
4. Build statistics UI with visualizations
5. Add trend analysis and insights
6. Export statistics as CSV/PDF
7. Add tests for calculation accuracy

**Data Models:**
```dart
class WritingSession {
  final DateTime startTime;
  final DateTime endTime;
  final int wordsWritten;
  final String novelId;
  final String chapterId;
}

class WritingStatistics {
  final List<WritingSession> sessions;
  final double averageWordsPerHour;
  final int totalWords;
  final int totalHours;
  final List<ProductivityPattern> patterns;
  final BestWritingTime bestTime;
}

class ProductivityPattern {
  final String dayOfWeek;
  final int averageWords;
  final int averageSessions;
}

class BestWritingTime {
  final int hour; // 0-23
  final double averageWords;
}
```

**Acceptance Criteria:**
- ✅ Tracks all writing sessions
- ✅ Calculates words per hour/speed
- ✅ Identifies most productive days/times
- ✅ Shows productivity trends over time
- ✅ Provides insights and recommendations
- ✅ Export statistics as CSV/PDF
- ✅ Works offline

**Estimated Effort:** 2-3 days

---

### Feature 9: Achievement System

**Description:** Milestone celebrations with achievement tracking and badges.

**User Story:**
> As a fiction writer, I want to earn achievements for reaching milestones so that I feel motivated and celebrated in my writing journey.

**Technical Approach:**
- Define achievement criteria (word counts, streaks, consistency)
- Implement achievement unlocking logic
- Create achievement display and notification system

**Implementation Steps:**
1. Define achievement types and criteria
2. Create `AchievementService`
3. Implement achievement tracking and unlocking
4. Build achievement UI with badges
5. Add notification system for new achievements
6. Share achievements (optional)
7. Add tests for achievement logic

**Data Models:**
```dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final DateTime unlockedAt;
  final int progress;
  final int target;
  final String iconPath;
}

enum AchievementType {
  wordCount, // e.g., "10K Words", "50K Words"
  streak, // e.g., "7-Day Streak", "30-Day Streak"
  consistency, // e.g., "Write Every Day for a Week"
  chapter, // e.g., "First Chapter", "10 Chapters"
  novel, // e.g., "First Novel Complete"
}
```

**Achievement Examples:**
- "First Words" - Write 100 words
- "Getting Started" - Write 1,000 words
- "Short Story" - Write 5,000 words
- "Novella" - Write 20,000 words
- "Novel" - Write 50,000 words
- "Epic" - Write 100,000 words
- "Daily Writer" - Write 7 days in a row
- "Marathon Writer" - Write 30 days in a row
- "Night Owl" - Write most between 10 PM - 2 AM
- "Early Bird" - Write most between 5 AM - 9 AM

**Acceptance Criteria:**
- ✅ Unlock achievements based on criteria
- ✅ Display achievements with badges
- ✅ Notify when achievements unlock
- ✅ Show progress towards locked achievements
- ✅ Share achievements (optional)
- ✅ Works offline

**Estimated Effort:** 2 days

---

### Feature 10: Export Analytics

**Description:** Generate writing reports and progress exports as PDF/CSV.

**User Story:**
> As a fiction writer, I want to export my writing statistics and progress so that I can analyze my data externally or share it with others.

**Technical Approach:**
- Use existing PDF generation infrastructure
- Create report templates for analytics
- Implement CSV export for raw data

**Implementation Steps:**
1. Create `AnalyticsExportService`
2. Design report templates (PDF)
3. Implement CSV export for raw data
4. Build export UI with format options
5. Add customization options (date range, metrics)
6. Add tests for export accuracy

**Data Models:**
```dart
class AnalyticsExport {
  final ExportFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final List<Metric> metrics;
  final String filePath;
}

enum ExportFormat {
  pdf,
  csv,
  json,
}

enum Metric {
  wordCount,
  writingTime,
  goals,
  achievements,
  progress,
}
```

**Acceptance Criteria:**
- ✅ Export as PDF with visualizations
- ✅ Export as CSV for raw data
- ✅ Export as JSON for API integration
- ✅ Customize date range and metrics
- ✅ Include charts and graphs in PDF
- ✅ Works offline

**Estimated Effort:** 1-2 days

---

## Implementation Timeline

### Week 3: AI Foundation + Goals
**Days 1-3:** Scene Suggestion Engine (Feature 1)
**Days 4-5:** Writing Goals & Streaks (Feature 6)

### Week 4: Character + Dashboard
**Days 1-3:** Character Consistency Checker (Feature 2)
**Days 4-5:** Progress Dashboard (Feature 7)

### Week 5: Plot + Statistics
**Days 1-4:** Plot Arc Tracking (Feature 3)
**Days 5:** Writing Statistics (Feature 8)

### Week 6: Dialogue + Outlines + Polish
**Days 1-2:** Dialogue Enhancement (Feature 4)
**Days 3-4:** Smart Chapter Outlines (Feature 5)
**Day 5:** Achievement System + Export (Features 9-10)

---

## Success Criteria

### Must-Have
- ✅ 10 features implemented and tested
- ✅ All features localized and accessible
- ✅ 0 lint errors maintained
- ✅ 85%+ test coverage
- ✅ All features work offline

### Nice-to-Have
- ✅ Optional cloud sync for analytics
- ✅ Share achievements to social media
- ✅ Custom achievement creation
- ✅ Advanced analytics visualizations

---

## Risk Assessment

### Low Risk
- ✅ AI features: Strong foundation from AI Chat Enhancement
- ✅ Analytics: Local-first, minimal dependencies
- ✅ All features have clear technical path

### Medium Risk
- ⚠️ AI quality: May need prompt tuning
- ⚠️ Data accuracy: Statistics must be precise
- ⚠️ Performance: Large novel analysis may be slow

### Mitigation Strategies
- Implement comprehensive testing for AI features
- Use existing, proven AI infrastructure
- Start with local-first, add optional sync later
- Monitor performance and optimize as needed

---

## Next Steps

1. **Review and approve this plan** - Confirm feature prioritization
2. **Set up Phase 2 development branch** - Create feature branches
3. **Start with Week 3 features** - Scene Suggestion Engine + Writing Goals
4. **Establish testing strategy** - Define test coverage requirements
5. **Set up continuous integration** - Ensure quality gates

---

## Dependencies

### Internal Dependencies
- ✅ Existing AI infrastructure (AI Chat Enhancement)
- ✅ Local storage (SharedPreferences)
- ✅ PDF generation (from Milestone 3)
- ✅ Existing user progress tracking

### External Dependencies
- None (all features are local-first)

---

## Conclusion

Phase 2 is ready to begin with **high confidence**. We have:
- ✅ Clear technical path for all features
- ✅ Strong foundation from AI Chat Enhancement
- ✅ Local-first approach (no backend dependencies)
- ✅ 10 high-value features planned
- ✅ 4-week implementation timeline

**Recommendation:** ✅ **Proceed with Phase 2 implementation**

**Status:** 🔄 **Ready to Start** (awaiting approval)
