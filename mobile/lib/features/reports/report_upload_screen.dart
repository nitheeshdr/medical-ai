import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../routes/route_names.dart';
import '../../shared/widgets/wise/wise_badge.dart';
import '../../shared/widgets/wise/wise_card.dart';
import 'package:dio/dio.dart';

// ── Reports provider ───────────────────────────────────────────────────────────

final reportsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final api = ref.read(apiClientProvider);
    final res = await api.get('/reports');
    final body = res.data as Map<String, dynamic>;
    final list = body['data'] ?? body['reports'] ?? body;
    if (list is List) return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  } catch (_) {
    return [];
  }
});

// ── Reports list screen ────────────────────────────────────────────────────────

class ReportUploadScreen extends ConsumerWidget {
  const ReportUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Reports')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showUploadSheet(context, ref),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload Report'),
      ),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyReports(onUpload: () => _showUploadSheet(context, ref)),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyReports(onUpload: () => _showUploadSheet(context, ref));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(reportsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ReportCard(report: list[i]),
            ),
          );
        },
      ),
    );
  }

  void _showUploadSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UploadSheet(onUploaded: () {
        Navigator.pop(context);
        ref.invalidate(reportsProvider);
      }),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyReports extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyReports({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.analytics_outlined, size: 48, color: cs.primary),
          ),
          const SizedBox(height: 24),
          Text('No Reports Yet', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Upload blood tests, MRIs, X-rays\nand get instant AI analysis.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload First Report'),
          ),
        ],
      ),
    );
  }
}

// ── Report card ────────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const _ReportCard({required this.report});

  static const _typeIcons = {
    'Blood Report': Icons.bloodtype_rounded,
    'MRI':          Icons.scanner_rounded,
    'ECG':          Icons.monitor_heart_rounded,
    'CT Scan':      Icons.biotech_rounded,
    'X-Ray':        Icons.medical_information_rounded,
    'Diabetes':     Icons.water_drop_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final type    = report['type'] as String? ?? 'Report';
    final name    = report['fileName'] as String? ?? type;
    final ai      = report['aiAnalysis'] as Map<String, dynamic>?;
    final summary = ai?['summary'] as String? ?? 'Pending AI analysis…';
    final needsAttention = ai?['needsAttention'] as bool? ?? false;
    final createdAt = report['createdAt'] as String? ?? '';
    final date = createdAt.isNotEmpty
        ? DateTime.tryParse(createdAt)?.toLocal().toString().substring(0, 10) ?? ''
        : '';
    final icon = _typeIcons[type] ?? Icons.description_outlined;

    return WiseCard(
      onTap: () => context.push(RouteNames.reportAnalysis, extra: report['_id'] as String? ?? ''),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(summary, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Text(date, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  if (needsAttention)
                    WiseBadge(label: '⚠ Attention', type: WiseBadgeType.warning)
                  else if (ai != null)
                    WiseBadge(label: '✓ Analyzed', type: WiseBadgeType.success),
                ]),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

// ── Upload bottom sheet ────────────────────────────────────────────────────────

class _UploadSheet extends ConsumerStatefulWidget {
  final VoidCallback onUploaded;
  const _UploadSheet({required this.onUploaded});
  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  String? _selectedType;
  bool _uploading = false;
  String? _error;

  static const _types = [
    ('Blood Report', Icons.bloodtype_rounded),
    ('MRI',          Icons.scanner_rounded),
    ('ECG',          Icons.monitor_heart_rounded),
    ('CT Scan',      Icons.biotech_rounded),
    ('X-Ray',        Icons.medical_information_rounded),
    ('Diabetes',     Icons.water_drop_outlined),
  ];

  Future<void> _pickAndUpload() async {
    if (_selectedType == null) {
      setState(() => _error = 'Please select a report type');
      return;
    }
    setState(() => _error = null);

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || !mounted) return;

    final file    = result.files.single;
    final path    = file.path;
    if (path == null) return;

    setState(() => _uploading = true);
    try {
      final api    = ref.read(apiClientProvider);
      final bytes  = await File(path).readAsBytes();
      final b64    = base64Encode(bytes);
      final isImage = path.toLowerCase().endsWith('.jpg') || path.toLowerCase().endsWith('.jpeg') || path.toLowerCase().endsWith('.png');
      final mime = isImage ? 'image/jpeg' : 'application/pdf';

      // 1. Create report record
      final createRes = await api.post('/reports', data: {
        'type':     _selectedType,
        'fileName': file.name,
        'fileSize': file.size,
        'fileUrl':  'data:$mime;base64,${b64.substring(0, b64.length.clamp(0, 100))}', // store reference only
      });
      final reportId = (createRes.data as Map<String, dynamic>)['data']?['_id']
          ?? (createRes.data as Map<String, dynamic>)['_id'] as String? ?? '';

      // 2. Trigger AI analysis
      if (reportId.isNotEmpty) {
        await api.post('/reports/analyze', data: {
          'reportId':      reportId,
          'imageBase64':   b64,
          'mimeType':      mime,
          'extractedText': 'Report type: $_selectedType\nFile: ${file.name}\nSize: ${file.size} bytes',
        });
      }

      if (mounted) {
        widget.onUploaded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report uploaded & AI analysis started ✓'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errMsg = 'Upload failed: ${e.toString().substring(0, e.toString().length.clamp(0, 80))}';
        if (e is DioException) {
          if (e.response?.statusCode == 500) {
            errMsg = 'Connection error 500: Server encountered an error during upload or analysis.';
          } else if (e.response?.statusCode != null) {
            errMsg = 'Upload failed with status ${e.response?.statusCode}. Please try again.';
          }
        }
        setState(() => _error = errMsg);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Upload Report', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Select report type', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) {
              final selected = _selectedType == t.$1;
              return FilterChip(
                avatar: Icon(t.$2, size: 16,
                    color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant),
                label: Text(t.$1),
                selected: selected,
                onSelected: (_) => setState(() => _selectedType = t.$1),
              );
            }).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: cs.error, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _uploading ? null : _pickAndUpload,
              icon: _uploading
                  ? SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                  : const Icon(Icons.folder_open_rounded),
              label: Text(_uploading ? 'Uploading & analyzing…' : 'Choose File & Upload'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Supported: PDF, JPG, PNG · Max 4MB',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
