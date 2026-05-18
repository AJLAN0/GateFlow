import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/mock_state.dart';
import 'gateflow_colors.dart';
import 'status_pill.dart';
import 'student_status_helpers.dart';

/// Staff monitor row: name, transport, status pill, last update, chevron.
class SchoolStudentRowCard extends StatelessWidget {
  const SchoolStudentRowCard({
    super.key,
    required this.student,
    required this.mock,
    required this.onOpenDetails,
  });

  final Student student;
  final MockState mock;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final bus = studentUsesBusRoster(student);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpenDetails,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GateFlowColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GateFlowColors.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  bus
                      ? Icons.directions_bus_rounded
                      : Icons.directions_car_rounded,
                  color: GateFlowColors.brandPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.grade} · ${bus ? 'Bus' : 'Car'} · ${student.id}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        statusPillForSchoolStudent(student),
                        if (mock.studentHasPendingPickupRequest(student))
                          const StatusPill(
                            label: 'Pending request',
                            tone: StatusTone.pending,
                          ),
                      ],
                    ),
                    if (student.lastMockUpdateLabel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        student.lastMockUpdateLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: GateFlowColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: onOpenDetails,
                    child: Text(
                      'Details',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: GateFlowColors.brandPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: GateFlowColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
