import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../core/constants.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeRequired = false;
  bool _agreeOptional = false;

  final List<Map<String, String>> _languages = [
    {'code': 'ko', 'label': '한국어'},
    {'code': 'en', 'label': 'English'},
    {'code': 'zh', 'label': '中文'},
    {'code': 'ja', 'label': '日本語'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool get _passwordMatch =>
      _passwordController.text == _confirmPasswordController.text;

  bool get _canSubmit =>
      _agreeRequired &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _nicknameController.text.isNotEmpty &&
          _passwordMatch;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          'auth.signup'.tr(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            _buildLabel('auth.email'.tr()),
            _buildTextField(
              controller: _emailController,
              hint: 'auth.email_hint'.tr(),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildLabel('auth.password'.tr()),
            _buildPasswordField(
              controller: _passwordController,
              hint: 'auth.password_hint_short'.tr(),
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 16),

            _buildLabel('auth.confirm_password'.tr()),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: 'auth.confirm_password_hint'.tr(),
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            if (_confirmPasswordController.text.isNotEmpty && !_passwordMatch)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'auth.password_mismatch'.tr(),
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            _buildLabel('auth.nickname'.tr()),
            _buildTextField(
              controller: _nicknameController,
              hint: 'auth.nickname_hint'.tr(),
            ),
            const SizedBox(height: 24),

            _buildLabel('auth.preferred_language'.tr()),
            const SizedBox(height: 8),
            Consumer<AuthViewModel>(
              builder: (context, vm, _) => Row(
                children: _languages.map((lang) {
                  final isSelected = vm.selectedLanguage == lang['code'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        vm.selectLanguage(lang['code']!);
                        context.setLocale(Locale(lang['code']!));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          lang['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppColors.subText,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('auth.terms'.tr()),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildCheckboxRow(
                    label: 'auth.terms_required'.tr(),
                    value: _agreeRequired,
                    onChanged: (v) =>
                        setState(() => _agreeRequired = v ?? false),
                    showDetail: true,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildCheckboxRow(
                    label: 'auth.terms_optional'.tr(),
                    value: _agreeOptional,
                    onChanged: (v) =>
                        setState(() => _agreeOptional = v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (!_canSubmit || vm.isLoading)
                    ? null
                    : () async {
                  final success = await vm.signUp(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    nickname: _nicknameController.text.trim(),
                    language: vm.selectedLanguage,
                  );
                  if (success && mounted) context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: vm.isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'auth.signup_complete'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.subText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.subText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.subText,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool showDetail = false,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.text),
          ),
        ),
        if (showDetail)
          TextButton(
            onPressed: () {
              // TODO: 약관 상세 보기 바텀시트
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'auth.terms_view'.tr(),
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}