import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controller.dart';
import '../core/domain/engines.dart';
import '../core/services/coach_service.dart';
import '../core/theme/design.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});
  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final input = TextEditingController(), scroll = ScrollController();
  bool busy = false;
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> send([String? suggestion]) async {
    final question = (suggestion ?? input.text).trim();
    if (busy || question.isEmpty || question.length > 1000) return;
    setState(() => busy = true);
    input.clear();
    var succeeded = false;
    final l = context.l;
    await runAction(context, () async {
      final reply = await CoachService.reply(
        question,
        ref.read(appProvider),
        l,
      );
      if (!mounted) return;
      final current = ref.read(appProvider),
          safe = SafetyEngine.validatedTopic(
            'general',
            current.profile,
            current.entries,
            DateTime.now(),
            prompt: question,
          );
      final answer = const {'safety', 'medical', 'emergency'}.contains(safe)
          ? CoachService.render(safe, current, l)
          : reply.text;
      await ref
          .read(appProvider.notifier)
          .mutate(
            (d) => d.patch({
              'chat': [
                ...d.chat,
                {
                  'role': 'user',
                  'text': question,
                  'at': DateTime.now().toUtc().toIso8601String(),
                },
                {
                  'role': 'assistant',
                  'text': answer,
                  'cloud': reply.cloud,
                  'at': DateTime.now().toUtc().toIso8601String(),
                },
              ].reversed.take(100).toList().reversed.toList(),
            }),
          );
      succeeded = true;
    });
    if (mounted) {
      if (!succeeded) input.text = question;
      setState(() => busy = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    final d = ref.watch(appProvider), l = c.l;
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(20),
            children: [
              Notice(l.coachIntro, icon: Icons.auto_awesome),
              const SizedBox(height: 20),
              if (d.chat.isEmpty) ...[
                const Icon(Icons.bubble_chart, size: 72, color: turquoise),
                const SizedBox(height: 18),
                Text(
                  l.tagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                ...[l.targetQuestion, l.weatherQuestion, l.habitQuestion].map(
                  (q) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: busy ? null : () => send(q),
                      child: Text(q),
                    ),
                  ),
                ),
              ],
              ...d.chat.map((m) {
                final user = m['role'] == 'user';
                return Align(
                  alignment: user
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: user ? ocean : Theme.of(c).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!user)
                          Text(
                            m['cloud'] == true ? l.cloudCoach : l.offlineCoach,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(c).colorScheme.primary,
                            ),
                          ),
                        SelectableText(
                          m['text'],
                          style: TextStyle(
                            color: user ? Colors.white : null,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (busy)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(l.thinking),
                ),
              if (d.chat.isNotEmpty)
                TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => runAction(c, () async {
                          if (await confirmDelete(c)) {
                            await ref.read(appProvider.notifier).patch({
                              'chat': [],
                            });
                          }
                        }),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l.deleteChat),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: l.ask,
                      counterText: '',
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: busy ? null : () => send(),
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: l.send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
