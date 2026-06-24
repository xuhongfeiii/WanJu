import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/website.dart';
import 'glass_card.dart';

class WebsiteCard extends StatelessWidget {
  final Website website;
  final VoidCallback onTap;

  const WebsiteCard({
    super.key,
    required this.website,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(12),
      enableBlur: false,
      onTap: onTap,
      child: Row(
        children: [
          _buildCoverImage(),
          const SizedBox(width: 16),
          Expanded(child: _buildContent(c)),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    String char = '';
    if (website.name.isNotEmpty) {
      char = website.name[0].toUpperCase();
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        color: Colors.black,
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          website.name,
          style: AppTheme.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: c.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          website.description,
          style: AppTheme.bodySm.copyWith(
            color: c.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryTag(c),
            _buildHeatCount(c),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTag(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: c.inputFill,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: c.outlineFaded,
          width: 1,
        ),
      ),
      child: Text(
        '#${website.category}',
        style: AppTheme.labelXs.copyWith(
          color: c.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildHeatCount(AppColors c) {
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          size: 14,
          color: c.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _formatHeatCount(website.heatCount),
          style: AppTheme.labelXs.copyWith(
            color: c.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatHeatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
