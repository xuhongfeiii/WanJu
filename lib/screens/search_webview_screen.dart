import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';
import '../utils/url_utils.dart';
import '../services/storage_service.dart';

enum SearchEngine {
  bing,
  yandex,
}

class SearchWebViewScreen extends StatefulWidget {
  final String query;

  const SearchWebViewScreen({super.key, required this.query});

  @override
  State<SearchWebViewScreen> createState() => _SearchWebViewScreenState();
}

class _SearchWebViewScreenState extends State<SearchWebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  SearchEngine _currentEngine = SearchEngine.bing;
  late TextEditingController _searchController;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _currentQuery = widget.query;
    _initWebView();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initWebView() {
    final url = _getSearchUrl(widget.query);
    final uri = Uri.tryParse(normalizeUrl(url));
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      debugPrint('Invalid URL: $url');
      return;
    }

    final settings = StorageService.getSettings();
    final userAgent = settings.userAgent == 'desktop'
        ? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: $error');
          },
        ),
      )
      ..loadRequest(uri);
  }

  String _getSearchUrl(String query) {
    switch (_currentEngine) {
      case SearchEngine.bing:
        if (query.trim().isEmpty) {
          return 'https://cn.bing.com';
        }
        return 'https://cn.bing.com/search?q=${Uri.encodeComponent(query)}';
      case SearchEngine.yandex:
        if (query.trim().isEmpty) {
          return 'https://www.yandex.com';
        }
        return 'https://www.yandex.com/search/?text=${Uri.encodeComponent(query)}';
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _currentQuery = query;
    });
    final url = normalizeUrl(_getSearchUrl(query));
    _webViewController.loadRequest(Uri.parse(url));
  }

  void _switchEngine(SearchEngine engine) {
    setState(() {
      _currentEngine = engine;
    });
    final url = normalizeUrl(_getSearchUrl(_currentQuery));
    _webViewController.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(c),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading) _buildProgressBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          bottom: BorderSide(
            color: c.outlineFaded,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildEngineSwitcher(c),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: c.inputFill,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: '搜索...',
                  hintStyle: AppTheme.bodySm.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      size: 18,
                      color: c.onSurfaceVariant,
                    ),
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                ),
                style: AppTheme.bodySm.copyWith(
                  color: c.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineSwitcher(AppColors c) {
    return GestureDetector(
      onTap: _showEnginePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.inputFill,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: c.outlineFaded,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: c.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _currentEngine == SearchEngine.bing ? 'Bing' : 'Yandex',
              style: AppTheme.labelXs.copyWith(
                color: c.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: c.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showEnginePicker() {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (context) {
        final bc = AppColors.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: bc.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '选择搜索引擎',
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: bc.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _currentEngine == SearchEngine.bing
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(Icons.language, size: 20, color: bc.onSurface),
                ),
                title: Text('Bing 国内版', style: AppTheme.bodyMd.copyWith(color: bc.onSurface)),
                trailing: _currentEngine == SearchEngine.bing
                    ? const Icon(Icons.check, color: AppTheme.primary, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _switchEngine(SearchEngine.bing);
                },
              ),
              ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _currentEngine == SearchEngine.yandex
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(Icons.language, size: 20, color: bc.onSurface),
                ),
                title: Text('Yandex', style: AppTheme.bodyMd.copyWith(color: bc.onSurface)),
                trailing: _currentEngine == SearchEngine.yandex
                    ? const Icon(Icons.check, color: AppTheme.primary, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _switchEngine(SearchEngine.yandex);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        value: _isLoading ? null : 1.0,
        backgroundColor: AppTheme.outline.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
        minHeight: 2,
      ),
    );
  }
}