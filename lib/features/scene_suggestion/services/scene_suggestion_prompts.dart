class SceneSuggestionPrompts {
  static String getGenrePrompt(String genre) {
    switch (genre.toLowerCase()) {
      case 'fantasy':
        return '''
Focus on fantasy elements:
- World-building details (magic systems, mythical creatures, unique settings)
- Character arcs involving destiny, power, or ancient prophecies
- Sensory details that bring fantasy worlds to life
- Balance between wonder and danger
- Consider character motivations and magical consequences
''';
      case 'romance':
        return '''
Focus on romantic elements:
- Emotional tension and character chemistry
- Subtle gestures, expressions, and internal monologues
- Relationship dynamics and conflict
- Authentic dialogue that reveals character feelings
- Pacing that builds emotional connection
- Consider character vulnerabilities and growth
''';
      case 'scifi':
        return '''
Focus on science fiction elements:
- Technological details and their implications
- Future society implications and ethical questions
- Scientific concepts made accessible
- Human response to technological change
- Balance between hard sci-fi and character drama
- Consider consequences of scientific advancement
''';
      case 'mystery':
        return '''
Focus on mystery elements:
- Clues and red herrings woven naturally
- Tension and suspense building
- Character revelations and secrets
- Pacing that maintains intrigue
- Logical plot progression
- Consider reader engagement and puzzle-solving
''';
      case 'thriller':
        return '''
Focus on thriller elements:
- High stakes and immediate danger
- Pacing that creates tension and urgency
- Character decisions under pressure
- Unexpected twists and turns
- Sensory details that heighten suspense
- Consider psychological elements and paranoia
''';
      case 'horror':
        return '''
Focus on horror elements:
- Atmospheric details that create dread
- Psychological horror and primal fears
- Pacing that builds tension gradually
- Character vulnerability and isolation
- Sensory details that unsettle and disturb
- Consider emotional impact and catharsis
''';
      case 'literary':
        return '''
Focus on literary fiction elements:
- Character depth and internal conflict
- Themes and subtext woven throughout
- Lyrical prose and sensory details
- Emotional authenticity and nuance
- Pacing that serves character development
- Consider universal human experiences
''';
      case 'youngadult':
        return '''
Focus on young adult fiction elements:
- Character growth and self-discovery
- Authentic teenage voice and perspective
- Relationships and social dynamics
- Themes of identity, belonging, and independence
- Balance between internal and external conflict
- Consider relatability and emotional authenticity
''';
      case 'historical':
        return '''
Focus on historical fiction elements:
- Period-accurate details and atmosphere
- Social context and historical significance
- Character perspectives shaped by their time
- Language and dialogue appropriate to era
- Themes that resonate across time periods
- Consider historical authenticity and accessibility
''';
      default:
        return '''
Focus on compelling narrative elements:
- Strong character voice and motivation
- Clear conflict and stakes
- Vivid sensory details and atmosphere
- Natural dialogue that reveals character
- Pacing that serves the story
- Consider emotional resonance and reader engagement
''';
    }
  }

  static String getTonePrompt(String tone) {
    switch (tone.toLowerCase()) {
      case 'serious':
        return '''
Maintain a serious tone:
- Weighty subject matter treated with appropriate gravity
- Emotional depth without melodrama
- Thoughtful pacing and contemplation
- Avoid humor or levity unless deliberately used for contrast
- Focus on consequences and responsibility
''';
      case 'humorous':
        return '''
Maintain a humorous tone:
- Witty dialogue and observational humor
- Comedic timing and absurdity
- Light-hearted approach to situations
- Balance humor with genuine character moments
- Use humor to reveal character truths
''';
      case 'dark':
        return '''
Maintain a dark tone:
- Explore themes of mortality, suffering, or corruption
- Gritty details and unpleasant truths
- Moral ambiguity and flawed characters
- Atmospheric oppression and hopelessness
- Avoid easy answers or happy endings
''';
      case 'light':
        return '''
Maintain a light tone:
- Optimistic perspective and hopeful outlook
- Gentle humor and warmth
- Lower stakes and conflicts
- Comfortable pace and pleasant atmosphere
- Focus on joy, wonder, or discovery
''';
      case 'dramatic':
        return '''
Maintain a dramatic tone:
- Heightened emotions and intense conflict
- Significant stakes and consequences
- Powerful character moments and revelations
- Dynamic pacing that builds tension
- Focus on transformation and catharsis
''';
      case 'romantic':
        return '''
Maintain a romantic tone:
- Emotional intimacy and connection
- Tender moments and heartfelt gestures
- Focus on relationships and feelings
- Soft, sensual details and atmosphere
- Emphasize love, longing, and devotion
''';
      case 'suspenseful':
        return '''
Maintain a suspenseful tone:
- Tension and uncertainty throughout
- Building anticipation and anxiety
- Hidden information and gradual reveals
- Urgent pacing and imminent danger
- Focus on psychological pressure
''';
      default:
        return '''
Maintain a neutral tone:
- Balanced approach to emotions and events
- Objective perspective on action and dialogue
- Natural pacing appropriate to the scene
- Focus on clarity and authenticity
- Let the scene speak for itself
''';
    }
  }

  static String buildScenePrompt({
    required String currentScene,
    required String genre,
    required String tone,
    List<String> previousScenes = const [],
    String? sceneContext,
    int suggestionCount = 3,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'You are an expert fiction writer helping with scene continuation. ',
    );
    buffer.writeln(
      'Generate $suggestionCount distinct scene continuation suggestions.',
    );
    buffer.writeln();

    if (genre.isNotEmpty && genre != 'general') {
      buffer.writeln('**Genre Guidelines**');
      buffer.writeln(getGenrePrompt(genre));
      buffer.writeln();
    }

    if (tone.isNotEmpty && tone != 'neutral') {
      buffer.writeln('**Tone Guidelines**');
      buffer.writeln(getTonePrompt(tone));
      buffer.writeln();
    }

    buffer.writeln('**Current Scene**');
    buffer.writeln(currentScene);
    buffer.writeln();

    if (previousScenes.isNotEmpty) {
      buffer.writeln('**Previous Scenes for Context**');
      for (var i = 0; i < previousScenes.length; i++) {
        buffer.writeln('${i + 1}. ${previousScenes[i]}');
      }
      buffer.writeln();
    }

    if (sceneContext != null && sceneContext.isNotEmpty) {
      buffer.writeln('**Additional Context**');
      buffer.writeln(sceneContext);
      buffer.writeln();
    }

    buffer.writeln();
    buffer.writeln('**Response Format**');
    buffer.writeln('Provide your response in this exact format:');
    buffer.writeln();
    buffer.writeln('SUGGESTION 1:');
    buffer.writeln('[Scene continuation text]');
    buffer.writeln('RATIONALE: [Why this works based on genre/tone]');
    buffer.writeln(
      'ALTERNATIVES: [Alternative 1; Alternative 2; Alternative 3]',
    );
    buffer.writeln();
    buffer.writeln('SUGGESTION 2:');
    buffer.writeln('[Scene continuation text]');
    buffer.writeln('RATIONALE: [Why this works]');
    buffer.writeln('ALTERNATIVES: [Alternatives]');
    buffer.writeln();
    buffer.writeln('[Continue for all $suggestionCount suggestions]');

    return buffer.toString().trimRight();
  }

  static String enhancePromptWithCharacters(
    String prompt,
    List<Map<String, String>> characters,
  ) {
    if (characters.isEmpty) {
      return prompt;
    }

    final buffer = StringBuffer(prompt);

    buffer.writeln();
    buffer.writeln();
    buffer.writeln('**Character Information**');
    buffer.writeln('Ensure suggestions are consistent with these characters:');

    for (final character in characters) {
      final name = character['name'] ?? 'Unknown';
      final role = character['role'];
      final bio = character['bio'];

      buffer.write('- **$name**');
      if (role != null && role.isNotEmpty) {
        buffer.write(' ($role)');
      }
      buffer.writeln();

      if (bio != null && bio.isNotEmpty) {
        buffer.writeln('  $bio');
      }
    }

    return buffer.toString().trimRight();
  }

  static List<String> getSuggestionVariations({
    required String baseSuggestion,
    required String genre,
    required String tone,
  }) {
    final variations = <String>[];

    switch (genre.toLowerCase()) {
      case 'fantasy':
        variations
          ..add(
            'Focus on magical elements and world-building in the continuation.',
          )
          ..add('Emphasize character growth and destiny.')
          ..add(
            'Include sensory details that bring the fantasy setting to life.',
          );
        break;
      case 'mystery':
        variations
          ..add('Introduce subtle clues or hints.')
          ..add('Build suspense through careful pacing.')
          ..add('Create tension through character reactions.');
        break;
      default:
        variations
          ..add('Continue with natural character-driven action.')
          ..add('Focus on emotional resonance and character development.')
          ..add('Emphasize atmosphere and sensory details.');
    }

    return variations;
  }
}
