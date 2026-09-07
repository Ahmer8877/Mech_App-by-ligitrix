import 'package:flutter/material.dart';
import '../../cores/theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/step_progress.dart';

enum DocStatus { notUploaded, pending, approved }

class _DocItem {
  final String label;
  final DocStatus status;
  const _DocItem(this.label, this.status);
}

class VerificationDocumentsScreen extends StatelessWidget {
  const VerificationDocumentsScreen({super.key});

  static const _docs = [
    _DocItem('CNIC (Front & Back)', DocStatus.approved),
    _DocItem('Profile Photo', DocStatus.approved),
    _DocItem('Experience Certificate', DocStatus.pending),
    _DocItem('Tools / Workshop Photo', DocStatus.notUploaded),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scheme = Theme.of(context).colorScheme;
    final allApproved = _docs.every((d) => d.status == DocStatus.approved);

    Color statusColor(DocStatus s) {
      switch (s) {
        case DocStatus.approved:
          return c.success;
        case DocStatus.pending:
          return c.accent;
        case DocStatus.notUploaded:
          return c.danger;
      }
    }

    String statusLabel(DocStatus s) {
      switch (s) {
        case DocStatus.approved:
          return 'Approved';
        case DocStatus.pending:
          return 'Under Review';
        case DocStatus.notUploaded:
          return 'Not Uploaded';
      }
    }

    return Scaffold(
      appBar: const FlowAppBar(title: 'Verification Documents'),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (allApproved ? c.success : c.accent).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    allApproved
                        ? Icons.verified_outlined
                        : Icons.hourglass_empty,
                    size: 18,
                    color: allApproved ? c.success : c.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      allApproved
                          ? 'Aap ka account fully verified hai'
                          : 'Verification mukammal karein taake requests milna shuru hon',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final d = _docs[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: c.borderStrong.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c.surface2,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            d.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(
                              d.status,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel(d.status),
                            style: TextStyle(
                              fontSize: 8.5,
                              color: statusColor(d.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            AccentButton(
              label: 'Upload New Document',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Document picker abhi backend se connect hona baaki hai',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
