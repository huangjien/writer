import 'package:flutter/material.dart';

enum WritingPromptCategory {
  sceneStarters(
    label: 'Scene Starters',
    icon: Icons.play_arrow,
    description: 'Beginnings to spark your story',
  ),
  characterDevelopment(
    label: 'Character',
    icon: Icons.person,
    description: 'Build rich, complex characters',
  ),
  dialogue(
    label: 'Dialogue',
    icon: Icons.chat_bubble,
    description: 'Craft compelling conversations',
  ),
  worldBuilding(
    label: 'World Building',
    icon: Icons.public,
    description: 'Develop your setting',
  ),
  plot(
    label: 'Plot',
    icon: Icons.auto_graph,
    description: 'Structure your narrative',
  ),
  writingExercises(
    label: 'Exercises',
    icon: Icons.edit,
    description: 'Practice specific techniques',
  ),
  templates(
    label: 'Templates',
    icon: Icons.description,
    description: 'Structured formats and frameworks',
  ),
  custom(
    label: 'Custom',
    icon: Icons.star,
    description: 'Your personal prompts',
  );

  const WritingPromptCategory({
    required this.label,
    required this.icon,
    required this.description,
  });

  final String label;
  final IconData icon;
  final String description;
}

class WritingPrompt {
  const WritingPrompt({
    required this.id,
    required this.text,
    required this.category,
    this.isCustom = false,
    this.aiContext,
  });

  final String id;
  final String text;
  final WritingPromptCategory category;
  final bool isCustom;
  final String? aiContext;

  WritingPrompt copyWith({
    String? id,
    String? text,
    WritingPromptCategory? category,
    bool? isCustom,
    String? aiContext,
  }) {
    return WritingPrompt(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      aiContext: aiContext ?? this.aiContext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category.name,
      'isCustom': isCustom,
      'aiContext': aiContext,
    };
  }

  factory WritingPrompt.fromJson(Map<String, dynamic> json) {
    return WritingPrompt(
      id: json['id'] as String,
      text: json['text'] as String,
      category: WritingPromptCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => WritingPromptCategory.custom,
      ),
      isCustom: json['isCustom'] as bool? ?? false,
      aiContext: json['aiContext'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WritingPrompt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
