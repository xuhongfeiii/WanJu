import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/update_service.dart';

class UpdateScreen extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateScreen({super.key, required this.updateInfo});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  double _progress = 0;
  bool _isDownloading = false;
  bool _isDone = false;
  String? _error;
  String? _filePath;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    final filePath = await UpdateService.downloadApk(
      widget.updateInfo.downloadUrl,
      (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      },
    );

    if (!mounted) return;

    if (filePath != null) {
      setState(() {
        _isDownloading = false;
        _isDone = true;
        _filePath = filePath;
        _progress = 1.0;
      });
      await UpdateService.installApk(filePath);
    } else {
      setState(() {
        _isDownloading = false;
        _error = '下载失败，请检查网络后重试';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('软件更新', style: AppTheme.headlineMd.copyWith(color: c.onSurface)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                _isDone ? Icons.check_circle : Icons.system_update,
                size: 72,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _isDone ? '下载完成' : '发现新版本',
                style: AppTheme.headlineLg.copyWith(color: c.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'v${widget.updateInfo.versionName}',
                style: AppTheme.bodyMd.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.updateInfo.changelog.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.inputFill,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '更新内容',
                        style: AppTheme.labelSm.copyWith(color: c.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.updateInfo.changelog,
                        style: AppTheme.bodyMd.copyWith(color: c.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (_isDownloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: c.outline,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: AppTheme.bodySm.copyWith(color: c.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppTheme.bodySm.copyWith(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              if (!_isDownloading && !_isDone)
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _startDownload,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      '立即更新',
                      style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (_isDone && _filePath != null)
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => UpdateService.installApk(_filePath!),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      '重新安装',
                      style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}