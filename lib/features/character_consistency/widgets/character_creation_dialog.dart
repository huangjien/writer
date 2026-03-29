import 'package:flutter/material.dart';
import 'package:writer/models/character_profile.dart';

class CharacterCreationDialog extends StatefulWidget {
  final Function(
    String name,
    int? age,
    String? role,
    List<String> physicalTraits,
    List<String> personalityTraits,
    SpeechPattern speechPattern,
    List<String> behavioralTendencies,
    Map<String, String> relationships,
  )
  onCharacterCreated;

  const CharacterCreationDialog({super.key, required this.onCharacterCreated});

  @override
  State<CharacterCreationDialog> createState() =>
      _CharacterCreationDialogState();
}

class _CharacterCreationDialogState extends State<CharacterCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _roleController = TextEditingController();

  final List<String> _physicalTraits = [];
  final List<String> _personalityTraits = [];
  final List<String> _behavioralTendencies = [];
  final Map<String, String> _relationships = {};

  String? _typicalTone;
  final List<String> _typicalPhrases = [];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final speechPattern = SpeechPattern(
        typicalTone: _typicalTone,
        typicalPhrases: _typicalPhrases,
      );

      widget.onCharacterCreated(
        _nameController.text.trim(),
        _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
        _roleController.text.trim().isEmpty
            ? null
            : _roleController.text.trim(),
        _physicalTraits,
        _personalityTraits,
        speechPattern,
        _behavioralTendencies,
        _relationships,
      );
    }
  }

  void _addTrait(List<String> traits, String label) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $label.toLowerCase()'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  traits.add(controller.text.trim());
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addRelationship() {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Relationship'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Character Name',
                hintText: 'e.g., Jane Smith',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: relationController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'e.g., Sister, Friend, Mentor',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  relationController.text.trim().isNotEmpty) {
                setState(() {
                  _relationships[nameController.text.trim()] =
                      relationController.text.trim();
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPhrase() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Typical Phrase'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Indeed, Quite right',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _typicalPhrases.add(controller.text.trim());
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Character Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., John Doe',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        hintText: 'e.g., 35',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        hintText: 'e.g., Protagonist',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _addTrait(_physicalTraits, 'Physical Trait'),
                    icon: const Icon(Icons.add),
                    label: const Text('Physical Trait'),
                  ),
                  Text('(${_physicalTraits.length})'),
                ],
              ),
              if (_physicalTraits.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _physicalTraits
                      .map(
                        (trait) => Chip(
                          label: Text(
                            trait,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() {
                              _physicalTraits.remove(trait);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _addTrait(_personalityTraits, 'Personality Trait'),
                    icon: const Icon(Icons.add),
                    label: const Text('Personality Trait'),
                  ),
                  Text('(${_personalityTraits.length})'),
                ],
              ),
              if (_personalityTraits.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _personalityTraits
                      .map(
                        (trait) => Chip(
                          label: Text(
                            trait,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() {
                              _personalityTraits.remove(trait);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _typicalTone,
                decoration: const InputDecoration(
                  labelText: 'Speech Tone',
                  prefixIcon: Icon(Icons.chat_bubble),
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                      'Formal',
                      'Casual',
                      'Sarcastic',
                      'Friendly',
                      'Aggressive',
                      'Shy',
                      'Professional',
                      'Slang',
                    ].map((tone) {
                      return DropdownMenuItem(value: tone, child: Text(tone));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typicalTone = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addPhrase,
                    icon: const Icon(Icons.add),
                    label: const Text('Typical Phrase'),
                  ),
                  Text('(${_typicalPhrases.length})'),
                ],
              ),
              if (_typicalPhrases.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _typicalPhrases
                      .map(
                        (phrase) => Chip(
                          label: Text(
                            phrase,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() {
                              _typicalPhrases.remove(phrase);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _addTrait(_behavioralTendencies, 'Behavior'),
                    icon: const Icon(Icons.add),
                    label: const Text('Behavior'),
                  ),
                  Text('(${_behavioralTendencies.length})'),
                ],
              ),
              if (_behavioralTendencies.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _behavioralTendencies
                      .map(
                        (behavior) => Chip(
                          label: Text(
                            behavior,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onDeleted: () {
                            setState(() {
                              _behavioralTendencies.remove(behavior);
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addRelationship,
                    icon: const Icon(Icons.add),
                    label: const Text('Relationship'),
                  ),
                  Text('(${_relationships.length})'),
                ],
              ),
              if (_relationships.isNotEmpty)
                ..._relationships.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.key)),
                        const Text(' → '),
                        Expanded(child: Text(entry.value)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            setState(() {
                              _relationships.remove(entry.key);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Create Profile')),
      ],
    );
  }
}
