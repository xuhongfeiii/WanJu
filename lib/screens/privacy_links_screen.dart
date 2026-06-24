import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/website.dart';
import '../services/storage_service.dart';
import 'webview_screen.dart';

class PrivacyLinksScreen extends StatefulWidget {
  const PrivacyLinksScreen({super.key});

  @override
  State<PrivacyLinksScreen> createState() => _PrivacyLinksScreenState();
}

class _PrivacyLinksScreenState extends State<PrivacyLinksScreen> {
  List<PrivacyLink> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final defaults = await StorageService.loadDefaultPrivacyLinks();
    final custom = StorageService.getCustomPrivacyLinks();
    setState(() {
      _links = [...defaults, ...custom];
      _isLoading = false;
    });
  }

  void _openLink(PrivacyLink link) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          website: Website(
            id: 'privacy_${link.name}',
            name: link.name,
            url: link.url,
            description: '',
            category: '',
            coverUrl: '',
            heatCount: 0,
          ),
        ),
      ),
    );
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
        title: Text('隐私空间', style: AppTheme.headlineMd.copyWith(color: c.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.lock, color: c.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _links.isEmpty
              ? Center(
                  child: Text(
                    '暂无链接',
                    style: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin, vertical: 16),
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final link = _links[index];
                    return _buildLinkItem(link, c);
                  },
                ),
    );
  }

  Widget _buildLinkItem(PrivacyLink link, AppColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openLink(link),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: const [AppTheme.whisperShadow],
            border: Border.all(color: c.outlineFaded, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(Icons.link, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  link.name,
                  style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w500, color: c.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: c.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
