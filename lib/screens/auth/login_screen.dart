import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    setState(() => _isLoading = true);
    final error = await AuthService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted) setState(() => _isLoading = false);
    if (error != null) {
      _showError(error);
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'Flora & Fern',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.gold,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Welcome Back,',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue your fashion journey.',
                style: TextStyle(color: AppColors.lightGray, fontSize: 16),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordSheet(context),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Signing In...' : 'Sign In',
                onPressed: _isLoading ? null : _signIn,
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: AppColors.lightGray)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.g_mobiledata, AppColors.darkGray, () => _simulateSocialLogin(context)),
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.apple, AppColors.darkGray, () => _simulateSocialLogin(context)),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: AppColors.lightGray)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Sign Up', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateSocialLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social login coming soon! Please use email/password.')),
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reset Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGray)),
            const SizedBox(height: 8),
            const Text('Enter your email and we will send a reset link.',
              style: TextStyle(color: AppColors.lightGray)),
            const SizedBox(height: 24),
            CustomTextField(
              hintText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              controller: emailCtrl,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Send Reset Link',
              onPressed: () async {
                Navigator.pop(sheetContext);
                final error = await AuthService.resetPassword(emailCtrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error ?? 'Reset link sent! Check your email.'),
                    backgroundColor: error != null ? Colors.redAccent : Colors.green,
                  ));
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.3)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
