import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:workin_fit/l10n/app_localizations.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';
import 'package:workin_fit/providers/workout_providers.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  ConsumerState<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _nameController = TextEditingController();
  final List<WorkoutConfig> _workouts = [];


  /* void _addTabataWorkout(String exerciseId) {
    setState(() {
      _workouts.add(TabataConfig(
        exerciseId: exerciseId,
        workTime: 20,
        restTime: 10,
        rounds: 8,
      ));
    });
  } */

  Future<void> _saveSession() async {
    final session = Session(
      id: const Uuid().v4(),
      name: _nameController.text,
      workouts: _workouts,
      difficulty: DifficultyLevel.intermediate,
      isCustom: true,
      userId: ref.read(currentUserIdProvider),
    );

    try {
      await ref.read(sessionActionsProvider).createSession(session);
      
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.sessions_create_success)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.sessions_error_generic(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);

    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.sessions_create_title)),
      body: exercisesAsync.when(
        data: (exercises) => Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localizations.sessions_name_label,
              ),
            ),
            // Exercise selection and workout config UI
            // ...
            ElevatedButton(
              onPressed: _saveSession,
              child: Text(localizations.sessions_save_button),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text(
          localizations.sessions_error_generic(err.toString()),
        ),
      ),
    );
  }
}

// Example: Display Sessions List
class SessionsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);

    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.sessions_list_title)),
      body: sessionsAsync.when(
        data: (sessions) => ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return ListTile(
              title: Text(session.name),
              subtitle: Text(
                '${session.exerciseCount} exercises • ${session.durationDisplay}'
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await ref.read(sessionActionsProvider)
                      .deleteSession(session.id);
                },
              ),
              onTap: () {
                // Navigate to workout execution
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text(
          localizations.sessions_error_generic(err.toString()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateSessionScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}