import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);

    final error = await AuthService.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (mounted) setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      // Successfully signed up — user is now saved in Firebase Auth + Firestore
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account,',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to get started!',
                style: TextStyle(color: AppColors.lightGray, fontSize: 16),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
              CustomButton(
                text: _isLoading ? 'Creating Account...' : 'Sign Up',
                onPressed: _isLoading ? null : _signUp,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(color: AppColors.lightGray)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Sign In', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
