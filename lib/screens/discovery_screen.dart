import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/website.dart';
import '../services/storage_service.dart';
import '../widgets/website_card.dart';
import '../widgets/glass_card.dart';
import 'webview_screen.dart';
import 'search_webview_screen.dart';
import 'developer_mode_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<Website> _websites = [];
  List<Website> _filteredWebsites = [];
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '影视', '壁纸', '工具', 'AI', '生活'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWebsites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWebsites() async {
    final websites = await StorageService.loadWebsites();
    setState(() {
      _websites = websites;
      _filteredWebsites = websites;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == '全部') {
        _filteredWebsites = _websites;
      } else {
        _filteredWebsites = _websites.where((w) => w.category == category).toList();
      }
    });
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchWebViewScreen(query: query),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSearchBar(c),
                const SizedBox(height: 20),
                if (StorageService.isDeveloperMode) ...[
                  _buildDevModeButton(c),
                  const SizedBox(height: 12),
                ],
                _buildCategoryFilter(c),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Column(
                children: [
                  _buildWebsiteList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColors c) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppTheme.radiusFull,
      blurSigma: 12,
      opacity: 0.3,
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: c.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _submitSearch,
                  decoration: InputDecoration(
                    hintText: '搜索网站或工具',
                    hintStyle: AppTheme.bodySm.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTheme.bodySm.copyWith(
                    color: c.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevModeButton(AppColors c) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeveloperModeScreen(),
          ),
        );
        _loadWebsites();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              '管理',
              style: AppTheme.labelXs.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(AppColors c) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => _filterByCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.chipPaddingX,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected ? c.onSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: isSelected ? c.onSurface : c.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? c.background : c.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category,
                    style: AppTheme.labelSm.copyWith(
                      color: isSelected ? c.background : c.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '全部':
        return Icons.apps;
      case '影视':
        return Icons.movie;
      case '壁纸':
        return Icons.wallpaper;
      case '工具':
        return Icons.build;
      case 'AI':
        return Icons.smart_toy;
      case '生活':
        return Icons.local_cafe;
      default:
        return Icons.category;
    }
  }

  Widget _buildWebsiteList() {
    return Column(
      children: _filteredWebsites.map((website) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.cardGap),
          child: WebsiteCard(
            website: website,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(website: website),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}