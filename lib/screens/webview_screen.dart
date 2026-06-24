import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';
import '../utils/url_utils.dart';
import '../models/website.dart';
import '../models/favorite.dart';
import '../services/storage_service.dart';

class WebViewScreen extends StatefulWidget {
  final Website website;

  const WebViewScreen({super.key, required this.website});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _didInit = false;
  bool _mainFrameFailed = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _initWebView();
    }
  }

  void _checkFavorite() {
    final favorites = StorageService.getFavorites();
    setState(() {
      _isFavorite = favorites.any((f) => f.websiteId == widget.website.id);
    });
  }

  void _initWebView() {
    final url = normalizeUrl(widget.website.url);
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      debugPrint('Invalid URL: ${widget.website.url}');
      return;
    }

    final settings = StorageService.getSettings();
    final userAgent = settings.userAgent == 'desktop'
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.backgroundDark
        : AppTheme.background;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgColor)
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.scheme != 'http' && uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _mainFrameFailed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
              StorageService.addHistory(widget.website.name, widget.website.url);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _mainFrameFailed = true;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(uri);
  }

  void _retry() {
    _mainFrameFailed = false;
    _isLoading = true;
    _webViewController.reload();
  }

  void _openInBrowser() async {
    final url = normalizeUrl(widget.website.url);
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  void _shareLink() {
    Clipboard.setData(ClipboardData(text: widget.website.url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接已复制'), backgroundColor: AppTheme.primary),
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      StorageService.addFavorite(Favorite(
        websiteId: widget.website.id,
        groupName: '默认',
        addedAt: DateTime.now(),
      ));
    } else {
      StorageService.removeFavorite(widget.website.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(c),
            if (_isLoading) _buildProgressBar(),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_mainFrameFailed) _buildErrorOverlay(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          bottom: BorderSide(color: c.outlineFaded, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: c.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.website.name,
              style: AppTheme.headlineMd.copyWith(color: c.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppTheme.primary : c.onSurface,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: c.onSurface),
            onPressed: () => _showMenu(c),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return const LinearProgressIndicator(
      value: null,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
      minHeight: 2,
    );
  }

  Widget _buildErrorOverlay(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: c.onSurfaceVariantFaded),
            const SizedBox(height: 16),
            Text('页面加载失败', style: AppTheme.headlineMd.copyWith(color: c.onSurface)),
            const SizedBox(height: 8),
            Text(
              '请检查网络连接后重试，或使用浏览器打开',
              style: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重试'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('浏览器打开'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(AppColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) {
        final bc = AppColors.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: bc.onSurface),
                title: const Text('刷新'),
                onTap: () {
                  _retry();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.open_in_browser, color: bc.onSurface),
                title: const Text('在浏览器中打开'),
                onTap: () {
                  Navigator.pop(context);
                  _openInBrowser();
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: bc.onSurface),
                title: const Text('分享链接'),
                onTap: () {
                  Navigator.pop(context);
                  _shareLink();
                },
              ),
              ListTile(
                leading: Icon(Icons.copy, color: bc.onSurface),
                title: const Text('复制URL'),
                onTap: () {
                  Navigator.pop(context);
                  _shareLink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
