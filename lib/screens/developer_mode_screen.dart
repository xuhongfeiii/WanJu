import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/settings.dart';
import '../models/website.dart';
import '../services/storage_service.dart';

class DeveloperModeScreen extends StatefulWidget {
  const DeveloperModeScreen({super.key});

  @override
  State<DeveloperModeScreen> createState() => _DeveloperModeScreenState();
}

class _DeveloperModeScreenState extends State<DeveloperModeScreen> {
  List<Website> _customWebsites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomWebsites();
  }

  Future<void> _loadCustomWebsites() async {
    final websites = await StorageService.getCustomWebsites();
    setState(() {
      _customWebsites = websites;
      _isLoading = false;
    });
  }

  InputDecoration _dialogInputDecoration(AppColors c, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  void _showAddWebsiteDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = '工具';

    final categories = ['影视', '壁纸', '工具', 'AI', '学习', '生活'];

    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dc.surface,
              title: Text('添加自定义网站', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: _dialogInputDecoration(dc, '网站名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: _dialogInputDecoration(dc, 'URL (https://...)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: _dialogInputDecoration(dc, '一句话描述'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: _dialogInputDecoration(dc, '分类'),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || urlController.text.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请填写网站名称和URL')),
                        );
                      }
                      return;
                    }
                    final newWebsite = Website(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text,
                      url: urlController.text,
                      description: descController.text,
                      category: selectedCategory,
                      coverUrl: '',
                      heatCount: 0,
                    );
                    await StorageService.addCustomWebsite(newWebsite);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    _loadCustomWebsites();
                  },
                  child: Text('添加', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditWebsiteDialog(Website website) {
    final nameController = TextEditingController(text: website.name);
    final urlController = TextEditingController(text: website.url);
    final descController = TextEditingController(text: website.description);
    String selectedCategory = website.category;

    final categories = ['影视', '壁纸', '工具', 'AI', '学习', '生活'];

    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dc.surface,
              title: Text('编辑网站', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: _dialogInputDecoration(dc, '网站名称'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: _dialogInputDecoration(dc, 'URL (https://...)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: _dialogInputDecoration(dc, '一句话描述'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: _dialogInputDecoration(dc, '分类'),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || urlController.text.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请填写网站名称和URL')),
                        );
                      }
                      return;
                    }
                    final updatedWebsite = Website(
                      id: website.id,
                      name: nameController.text,
                      url: urlController.text,
                      description: descController.text,
                      category: selectedCategory,
                      coverUrl: website.coverUrl,
                      heatCount: website.heatCount,
                    );
                    await StorageService.updateCustomWebsite(updatedWebsite);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    _loadCustomWebsites();
                  },
                  child: Text('保存', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteWebsite(Website website) {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('删除网站', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Text('确定要删除 "${website.name}" 吗？', style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                await StorageService.removeCustomWebsite(website.id);
                if (mounted) {
                  Navigator.pop(context);
                }
                _loadCustomWebsites();
              },
              child: Text('删除', style: AppTheme.bodyMd.copyWith(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateUrlDialog() {
    final settings = StorageService.getSettings();
    final controller = TextEditingController(text: settings.updateUrl);

    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('设置更新地址', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: TextField(
            controller: controller,
            decoration: _dialogInputDecoration(dc, 'https://example.com/update.json'),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                settings.updateUrl = controller.text;
                await StorageService.saveSettings(settings);
                if (mounted) Navigator.pop(context);
              },
              child: Text('保存', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPasswordDialog() {
    final settings = StorageService.getSettings();
    final controller = TextEditingController(text: settings.privacyPassword);

    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text('设置隐私密码', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: _dialogInputDecoration(dc, '新密码'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;
                settings.privacyPassword = controller.text;
                await StorageService.saveSettings(settings);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('隐私密码已更新'), backgroundColor: AppTheme.primary),
                  );
                }
              },
              child: Text('保存', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyLinkDialog({int? editIndex}) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    if (editIndex != null) {
      final links = StorageService.getCustomPrivacyLinks();
      if (editIndex < links.length) {
        nameController.text = links[editIndex].name;
        urlController.text = links[editIndex].url;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return AlertDialog(
          backgroundColor: dc.surface,
          title: Text(editIndex != null ? '编辑隐私链接' : '添加隐私链接',
              style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: _dialogInputDecoration(dc, '名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: _dialogInputDecoration(dc, 'URL (https://...)'),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || urlController.text.isEmpty) return;
                if (editIndex != null) {
                  // For simplicity, remove old and add new
                  await StorageService.removeCustomPrivacyLink(editIndex);
                }
                await StorageService.addCustomPrivacyLink(nameController.text, urlController.text);
                if (mounted) Navigator.pop(context);
              },
              child: Text('保存', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyLinkManager() {
    showDialog(
      context: context,
      builder: (context) {
        final dc = AppColors.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final links = StorageService.getCustomPrivacyLinks();
            return AlertDialog(
              backgroundColor: dc.surface,
              title: Text('管理隐私链接', style: AppTheme.headlineMd.copyWith(color: dc.onSurface)),
              content: SizedBox(
                width: double.maxFinite,
                child: links.isEmpty
                    ? Text('暂无自定义隐私链接', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: links.length,
                        itemBuilder: (context, index) {
                          final link = links[index];
                          return ListTile(
                            dense: true,
                            title: Text(link.name, style: AppTheme.bodyMd.copyWith(color: dc.onSurface)),
                            subtitle: Text(link.url, style: AppTheme.labelSm.copyWith(color: dc.onSurfaceVariant)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                await StorageService.removeCustomPrivacyLink(index);
                                setDialogState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('关闭', style: AppTheme.bodyMd.copyWith(color: dc.onSurfaceVariant)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPrivacyLinkDialog();
                  },
                  child: Text('添加', style: AppTheme.bodyMd.copyWith(color: AppTheme.primary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacyConfigCard(AppColors c, Settings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: const [AppTheme.whisperShadow],
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _showPrivacyPasswordDialog,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Icon(Icons.lock_outline, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('设置隐私密码', style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600, color: c.onSurface)),
                        Text('当前密码: ●●●●', style: AppTheme.labelSm.copyWith(color: c.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: c.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          InkWell(
            onTap: _showPrivacyLinkManager,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Icon(Icons.link, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('管理隐私链接', style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600, color: c.onSurface)),
                  ),
                  Icon(Icons.chevron_right, color: c.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final settings = StorageService.getSettings();
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '开发者模式',
          style: AppTheme.headlineMd.copyWith(color: c.onSurface),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: c.onSurface),
            onPressed: _showAddWebsiteDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.containerMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUpdateConfigCard(c, settings),
                  const SizedBox(height: 16),
                  _buildPrivacyConfigCard(c, settings),
                  const SizedBox(height: 24),
                  Text(
                    '自定义网站 (${_customWebsites.length})',
                    style: AppTheme.labelSm.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  if (_customWebsites.isEmpty)
                    _buildEmptyState(c)
                  else
                    ..._customWebsites.map((website) => _buildWebsiteItem(website, c)),
                ],
              ),
            ),
    );
  }

  Widget _buildUpdateConfigCard(AppColors c, Settings settings) {
    return InkWell(
      onTap: _showUpdateUrlDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: const [AppTheme.whisperShadow],
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: const Icon(Icons.system_update, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTA 更新配置',
                    style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600, color: c.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.updateUrl.isEmpty ? '点击设置更新地址' : settings.updateUrl,
                    style: AppTheme.labelSm.copyWith(
                      color: settings.updateUrl.isEmpty ? c.onSurfaceVariantFaded : c.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: c.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.code, size: 48, color: c.onSurfaceVariantFaded),
            const SizedBox(height: 16),
            Text('暂无自定义网站', style: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('点击右上角 + 添加', style: AppTheme.bodySm.copyWith(color: c.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsiteItem(Website website, AppColors c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: const [AppTheme.whisperShadow],
        border: Border.all(color: c.outlineFaded, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.inputFill,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(Icons.language, color: c.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  website.name,
                  style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600, color: c.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  website.url,
                  style: AppTheme.labelXs.copyWith(color: c.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('#${website.category}', style: AppTheme.labelXs.copyWith(color: AppTheme.primary)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: c.onSurfaceVariant, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditWebsiteDialog(website);
              } else if (value == 'delete') {
                _deleteWebsite(website);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: c.onSurface),
                      const SizedBox(width: 8),
                      Text('编辑', style: AppTheme.bodyMd.copyWith(color: c.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('删除', style: AppTheme.bodyMd.copyWith(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}