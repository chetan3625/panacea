import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, required this.icon, this.color = AppColors.primary, this.tint = AppColors.primaryLight});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) => AppCard(
    color: tint,
    padding: const EdgeInsets.all(10),
    child: LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 110;
      final iconBox = DecoratedBox(
        decoration: BoxDecoration(color: AppColors.card.withValues(alpha: .75), borderRadius: BorderRadius.circular(AppRadii.control)),
        child: SizedBox(width: compact ? 30 : 38, height: compact ? 30 : 38, child: Icon(icon, size: compact ? 18 : 20, color: color)),
      );
      final content = Column(
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: compact ? 18 : 22, color: color)),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: compact ? TextAlign.center : TextAlign.start, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
        ],
      );
      return compact
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [iconBox, const SizedBox(height: 6), content])
          : Row(children: [iconBox, const SizedBox(width: 10), Expanded(child: content)]);
    }),
  );
}

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.label, this.color = AppColors.primary, this.background = AppColors.primaryLight});
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.chip)),
    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
  );
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, this.size = 40, this.color = AppColors.primary, this.background = AppColors.primaryLight});
  final String initials;
  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: size / 2,
    backgroundColor: background,
    child: Text(initials, maxLines: 1, style: TextStyle(color: color, fontSize: size * .34, fontWeight: FontWeight.w600)),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
    ?trailing,
  ]);
}

class AppChoiceChips<T> extends StatelessWidget {
  const AppChoiceChips({super.key, required this.values, required this.selected, required this.label, required this.onSelected, this.wrap = true});
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final chips = values.map((value) => ChoiceChip(
      label: Text(label(value)),
      selected: value == selected,
      onSelected: (_) => onSelected(value),
      showCheckmark: false,
      labelStyle: TextStyle(color: value == selected ? Colors.white : AppColors.secondary),
      side: BorderSide(color: value == selected ? AppColors.primary : AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
    ));
    return wrap
        ? Wrap(spacing: 6, runSpacing: 4, children: chips.toList())
        : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: chips.toList()));
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: icon == null ? const SizedBox.shrink() : Icon(icon),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: icon == null ? const SizedBox.shrink() : Icon(icon),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}

class StickyBottomBar extends StatelessWidget {
  const StickyBottomBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: children),
    ),
  );
}

class TimelineNode extends StatelessWidget {
  const TimelineNode({super.key, required this.child, this.color = AppColors.primary, this.isLast = false});
  final Widget child;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 26, child: Stack(alignment: Alignment.topCenter, children: [
        if (!isLast) Positioned(top: 18, bottom: 0, child: Container(width: 2, color: AppColors.border)),
        Container(margin: const EdgeInsets.only(top: 12), width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 3))),
      ])),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: child)),
    ]),
  );
}
