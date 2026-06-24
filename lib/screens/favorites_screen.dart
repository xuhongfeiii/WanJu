import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/favorite.dart';
import '../models/website.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import 'webview_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _showFavorites = true;
  List<Favorite> _favorites = [];
  List<Website> _websites = [];
  List<Map<String, String>> _history = [];
  final Map<String, List<Favorite>> _groupedFavorites = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final favorites = StorageService.getFavorites();
    final websites = await StorageService.loadWebsites();
    final history = StorageService.getHistory();
    final websiteIds = websites.map((w) => w.id).toSet();
    final validFavorites = favorites.where((f) => websiteIds.contains(f.websiteId)).toList();
    if (validFavorites.length < favorites.length) {
      for (final f in favorites) {
        if (!websiteIds.contains(f.websiteId)) {
          await StorageService.removeFavorite(f.websiteId);
        }
      }
    }
    setState(() {
      _favorites = validFavorites;
      _websites = websites;
      _history = history;
      _groupFavorites();
    });
  }

  void _groupFavorites() {
    _groupedFavorites.clear();
    for (var favorite in _favorites) {
      if (!_groupedFavorites.containsKey(favorite.groupName)) {
        _groupedFavorites[favorite.groupName] = [];
      }
      _groupedFavorites[favorite.groupName]!.add(favorite);
    }
  }

  void _deleteFavorite(String websiteId) {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('删除收藏', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Text('确定要取消收藏吗？', style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                await StorageService.removeFavorite(websiteId);
                if (mounted) Navigator.pop(context);
                _loadData();
              },
              child: Text('删除', style: AppTheme.bodyMd.copyWith(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildSegmentControl(c),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Column(
                children: [
                  _showFavorites ? _buildFavoritesList(c) : _buildRecentList(c),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentControl(AppColors c) {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showFavorites = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showFavorites ? c.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Center(
                  child: Text(
                    '收藏',
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: _showFavorites ? FontWeight.w600 : FontWeight.normal,
                      color: _showFavorites ? c.background : c.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFavorites = false;
                  _history = StorageService.getHistory();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showFavorites ? c.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Center(
                  child: Text(
                    '最近',
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: !_showFavorites ? FontWeight.w600 : FontWeight.normal,
                      color: !_showFavorites ? c.background : c.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(AppColors c) {
    if (_groupedFavorites.isEmpty) {
      return _buildEmptyState('暂无收藏', c);
    }

    return Column(
      children: _groupedFavorites.entries.map((entry) {
        return _buildGroup(entry.key, entry.value, c);
      }).toList(),
    );
  }

  Widget _buildGroup(String groupName, List<Favorite> favorites, AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              groupName,
              style: AppTheme.labelSm.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: AppTheme.cardGap,
          runSpacing: AppTheme.cardGap,
          children: favorites.map((favorite) {
            final website = _websites.cast<Website?>().firstWhere(
              (w) => w?.id == favorite.websiteId,
              orElse: () => null,
            );
            if (website == null) return const SizedBox.shrink();
            return _buildFavoriteItem(website, c);
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFavoriteItem(Website website, AppColors c) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(website: website),
          ),
        ).then((_) => _loadData());
      },
      onLongPress: () => _deleteFavorite(website.id),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            _buildFirstCharAvatar(website.name, 60, c),
            const SizedBox(height: 8),
            Text(
              website.name,
              style: AppTheme.labelXs.copyWith(
                color: c.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList(AppColors c) {
    if (_history.isEmpty) {
      return _buildEmptyState('暂无浏览记录', c);
    }

    return Column(
      children: [
        ..._history.take(20).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.cardGap),
            child: _buildRecentItem(item, c),
          );
        }),
      ],
    );
  }

  Widget _buildRecentItem(Map<String, String> item, AppColors c) {
    final title = item['title'] ?? '';
    final url = item['url'] ?? '';
    final time = item['time'] ?? '';

    return GestureDetector(
      onTap: () {
        final website = Website(
          id: 'history_${url.hashCode}',
          name: title,
          url: url,
          description: '',
          category: '综合',
          coverUrl: '',
          heatCount: 0,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(website: website),
          ),
        ).then((_) => _loadData());
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        enableBlur: false,
        child: Row(
          children: [
            _buildFirstCharAvatar(title, 60, c),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    url,
                    style: AppTheme.bodySm.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (time.isNotEmpty)
              Text(
                _formatTime(time),
                style: AppTheme.bodySm.copyWith(
                  color: c.onSurfaceVariantFaded,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return '刚刚';
      if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
      if (diff.inHours < 24) return '${diff.inHours}小时前';
      if (diff.inDays < 7) return '${diff.inDays}天前';
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }

  Widget _buildFirstCharAvatar(String name, double size, AppColors c) {
    String char = '';
    if (name.isNotEmpty) {
      char = name[0].toUpperCase();
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border,
            size: 48,
            color: c.onSurfaceVariantFaded,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyMd.copyWith(
              color: c.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}