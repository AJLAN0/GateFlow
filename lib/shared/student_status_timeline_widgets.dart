import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gateflow_colors.dart';
import 'student_daily_journey.dart';

/// Full student status page with dual timelines (morning + afternoon).
class StudentStatusDetailScreen extends StatelessWidget {
  const StudentStatusDetailScreen({
    super.key,
    required this.journey,
    this.onBack,
    this.footer,
  });

  final StudentDailyJourney journey;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GateFlowColors.surface,
      appBar: AppBar(
        backgroundColor: GateFlowColors.brandPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'View Student Status',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          StudentInfoCard(journey: journey),
          const SizedBox(height: 14),
          DailySummaryCard(journey: journey),
          const SizedBox(height: 20),
          StatusTimelineSection(
            title: 'Morning Pickup',
            subtitle: 'Home → school',
            phaseLabel: journey.morningPhaseLabel,
            steps: journey.morningSteps,
          ),
          const SizedBox(height: 16),
          StatusTimelineSection(
            title: 'Afternoon Drop-off',
            subtitle: 'School → home',
            phaseLabel: journey.afternoonPhaseLabel,
            steps: journey.afternoonSteps,
          ),
          if (footer != null) ...[
            const SizedBox(height: 20),
            footer!,
          ],
        ],
      ),
    );
  }
}

class StudentInfoCard extends StatelessWidget {
  const StudentInfoCard({super.key, required this.journey});

  final StudentDailyJourney journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: GateFlowColors.brandPrimary.withValues(alpha: 0.12),
            child: Icon(
              journey.transportMode == StudentTransportMode.bus
                  ? Icons.directions_bus_rounded
                  : Icons.directions_car_rounded,
              color: GateFlowColors.brandPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.studentName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: GateFlowColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${journey.grade} · ${journey.transportLabel}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: GateFlowColors.textSecondary,
                  ),
                ),
                Text(
                  'ID · ${journey.studentId}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: GateFlowColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key, required this.journey});

  final StudentDailyJourney journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s summary',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Today status',
            value: journey.attendanceLabel,
            highlight: journey.attendance == AttendanceStatus.absent,
          ),
          _SummaryRow(
            label: 'Current status',
            value: journey.currentStatusLabel,
          ),
          _SummaryRow(
            label: 'Morning pickup',
            value: journey.morningPhaseLabel,
          ),
          _SummaryRow(
            label: 'Afternoon drop-off',
            value: journey.afternoonPhaseLabel,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: GateFlowColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? GateFlowColors.danger
                  : GateFlowColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusTimelineSection extends StatelessWidget {
  const StatusTimelineSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.phaseLabel,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final String phaseLabel;
  final List<TimelineStepData> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: GateFlowColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  phaseLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GateFlowColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            return TimelineStepTile(
              step: steps[i],
              isLast: i == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class TimelineStepTile extends StatelessWidget {
  const TimelineStepTile({
    super.key,
    required this.step,
    required this.isLast,
  });

  final TimelineStepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(step.visualState);
    final isCurrent = step.visualState == TimelineVisualState.current;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 26 : 22,
                  height: isCurrent ? 26 : 22,
                  decoration: BoxDecoration(
                    color: colors.dotFill,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.dotBorder,
                      width: isCurrent ? 2.5 : 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: colors.dotBorder.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _iconFor(step.visualState),
                    size: isCurrent ? 14 : 12,
                    color: colors.iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? GateFlowColors.brandPrimary.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(
                          color: GateFlowColors.brandPrimary.withValues(alpha: 0.25),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: colors.titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        height: 1.35,
                        color: colors.bodyColor,
                      ),
                    ),
                    if (step.timestamp != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        step.timestamp!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(TimelineVisualState state) {
    switch (state) {
      case TimelineVisualState.completed:
        return Icons.check_rounded;
      case TimelineVisualState.current:
        return Icons.radio_button_checked;
      case TimelineVisualState.pending:
        return Icons.circle_outlined;
      case TimelineVisualState.error:
        return Icons.error_outline_rounded;
      case TimelineVisualState.skipped:
        return Icons.remove_rounded;
    }
  }

  static _StepColors _colorsFor(TimelineVisualState state) {
    switch (state) {
      case TimelineVisualState.completed:
        return const _StepColors(
          dotFill: GateFlowColors.success,
          dotBorder: GateFlowColors.success,
          iconColor: Colors.white,
          lineColor: GateFlowColors.success,
          titleColor: GateFlowColors.textPrimary,
          bodyColor: GateFlowColors.textSecondary,
        );
      case TimelineVisualState.current:
        return const _StepColors(
          dotFill: Colors.white,
          dotBorder: GateFlowColors.brandPrimary,
          iconColor: GateFlowColors.brandPrimary,
          lineColor: GateFlowColors.divider,
          titleColor: GateFlowColors.brandPrimary,
          bodyColor: GateFlowColors.textSecondary,
        );
      case TimelineVisualState.pending:
        return _StepColors(
          dotFill: GateFlowColors.divider,
          dotBorder: GateFlowColors.textTertiary.withValues(alpha: 0.5),
          iconColor: GateFlowColors.textTertiary,
          lineColor: GateFlowColors.divider,
          titleColor: GateFlowColors.textTertiary,
          bodyColor: GateFlowColors.textTertiary,
        );
      case TimelineVisualState.error:
        return const _StepColors(
          dotFill: GateFlowColors.danger,
          dotBorder: GateFlowColors.danger,
          iconColor: Colors.white,
          lineColor: GateFlowColors.danger,
          titleColor: GateFlowColors.danger,
          bodyColor: GateFlowColors.textSecondary,
        );
      case TimelineVisualState.skipped:
        return _StepColors(
          dotFill: GateFlowColors.divider,
          dotBorder: GateFlowColors.textTertiary.withValues(alpha: 0.4),
          iconColor: GateFlowColors.textTertiary,
          lineColor: GateFlowColors.divider.withValues(alpha: 0.5),
          titleColor: GateFlowColors.textTertiary,
          bodyColor: GateFlowColors.textTertiary,
        );
    }
  }
}

class _StepColors {
  const _StepColors({
    required this.dotFill,
    required this.dotBorder,
    required this.iconColor,
    required this.lineColor,
    required this.titleColor,
    required this.bodyColor,
  });

  final Color dotFill;
  final Color dotBorder;
  final Color iconColor;
  final Color lineColor;
  final Color titleColor;
  final Color bodyColor;
}
