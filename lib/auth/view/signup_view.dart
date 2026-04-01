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

  // 비밀번호 확인 일치 여부
  bool get _passwordMatch =>
      _passwordController.text == _confirmPasswordController.text;

  // 가입 버튼 활성화 조건
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
        title: const Text(
          '회원가입',
          style: TextStyle(
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

            // 이메일
            _buildLabel('이메일'),
            _buildTextField(
              controller: _emailController,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 비밀번호
            _buildLabel('비밀번호'),
            _buildPasswordField(
              controller: _passwordController,
              hint: '비밀번호 (6자 이상)',
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            _buildLabel('비밀번호 확인'),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hint: '비밀번호를 다시 입력하세요',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            // 비밀번호 불일치 경고
            if (_confirmPasswordController.text.isNotEmpty && !_passwordMatch)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  '비밀번호가 일치하지 않습니다.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            // 닉네임
            _buildLabel('닉네임'),
            _buildTextField(
              controller: _nicknameController,
              hint: '사용할 닉네임을 입력하세요',
            ),
            const SizedBox(height: 24),

            // 선호 언어 선택
            _buildLabel('선호 언어'),
            const SizedBox(height: 8),
            Consumer<AuthViewModel>(
              builder: (context, vm, _) => Row(
                children: _languages.map((lang) {
                  final isSelected = vm.selectedLanguage == lang['code'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => vm.selectLanguage(lang['code']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white,
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
                            color: isSelected
                                ? Colors.white
                                : AppColors.subText,
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

            // 약관 동의
            _buildLabel('약관 동의'),
            const SizedBox(height: 8),

            // 필수 약관
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildCheckboxRow(
                    label: '(필수) 이용약관에 동의합니다.',
                    value: _agreeRequired,
                    onChanged: (v) =>
                        setState(() => _agreeRequired = v ?? false),
                    showDetail: true,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _buildCheckboxRow(
                    label: '(선택) 마케팅 정보 수신에 동의합니다.',
                    value: _agreeOptional,
                    onChanged: (v) =>
                        setState(() => _agreeOptional = v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 가입 완료 버튼
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (!_canSubmit || vm.isLoading)
                    ? null
                    : () {
                  // TODO: Firebase 연동 시 vm.signUp() 호출
                  context.go('/home');
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
                    : const Text(
                  '가입 완료',
                  style: TextStyle(
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

  // --- 헬퍼 위젯들 ---

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
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
            ),
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
            child: const Text(
              '보기',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}