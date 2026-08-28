import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

const _otpValiditySeconds = 5 * 60; // 5 menit, samakan dengan OtpService::generate() di backend
const _resendCooldownSeconds = 60; // 1 menit

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String password;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = _otpValiditySeconds;
  int _resendCooldownRemaining = _resendCooldownSeconds;
  bool _autoSubmitTriggered = false;

  bool get _isExpired => _remainingSeconds <= 0;
  bool get _canResend => _resendCooldownRemaining <= 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) _remainingSeconds--;
        if (_resendCooldownRemaining > 0) _resendCooldownRemaining--;
      });
    });
  }

  void _onCodeChanged(String value) {
    // Auto-submit begitu panjang kode mencapai 6 digit, baik dari ketik manual
    // maupun paste — tanpa mengecek benar/salah satu-satu, cukup pastikan tidak
    // submit berulang kali (guard _autoSubmitTriggered) dan tidak submit saat
    // sudah kadaluarsa/sedang loading.
    if (value.length == 6 && !_autoSubmitTriggered && !_isExpired) {
      _autoSubmitTriggered = true;
      _submit();
    } else if (value.length < 6) {
      _autoSubmitTriggered = false;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        OtpSubmitted(email: widget.email, code: _codeController.text.trim()),
      );
    }
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthBloc>().add(
      LoginSubmitted(email: widget.email, password: widget.password),
    );
    setState(() {
      _remainingSeconds = _otpValiditySeconds;
      _resendCooldownRemaining = _resendCooldownSeconds;
      _autoSubmitTriggered = false;
    });
    _codeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode OTP baru telah dikirim.')),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildHeroHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF8A6449)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.xxl),
          bottomRight: Radius.circular(AppSpacing.xxl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -30,
            child: _decorativeCircle(110, Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -10,
            right: -20,
            child: _decorativeCircle(90, Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, top: AppSpacing.sm),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 38),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Verifikasi OTP',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login berhasil.')),
            );
          } else if (state is AuthFailure) {
            _autoSubmitTriggered = false; // izinkan auto-submit lagi kalau user ketik ulang
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.error,
                content: Text(state.message),
              ),
            );
          } else if (state is AuthOtpRequired) {
            // Muncul lagi setelah resend sukses — tidak perlu aksi tambahan,
            // countdown sudah direset manual di _resend().
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroHeader(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Text('Masukkan Kode OTP', style: AppTextStyles.heading1),
                        const SizedBox(height: AppSpacing.xs),
                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: 'Kode OTP telah dikirim ke '),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(
                              _isExpired ? Icons.error_outline : Icons.timer_outlined,
                              size: 16,
                              color: _isExpired ? AppColors.error : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _isExpired
                                  ? 'Kode sudah tidak berlaku, silakan kirim ulang.'
                                  : 'Kode berlaku hingga ${_formatDuration(_remainingSeconds)}',
                              style: AppTextStyles.caption.copyWith(
                                color: _isExpired ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _codeController,
                          onChanged: _onCodeChanged,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !_isExpired && !isLoading,
                          textAlign: TextAlign.center,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: AppTextStyles.heading2.copyWith(letterSpacing: 8),
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Kode OTP',
                            labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
                          ),
                          validator: (value) =>
                          (value == null || value.length != 6) ? 'Kode OTP harus 6 digit' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Verifikasi',
                          isLoading: isLoading,
                          onPressed: _isExpired ? null : _submit,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: _canResend ? _resend : null,
                            child: Text(
                              _canResend
                                  ? 'Kirim Ulang Kode'
                                  : 'Kirim ulang dalam ${_formatDuration(_resendCooldownRemaining)}',
                              style: AppTextStyles.body.copyWith(
                                color: _canResend ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}