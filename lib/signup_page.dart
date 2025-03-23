import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final TextEditingController _otpController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  String? _verificationId;
  int? _resendToken;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  // Function to register user with email and password
  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Store additional user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'phoneVerified': _isPhoneVerified,
        'createdAt': Timestamp.now(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      
      // Navigate to home screen or login screen
      
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Format phone number to ensure it has country code
  String _formatPhoneNumber(String phone) {
    // If phone doesn't start with +, add country code +1 (for US)
    // You should modify this based on your target users' location
    if (!phone.startsWith('+')) {
      if (phone.startsWith('1')) {
        return '+$phone';
      } else {
        return '+1$phone'; // Default US country code
      }
    }
    return phone;
  }
  
  // Phone verification functions
  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          try {
            if (_auth.currentUser != null) {
              await _auth.currentUser?.linkWithCredential(credential);
            }
            setState(() {
              _isPhoneVerified = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone verified automatically!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Auto-verification error: ${e.toString()}')),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = 'Verification failed';
          
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format. Please include country code (e.g., +1 for US).';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again tomorrow.';
          } else {
            errorMessage = 'Error: ${e.message}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent!')),
          );
          _showOTPInputDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone verification error: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _showOTPInputDialog() async {
    _otpController.clear();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isVerifying = false;
          
          return AlertDialog(
            title: const Text('Enter Verification Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the 6-digit code sent to your phone',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '123456',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive code? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _verifyPhoneNumber();
                      },
                      child: const Text('Resend'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isVerifying ? null : () async {
                  if (_otpController.text.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid 6-digit code')),
                    );
                    return;
                  }
                  
                  try {
                    setDialogState(() {
                      isVerifying = true;
                    });
                    
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId!,
                      smsCode: _otpController.text.trim(),
                    );
                    
                    // Link phone credential with user account if user exists
                    if (_auth.currentUser != null) {
                      try {
                        await _auth.currentUser?.linkWithCredential(credential);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'provider-already-linked') {
                          // Phone may already be linked, which is fine
                        } else {
                          throw e;
                        }
                      }
                    }
                    
                    setState(() {
                      _isPhoneVerified = true;
                    });
                    
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone verified successfully!')),
                    );
                  } on FirebaseAuthException catch (e) {
                    setDialogState(() {
                      isVerifying = false;
                    });
                    
                    String errorMessage = 'Verification failed';
                    
                    if (e.code == 'invalid-verification-code') {
                      errorMessage = 'Invalid verification code. Please try again.';
                    } else if (e.code == 'session-expired') {
                      errorMessage = 'Verification session expired. Please request a new code.';
                      Navigator.of(context).pop();
                      _verifyPhoneNumber();
                      return;
                    } else {
                      errorMessage = 'Error: ${e.message}';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  } catch (e) {
                    setDialogState(() {
                      isVerifying = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to verify: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: isVerifying 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          color: Colors.white
                        )
                      )
                    : const Text('Verify'),
              ),
            ],
          );
        }
      ),
    );
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
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  hintText: 'username@gmail.com',
                  labelText: 'Email',
                ),
                const SizedBox(height: 10),
                // Phone Number Field with Verify Button
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        hintText: '+1234567890',
                        labelText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        enabled: !_isPhoneVerified,
                        helperText: 'Include country code (e.g., +1)',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading || _isPhoneVerified ? null : _verifyPhoneNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPhoneVerified ? Colors.green : Colors.white,
                        foregroundColor: _isPhoneVerified ? Colors.white : Colors.blue.shade800,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      child: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isPhoneVerified ? 'Verified ✓' : 'Verify Phone'),
                    ),
                  ],
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
                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // Moved "or continue with" text under the signup button
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
                // Social Media Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle Google Sign-In
                        _signInWithGoogle();
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
                        // Handle Gmail Sign-In (same as Google Sign-In)
                        _signInWithGoogle();
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
  
  // Google Sign In
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Here you would implement Google Sign-In
      // This is a placeholder for now as it requires GoogleSignIn package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In would be implemented here')),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        helperText: helperText,
        helperStyle: const TextStyle(color: Colors.white70, fontSize: 12),
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