import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import 'privacy_links_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _unlock() {
    final settings = StorageService.getSettings();
    final correctPassword = settings.privacyPassword;

    if (_passwordController.text == correctPassword) {
      _errorText = null;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PrivacyLinksScreen(),
        ),
      ).then((_) {
        _passwordController.clear();
        if (mounted) setState(() => _errorText = null);
      });
    } else {
      setState(() => _errorText = '密码错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildShieldIcon(),
                const SizedBox(height: 24),
                Text('隐私空间', style: AppTheme.headlineLg.copyWith(color: c.onSurface)),
                const SizedBox(height: 8),
                Text(
                  '输入密码以进入',
                  style: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMd.copyWith(color: c.onSurface),
                  decoration: InputDecoration(
                    hintText: '请输入密码',
                    hintStyle: AppTheme.bodyMd.copyWith(color: c.onSurfaceVariant),
                    errorText: _errorText,
                    errorStyle: AppTheme.labelSm.copyWith(color: Colors.redAccent),
                    filled: true,
                    fillColor: c.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _unlock,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text('进入', style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.shield_outlined, color: Colors.black, size: 44),
    );
  }
}
