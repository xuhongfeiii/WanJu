import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/theme.dart';
import '../models/settings.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import 'developer_mode_screen.dart';
import '../services/update_service.dart';
import 'update_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings _settings;
  String _version = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _settings = StorageService.getSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${info.version}+${info.buildNumber}';
      });
    }
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings(_settings);
    if (mounted) {
      ThemeScope.of(context)?.updateTheme(_settings.darkTheme);
    }
  }

  void _showDeveloperKeyDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('开发者模式', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '请输入开发者密钥',
                style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '密钥',
                  hintStyle: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: dc.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: dc.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                final success = StorageService.unlockDeveloperMode(keyController.text);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('开发者模式已启用'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeveloperModeScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('密钥错误'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('确认', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showUserAgentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('浏览器标识', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserAgentOption('mobile', '手机版', '使用手机浏览器标识访问网站', dc),
              const SizedBox(height: 8),
              _buildUserAgentOption('desktop', '电脑版', '使用电脑浏览器标识访问网站', dc),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAgentOption(String value, String title, String subtitle, AppColors c) {
    final isSelected = _settings.userAgent == value;
    return GestureDetector(
      onTap: () {
        setState(() => _settings.userAgent = value);
        _saveSettings();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : c.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primary : c.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.labelXs.copyWith(color: c.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSection('浏览', [
                    _buildSwitchItem(
                      '广告过滤',
                      _settings.adBlockEnabled,
                      (value) {
                        setState(() => _settings.adBlockEnabled = value);
                        _saveSettings();
                      },
                      c,
                    ),
                    _buildTapItem(
                      '浏览器标识',
                      _settings.userAgent == 'mobile' ? '手机版' : '电脑版',
                      _showUserAgentDialog,
                      c,
                    ),
                  ], c),
                  const SizedBox(height: 24),
                  _buildSection('外观', [
                    _buildSwitchItem(
                      '深色主题',
                      _settings.darkTheme,
                      (value) {
                        setState(() => _settings.darkTheme = value);
                        _saveSettings();
                      },
                      c,
                    ),
                  ], c),
                  const SizedBox(height: 24),
                  _buildSection('数据', [
                    _buildTapItem2('清除所有缓存', _showClearCacheDialog, c),
                    _buildTapItem2('清除浏览历史', _showClearHistoryDialog, c),
                  ], c),
                  const SizedBox(height: 24),
                  _buildSection('关于', [
                    _buildVersionItem(c),
                  ], c),
                  if (StorageService.isDeveloperMode) ...[
                    const SizedBox(height: 24),
                    _buildSection('开发者', [
                      _buildTapItem2('管理自定义网站', () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeveloperModeScreen(),
                          ),
                        );
                        if (mounted) setState(() => _settings = StorageService.getSettings());
                      }, c),
                      _buildTapItem2('退出开发者模式', () {
                        setState(() {
                          StorageService.exitDeveloperMode();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已退出开发者模式'),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      }, c),
                    ], c),
                  ],
                  const SizedBox(height: 24),
                  _buildSection('更新', [
                    _buildTapItem2('检查更新', _checkForUpdate, c),
                  ], c),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.labelSm.copyWith(
            color: c.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          enableBlur: false,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged, AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: c.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.bodyMd.copyWith(
              color: c.onSurface,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.black,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: c.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildTapItem(String title, String trailing, VoidCallback onTap, AppColors c) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: c.outline,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.bodyMd.copyWith(
                color: c.onSurface,
              ),
            ),
            Row(
              children: [
                Text(
                  trailing,
                  style: AppTheme.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: c.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapItem2(String title, VoidCallback onTap, AppColors c) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: c.outline,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.bodyMd.copyWith(
                color: c.onSurface,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: c.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(AppColors c) {
    return GestureDetector(
      onLongPress: _showDeveloperKeyDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '版本',
              style: AppTheme.bodyMd.copyWith(
                color: c.onSurface,
              ),
            ),
            Text(
              StorageService.isDeveloperMode ? '$_version-dev' : _version,
              style: AppTheme.bodyMd.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('清除缓存', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Text('确定要清除所有缓存吗？', style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                await WebViewCookieManager().clearCookies();
                final controller = WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted);
                await controller.clearCache();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('缓存已清除'), backgroundColor: AppTheme.primary),
                  );
                }
              },
              child: Text('确定', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('清除浏览历史', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Text('确定要清除浏览历史吗？', style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                await StorageService.clearHistory();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('浏览历史已清除'), backgroundColor: AppTheme.primary),
                  );
                }
              },
              child: Text('确定', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _checkForUpdate() async {
    final c = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在检查更新...'),
        backgroundColor: AppTheme.primary,
        duration: Duration(seconds: 1),
      ),
    );

    final updateInfo = await UpdateService.checkUpdate();

    if (!mounted) return;

    if (updateInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateScreen(updateInfo: updateInfo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已是最新版本'),
          backgroundColor: c.onSurfaceVariant,
        ),
      );
    }
  }
}