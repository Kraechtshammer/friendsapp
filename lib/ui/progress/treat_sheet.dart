import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/stamps.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/number_stepper.dart';
import '../widgets/section_label.dart';

/// Opens the sheet that adds a treat (no [treat]) or edits a waiting one:
/// name, stamp number, move up or down and delete. A new treat starts with
/// the default card size from the settings.
Future<void> showTreatSheet(
  BuildContext context,
  WidgetRef ref, {
  Treat? treat,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.kept.surface,
  builder: (_) => _TreatSheet(treat),
);

class _TreatSheet extends ConsumerStatefulWidget {
  const _TreatSheet(this.treat);

  final Treat? treat;

  @override
  ConsumerState<_TreatSheet> createState() => _TreatSheetState();
}

class _TreatSheetState extends ConsumerState<_TreatSheet> {
  late final _name = TextEditingController(text: widget.treat?.name ?? '');
  late int _stamps =
      widget.treat?.stampsNeeded ??
      ref.read(settingsProvider).value?.stampWeights.cardSize ??
      const StampWeights().cardSize;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final navigator = Navigator.of(context);
    final repo = ref.read(treatsRepositoryProvider);
    final treat = widget.treat;
    if (treat == null) {
      await repo.add(name, _stamps);
    } else {
      if (name != treat.name) await repo.rename(treat.id, name);
      if (_stamps != treat.stampsNeeded) {
        await repo.setStampsNeeded(treat.id, _stamps);
      }
    }
    navigator.pop();
  }

  Future<void> _move(bool up) async {
    final navigator = Navigator.of(context);
    await ref.read(treatsRepositoryProvider).move(widget.treat!.id, up: up);
    navigator.pop();
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    await ref.read(treatsRepositoryProvider).delete(widget.treat!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final treat = widget.treat;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            treat == null ? l10n.treatAdd : l10n.treatEdit,
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          SectionLabel(l10n.treatNameLabel),
          KeptTextField(
            controller: _name,
            fillColor: kept.ground,
            textCapitalization: TextCapitalization.sentences,
          ),
          SectionLabel(l10n.treatStampsLabel),
          NumberStepper(
            value: _stamps,
            min: 1,
            max: 200,
            onChanged: (v) => setState(() => _stamps = v),
          ),
          MainButton(
            label: l10n.save,
            onPressed: _name.text.trim().isEmpty ? null : () => _save(),
          ),
          if (treat != null)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: GreyButton(
                    label: l10n.treatMoveUp,
                    onPressed: () => unawaited(_move(true)),
                  ),
                ),
                Expanded(
                  child: GreyButton(
                    label: l10n.treatMoveDown,
                    onPressed: () => unawaited(_move(false)),
                  ),
                ),
              ],
            ),
          if (treat != null)
            GreyButton(
              label: l10n.treatDelete,
              onPressed: () => unawaited(_delete()),
            ),
        ],
      ),
    );
  }
}
