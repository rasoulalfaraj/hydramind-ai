import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/database/vault.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';

final vaultProvider = Provider<Vault>(
  (ref) => throw StateError('Inject the vault before boot'),
);
final initialProvider = Provider<AppData>((ref) => AppData());
final appProvider = StateNotifierProvider<AppController, AppData>(
  (ref) => AppController(ref.read(vaultProvider), ref.read(initialProvider)),
);

class AppController extends StateNotifier<AppData> {
  final Vault vault;
  Future<void> queue = Future.value();
  AppController(this.vault, AppData initial) : super(initial);
  Future<void> mutate(AppData Function(AppData) change) {
    final operation = queue.then((_) async {
      final next = change(state);
      await vault.save(next);
      state = next;
    });
    queue = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> patch(Map<String, dynamic> values) =>
      mutate((s) => s.patch(values));
  Future<void> add(
    int ml,
    Drink drink,
    DateTime at,
    String note, {
    String? id,
  }) {
    if (ml < 1 ||
        ml > 3000 ||
        at.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      throw ArgumentError('Invalid intake');
    }
    return mutate((s) {
      final entry = Intake(
        id: id ?? const Uuid().v4(),
        ml: ml,
        drink: drink,
        at: at,
        note: note,
      );
      final entries = [...s.entries.where((e) => e.id != entry.id), entry]
        ..sort((a, b) => b.at.compareTo(a.at));
      final targets = {...s.dailyTargets};
      final goal = HydrationEngine.estimate(s.profile).beverageMl;
      if (goal != null) targets.putIfAbsent(dayKey(at), () => goal);
      return s.patch({
        'entries': entries.map((e) => e.toJson()).toList(),
        'targets': targets,
      });
    });
  }

  Future<void> remove(String id) => mutate(
    (s) => s.patch({
      'entries': s.entries
          .where((e) => e.id != id)
          .map((e) => e.toJson())
          .toList(),
    }),
  );
  Future<void> erase() {
    final op = queue.then((_) async {
      await vault.clear();
      await Vault.secure.delete(key: 'backend_url');
      await Vault.secure.delete(key: 'backend_token');
      state = AppData();
    });
    queue = op.catchError((Object _) {});
    return op;
  }
}
