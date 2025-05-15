import 'package:flutter/material.dart';
import 'package:gadgetzilla/widgets/custom_text_field.dart';
import 'package:gadgetzilla/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;
  bool _allFieldsValid = false;

  void _showSnack(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _validateFields() {
    final nameValid = _nameController.text.isNotEmpty;
    final emailValid = _emailController.text.contains('@');
    final passwordValid = _passwordController.text.length >= 6;

    setState(() {
      _allFieldsValid = nameValid && emailValid && passwordValid;
    });
  }

  Future<void> _handleSignup() async {
    setState(() => _submitted = true);
    _validateFields();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      // ✅ Save user login status
      final prefs = await SharedPreferences.getInstance(); // Fix here
      await prefs.setBool('isLoggedIn', true);

      _showSnack("Signup successful!", Colors.green);

      // ✅ Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      _showSnack("Something went wrong. Try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.only(top: screenHeight * 0.08, bottom: 20),
              children: [
                const Text(
                  'Create an account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's create your account.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  onChanged: (val) => _validateFields(),
                  validator: (val) {
                    if (_submitted && (val == null || val.isEmpty)) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  showCheckCircle: _nameController.text.isNotEmpty,
                  showWarningCircle: _submitted && _nameController.text.isEmpty,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
                  onChanged: (val) => _validateFields(),
                  validator: (val) {
                    if (_submitted && (val == null || val.trim().isEmpty)) {
                      return 'Please enter your email';
                    }
                    if (_submitted && !(val?.contains('@') ?? false)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  showCheckCircle: _emailController.text.contains('@'),
                  showWarningCircle:
                      _submitted &&
                      (!_emailController.text.contains('@') ||
                          _emailController.text.isEmpty),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  isPassword: true,
                  onChanged: (val) => _validateFields(),
                  validator: (val) {
                    if (_submitted && (val == null || val.isEmpty)) {
                      return 'Please enter your password';
                    }
                    if (_submitted && (val?.length ?? 0) < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  showCheckCircle: _passwordController.text.length >= 6,
                  showWarningCircle:
                      _submitted &&
                      (_passwordController.text.length < 6 ||
                          _passwordController.text.isEmpty),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(text: 'By signing up you agree to our '),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ', '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ', and '),
                      TextSpan(
                        text: 'Cookie Use',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _allFieldsValid ? Colors.black : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Create an Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/google_icon.png',
                      width: 24,
                      height: 24,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata),
                    ),
                    label: const Text(
                      'Sign Up with Google',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Sign Up with Facebook',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Log In',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
