import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/features/character_consistency/services/character_consistency_service.dart';
import 'package:writer/features/character_consistency/widgets/character_profile_card.dart';
import 'package:writer/features/character_consistency/widgets/character_creation_dialog.dart';
import 'package:writer/models/character_profile.dart';

final characterConsistencyServiceProvider =
    Provider<CharacterConsistencyService>((ref) {
      return CharacterConsistencyService();
    });

final characterProfilesProvider =
    FutureProvider.autoDispose<List<CharacterProfile>>((ref) async {
      final service = ref.watch(characterConsistencyServiceProvider);
      return service.getProfiles();
    });

class CharacterConsistencyScreen extends ConsumerStatefulWidget {
  const CharacterConsistencyScreen({super.key});

  @override
  ConsumerState<CharacterConsistencyScreen> createState() =>
      _CharacterConsistencyScreenState();
}

class _CharacterConsistencyScreenState
    extends ConsumerState<CharacterConsistencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(characterProfilesProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfiles() async {
    ref.invalidate(characterProfilesProvider);
  }

  void _showCreateCharacterDialog() {
    showDialog(
      context: context,
      builder: (context) => CharacterCreationDialog(
        onCharacterCreated:
            (
              name,
              age,
              role,
              physicalTraits,
              personalityTraits,
              speechPattern,
              behavioralTendencies,
              relationships,
            ) async {
              final service = ref.read(characterConsistencyServiceProvider);
              await service.createProfile(
                name: name,
                age: age,
                role: role,
                physicalTraits: physicalTraits,
                personalityTraits: personalityTraits,
                speechPattern: speechPattern,
                behavioralTendencies: behavioralTendencies,
                relationships: relationships,
              );
              if (mounted) {
                Navigator.of(context).pop();
                _refreshProfiles();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Character profile created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
      ),
    );
  }

  Future<void> _deleteCharacter(CharacterProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character Profile'),
        content: Text(
          'Are you sure you want to delete ${profile.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(characterConsistencyServiceProvider);
      await service.deleteProfile(profile.id);
      if (mounted) {
        _refreshProfiles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Consistency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search characters by name, role, or traits...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProfiles,
              child: Consumer(
                builder: (context, ref, child) {
                  final profilesAsync = ref.watch(characterProfilesProvider);

                  return profilesAsync.when(
                    data: (profiles) {
                      final filteredProfiles = _searchQuery.isEmpty
                          ? profiles
                          : profiles
                                .where(
                                  (profile) =>
                                      profile.name.toLowerCase().contains(
                                        _searchQuery.toLowerCase(),
                                      ) ||
                                      (profile.role?.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ??
                                          false) ||
                                      profile.personalityTraits.any(
                                        (trait) => trait.toLowerCase().contains(
                                          _searchQuery.toLowerCase(),
                                        ),
                                      ),
                                )
                                .toList();

                      if (filteredProfiles.isEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No character profiles yet'
                                      : 'No characters found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Create your first character profile to start tracking consistency'
                                      : 'Try a different search term',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _showCreateCharacterDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Character'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredProfiles.length,
                        itemBuilder: (context, index) {
                          final profile = filteredProfiles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CharacterProfileCard(
                              profile: profile,
                              onDelete: () => _deleteCharacter(profile),
                              onTap: () => _showCharacterDetails(profile),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('Error loading profiles: $error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshProfiles,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCharacterDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('New Character'),
      ),
    );
  }

  void _showCharacterDetails(CharacterProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CharacterDetailScreen(profile: profile),
      ),
    );
  }
}

class _CharacterDetailScreen extends ConsumerStatefulWidget {
  final CharacterProfile profile;

  const _CharacterDetailScreen({required this.profile});

  @override
  ConsumerState<_CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState
    extends ConsumerState<_CharacterDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.profile.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.profile.role != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Role'),
                  subtitle: Text(widget.profile.role!),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.profile.age != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Age'),
                  subtitle: Text('${widget.profile.age} years old'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Personality Traits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.profile.personalityTraits
                          .map(
                            (trait) => Chip(
                              label: Text(trait),
                              backgroundColor: Colors.blue.shade50,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.accessibility, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Physical Traits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.profile.physicalTraits
                          .map(
                            (trait) => Chip(
                              label: Text(trait),
                              backgroundColor: Colors.green.shade50,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Speech Pattern',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.profile.speechPattern.typicalTone != null) ...[
                      const Text(
                        'Tone:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.profile.speechPattern.typicalTone!),
                      const SizedBox(height: 8),
                    ],
                    if (widget
                        .profile
                        .speechPattern
                        .typicalPhrases
                        .isNotEmpty) ...[
                      const Text(
                        'Typical Phrases:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.profile.speechPattern.typicalPhrases
                            .map(
                              (phrase) => Chip(
                                label: Text(phrase),
                                backgroundColor: Colors.purple.shade50,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Behavioral Tendencies',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.profile.behavioralTendencies.map(
                      (behavior) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(behavior)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Relationships',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.profile.relationships.isEmpty)
                      const Text('No relationships defined')
                    else
                      ...widget.profile.relationships.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(entry.value),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Appearances: ${widget.profile.totalAppearances}',
                    ),
                    Text(
                      'Consistency Score: ${(widget.profile.consistencyScore * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
