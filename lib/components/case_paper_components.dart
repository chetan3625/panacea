import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionCard – titled card container used for each clinical section
// ─────────────────────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accent = false,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleColor = accent ? cs.primary : cs.onSurface;
    final borderColor = accent ? cs.primary.withValues(alpha: 0.35) : cs.outline;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              color: accent
                  ? cs.primary.withValues(alpha: 0.08)
                  : cs.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: titleColor),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChoiceChipGroup – multi (or single) select chip group, crash-proof widths
// ─────────────────────────────────────────────────────────────────────────────
class ChoiceChipGroup extends StatelessWidget {
  const ChoiceChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = true,
    this.horizontalOnMobile = false,
    this.dense = false,
  });

  final String label;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multiSelect;
  final bool horizontalOnMobile;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    Widget chipRow({bool horizontal = false}) {
      final chips = options.map((option) {
        final active = selected.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: active,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (_) {
            final next = {...selected};
            if (multiSelect) {
              active ? next.remove(option) : next.add(option);
            } else {
              next..clear()..add(option);
            }
            onChanged(next);
          },
        );
      }).toList();

      if (horizontal) {
        return SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) => chips[i],
          ),
        );
      }
      return Wrap(spacing: 6, runSpacing: dense ? 2 : 6, children: chips);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: dense ? 4 : 8),
        ],
        chipRow(horizontal: horizontalOnMobile && isMobile),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MultiSelectFilterCloud – searchable bottom-sheet multi-picker
// ─────────────────────────────────────────────────────────────────────────────
class MultiSelectFilterCloud extends StatelessWidget {
  const MultiSelectFilterCloud({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final IconData? icon;

  Future<void> _openSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
        title: label,
        options: options,
        selected: selected,
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            TextButton.icon(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                selected.isEmpty ? 'Select' : 'Edit (${selected.length})',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: selected.map((item) => Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () {
                final next = {...selected}..remove(item);
                onChanged(next);
              },
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
  });
  final String title;
  final List<String> options;
  final Set<String> selected;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final _search = TextEditingController();
  late Set<String> _sel = {...widget.selected};
  String _query = '';

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((o) => o.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final sh = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: SizedBox(
        height: sh * 0.82,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_sel),
                    child: const Text('Done'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final opt = filtered[i];
                    return CheckboxListTile(
                      value: _sel.contains(opt),
                      dense: true,
                      title: Text(opt),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) => setState(
                        () => v == true ? _sel.add(opt) : _sel.remove(opt),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SegmentedPillToggle – horizontal scroll-safe segmented control
// ─────────────────────────────────────────────────────────────────────────────
class SegmentedPillToggle extends StatelessWidget {
  const SegmentedPillToggle({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = options.contains(value) ? value : options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: options
                .map((o) => ButtonSegment(value: o, label: Text(o)))
                .toList(),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ModalityMatrixRow – +/0/- three-way toggle for a single stimulus
// ─────────────────────────────────────────────────────────────────────────────
class ModalityMatrixRow extends StatelessWidget {
  const ModalityMatrixRow({
    super.key,
    required this.stimulus,
    required this.value,
    required this.onChanged,
  });

  final String stimulus;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = const ['+', '0', '-'].contains(value) ? value : '0';
    final control = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: '+', label: Text('+ Amel')),
          ButtonSegment(value: '0', label: Text('Neutral')),
          ButtonSegment(value: '-', label: Text('– Agg')),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite || constraints.maxWidth < 500) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stimulus, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                control,
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(stimulus)),
              Expanded(flex: 5, child: control),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ResponsiveGrid – crash-proof Wrap-based responsive grid
// ─────────────────────────────────────────────────────────────────────────────
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.minColumnWidth = 260.0,
  });

  final List<Widget> children;
  final double spacing;
  final double minColumnWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columns = (availableWidth / (minColumnWidth + spacing))
            .floor()
            .clamp(1, 4);
        final itemWidth =
            (availableWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KeynoteCard – highlighted doctor observation card
// ─────────────────────────────────────────────────────────────────────────────
class KeynoteCard extends StatelessWidget {
  const KeynoteCard({
    super.key,
    required this.child,
    this.label = 'Doctor Peculiarity / Keynote',
  });
  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
