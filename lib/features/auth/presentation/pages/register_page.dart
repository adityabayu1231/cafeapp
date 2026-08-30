import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const _RegisterView();
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordMatchMessage;
  bool _passwordsMatch = false;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordMatch);
    _confirmPasswordController.removeListener(_checkPasswordMatch);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String label, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    );
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      if (confirm.isEmpty) {
        _passwordMatchMessage = null;
        _passwordsMatch = false;
      } else if (password == confirm) {
        _passwordMatchMessage = 'Password cocok';
        _passwordsMatch = true;
      } else {
        _passwordMatchMessage = 'Password belum sama';
        _passwordsMatch = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Daftar Akun', style: TextStyle(color: Colors.white)),
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registrasi berhasil. Silakan login.')),
            );
            Navigator.of(context).pop();
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.error,
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buat Akun Baru', style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Isi data di bawah untuk mulai memesan di Awake Coffee',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(label: 'Nama Lengkap', icon: Icons.person_outline),
                    validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(label: 'Email', icon: Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email wajib diisi';
                      if (!_emailRegex.hasMatch(value)) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password wajib diisi';
                      if (value.length < 8) return 'Password minimal 8 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: AppTextStyles.body,
                    decoration: _inputDecoration(
                      label: 'Konfirmasi Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                      if (value != _passwordController.text) return 'Password tidak cocok';
                      return null;
                    },
                  ),
                  if (_passwordMatchMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          _passwordsMatch ? Icons.check_circle_outline : Icons.error_outline,
                          size: 16,
                          color: _passwordsMatch ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _passwordMatchMessage!,
                          style: AppTextStyles.caption.copyWith(
                            color: _passwordsMatch ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Daftar',
                    isLoading: isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<RegisterBloc>().add(
                          RegisterSubmitted(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            passwordConfirmation: _confirmPasswordController.text,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}