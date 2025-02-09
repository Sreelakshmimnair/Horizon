import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Full Name Field
                _buildTextField(
                  controller: _fullNameController,
                  hintText: 'Enter your full name',
                  labelText: 'Full Name',
                ),
                const SizedBox(height: 10),
                // Email Field with Verify Button
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        hintText: 'username@gmail.com',
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Handle email verification
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        elevation: 0,
                      ),
                      child: const Text('Verify Email'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Phone Number Field
                _buildTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-type your password',
                  labelText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    // Handle sign-up action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Social Media Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle Google Sign-In
                      },
                      child: Image.asset(
                        'assets/images/google.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // Handle Gmail Sign-In
                      },
                      child: Image.asset(
                        'assets/images/gmail.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account yet?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login here',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: const TextStyle(color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blue.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
    );
  }
}
