import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 1. Multi-Select Chip Group (For Dreams, Diseases, Concomitants)
class MultiSelectChipGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final RxList<String> selectedItems;

  const MultiSelectChipGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Obx(
          () => Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              final isSelected = selectedItems.contains(option);
              return FilterChip(
                label: Text(option, style: const TextStyle(fontSize: 13)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    selectedItems.add(option);
                  } else {
                    selectedItems.remove(option);
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// 2. Segmented Toggle Group (For Thermals, Thirst, Cycle Rhythm)
class SegmentedToggleGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final RxString selectedValue;

  const SegmentedToggleGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SingleChildScrollView(
          scrollDirection:
              Axis.horizontal, // Prevents overflow on narrow mobile screens
          child: Obx(() {
            final currentSelection =
                selectedValue.value.isNotEmpty &&
                    options.contains(selectedValue.value)
                ? selectedValue.value
                : options.first;

            return SegmentedButton<String>(
              showSelectedIcon: false,
              segments: options
                  .map(
                    (opt) => ButtonSegment<String>(
                      value: opt,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          opt,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              selected: {currentSelection},
              onSelectionChanged: (Set<String> newSelection) {
                selectedValue.value = newSelection.first;
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// 3. Modality Matrix Row (+ Ameliorates, 0 Neutral, - Aggravates)
class ModalityMatrixRow extends StatelessWidget {
  final String label;
  final RxInt stateValue; // 1 = Amel, 0 = Neutral, -1 = Agg

  const ModalityMatrixRow({
    super.key,
    required this.label,
    required this.stateValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;

          final control = Obx(
            () => SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<int>(value: 1, label: Text('+ Amel')),
                ButtonSegment<int>(value: 0, label: Text('Neutral')),
                ButtonSegment<int>(value: -1, label: Text('- Agg')),
              ],
              selected: {stateValue.value},
              onSelectionChanged: (Set<int> newSelection) {
                stateValue.value = newSelection.first;
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                control,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(flex: 3, child: control),
            ],
          );
        },
      ),
    );
  }
}

/// 4. Radio Select Group (For Marital Status, Referred By, Occupation, etc.)
class RadioSelectGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final RxString selectedValue;
  final TextEditingController? controller;

  const RadioSelectGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Obx(() {
          final current = selectedValue.value;
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              final isSelected = current == option;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        option,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundColor: Theme.of(context).colorScheme.surface,
                onSelected: (selected) {
                  if (selected) {
                    selectedValue.value = option;
                    if (controller != null) {
                      controller!.text = option;
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

/// 5. Quick Append Text Field with Chip Suggestions
class QuickAppendTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> quickSuggestions;
  final int maxLines;

  const QuickAppendTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.quickSuggestions,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quickSuggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              'Quick Select / Suggestions:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: quickSuggestions.map((sug) {
              return ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 14),
                label: Text(sug, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  if (controller.text.isEmpty) {
                    controller.text = sug;
                  } else if (!controller.text.contains(sug)) {
                    controller.text = '${controller.text}, $sug';
                  }
                },
                backgroundColor: const Color(0xFFF0F4F8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            alignLabelWithHint: maxLines > 1,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

/// 6. "Where Is My Train" Style Vertical Timeline Bar for Follow-Ups & Visits
class WhereIsMyTrainTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> visits;
  final Function(Map<String, dynamic>)? onTapVisit;
  final Function(Map<String, dynamic>)? onDeleteVisit;

  const WhereIsMyTrainTimeline({
    super.key,
    required this.visits,
    this.onTapVisit,
    this.onDeleteVisit,
  });

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              'No follow-up visits recorded yet. Click "+ Log Follow-Up Visit" below.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        final title = visit['title']?.toString() ??
            visit['paperType']?.toString() ??
            'Follow-Up Visit ${visits.length - index}';
        final date = visit['date']?.toString() ?? '';
        final time = visit['time']?.toString() ?? '';
        final status = visit['status']?.toString();
        final remedy = visit['remedy']?.toString();
        final complaint = visit['chiefComplaint']?.toString();
        final isLast = index == visits.length - 1;

        Color statusColor = Theme.of(context).colorScheme.primary;
        if (status != null) {
          if (status.contains('Better') || status.contains('Ameliorated')) {
            statusColor = const Color(0xFF16A34A);
          } else if (status.contains('Worse') || status.contains('Aggravated')) {
            statusColor = const Color(0xFFE11D48);
          } else if (status.contains('Same') || status.contains('Unchanged')) {
            statusColor = const Color(0xFFD97706);
          }
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Train Track Vertical Indicator Line & Station Node
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 3,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Visit Card Details
              Expanded(
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTapVisit?.call(visit),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (MediaQuery.sizeOf(context).width < 600) ...[
                            Row(children: [
                              Expanded(child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              )),
                              if (onDeleteVisit != null) IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red[400],
                                onPressed: () => onDeleteVisit?.call(visit),
                                tooltip: 'Delete visit',
                              ),
                            ]),
                            if (date.isNotEmpty || time.isNotEmpty)
                              Align(alignment: Alignment.centerLeft, child: Chip(
                                visualDensity: VisualDensity.compact,
                                avatar: const Icon(Icons.calendar_today, size: 12),
                                label: Text('$date ${time.isNotEmpty ? "• $time" : ""}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                              )),
                          ] else
                            Row(children: [
                              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                              if (date.isNotEmpty || time.isNotEmpty) Chip(
                                visualDensity: VisualDensity.compact,
                                avatar: const Icon(Icons.calendar_today, size: 12),
                                label: Text('$date ${time.isNotEmpty ? "• $time" : ""}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                              ),
                              if (onDeleteVisit != null) IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red[400],
                                onPressed: () => onDeleteVisit?.call(visit),
                                tooltip: 'Delete visit',
                              ),
                            ]),
                          if (status != null && status.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          if (remedy != null && remedy.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.medication_outlined, size: 16, color: Colors.indigo),
                                const SizedBox(width: 4),
                                Text(
                                  'Remedy: $remedy',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (complaint != null && complaint.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              complaint,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


/// 7. Growth / Degrowth / Upgradation Trend Graph Widget
class FollowUpGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> visits;

  const FollowUpGrowthChart({
    super.key,
    required this.visits,
  });

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = <Map<String, dynamic>>[];
    for (int i = 0; i < visits.length; i++) {
      final v = visits[i];
      final date = v['date']?.toString() ?? 'V${i + 1}';
      final status = v['status']?.toString() ?? '';
      double score = 30.0 * (i + 1);
      if (status.contains('Better') || status.contains('Ameliorated')) {
        score = 40.0 + (i + 1) * 20.0;
        if (score > 100) score = 95.0;
      } else if (status.contains('Worse') || status.contains('Aggravated')) {
        score = -20.0;
      } else if (status.contains('Initial')) {
        score = 0.0;
      }
      points.add({
        'label': date,
        'score': score,
        'title': v['title'] ?? 'Visit',
      });
    }

    final double latestScore = points.isNotEmpty ? (points.last['score'] as double) : 0.0;
    final bool isDowngraded = latestScore < 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: !isDowngraded ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: !isDowngraded ? const Color(0xFF86EFAC) : const Color(0xFFFECDD3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !isDowngraded ? Icons.show_chart_rounded : Icons.trending_down_rounded,
                        color: !isDowngraded ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Patient Health Growth & Recovery Trend',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: !isDowngraded ? const Color(0xFF15803D) : const Color(0xFFBE123C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: !isDowngraded ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    !isDowngraded
                        ? '+${latestScore.toInt()}% Upgradation'
                        : '${latestScore.abs().toInt()}% Downgradation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _GrowthChartPainter(
                  points: points,
                  lineColor: !isDowngraded ? const Color(0xFF16A34A) : const Color(0xFFE11D48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> points;
  final Color lineColor;

  _GrowthChartPainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()..color = lineColor;
    final paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    final zeroY = size.height * 0.75;
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), paintGrid);

    final stepX = points.length > 1 ? (size.width - 40) / (points.length - 1) : size.width / 2;
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = 20.0 + (points.length > 1 ? i * stepX : size.width / 2 - 20);
      final score = (points[i]['score'] as double).clamp(-30.0, 100.0);
      final y = size.height - 25.0 - (score + 30.0) / 130.0 * (size.height - 40.0);
      final pt = Offset(x, y);

      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawCircle(pt, 4, paintDot);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) => true;
}
