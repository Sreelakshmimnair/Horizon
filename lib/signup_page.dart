import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'homepage.dart';

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
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _isEmailSent = false;
  User? _verifiedUser;
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // Check email validation first (without creating temp user)
  Future<void> _verifyEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    
    // Check password fields
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
      return;
    }
    
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
      
      // Check if email is already in use
      List<String> methods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      if (methods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered. Please use a different email or login.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Create user with the user's chosen password directly
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text, // Use the user's password from the start
      );
      
      _verifiedUser = userCredential.user;
      
      // Send verification email
      await _verifiedUser!.sendEmailVerification();
      
      // Set up listener for auth state changes to check when email is verified
      _setupEmailVerificationListener(_verifiedUser!);
      
      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });
      
      // Show verification dialog
      _showEmailVerificationDialog();
      
    } on FirebaseAuthException catch (e) {
      debugPrint('Email verification error: ${e.code} - ${e.message}');
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = 'Failed to send verification email';
      if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already registered. Please login instead.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak. Please use a stronger password.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      debugPrint('Email verification general error: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  // Set up listener to check for email verification
  void _setupEmailVerificationListener(User user) {
    // Set up a timer to periodically check if the email is verified
    Stream.periodic(const Duration(seconds: 3)).listen((_) async {
      if (_isEmailVerified) return;
      
      try {
        // Reload the user to get the updated status
        await user.reload();
        User? refreshedUser = _auth.currentUser;
        
        if (refreshedUser != null && refreshedUser.emailVerified) {
          setState(() {
            _isEmailVerified = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verified successfully!')),
          );
          
          // Close verification dialog if it's open
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        debugPrint('Error checking email verification: $e');
      }
    });
  }
  
  // Complete registration after email is verified
  Future<void> _registerUser() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first')),
      );
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Ensure user is signed in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // If somehow the user is not signed in, sign in with the provided credentials
        UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        currentUser = userCred.user;
      }
      
      // Make sure we have a valid user before proceeding
      if (currentUser == null) {
        throw Exception("Failed to authenticate user");
      }
      
      // Store additional user info in Firestore
      try {
        await _firestore.collection('users').doc(currentUser.uid).set({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(), // Use server timestamp instead
          'authProvider': 'email',
        });
      } catch (firestoreError) {
        debugPrint('Firestore error: $firestoreError');
        throw Exception("Permission denied: Make sure your Firebase rules allow writing to the users collection");
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      String message = 'An error occurred';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'There was a problem with your account. Please verify your email again.';
        // Sign out the user to start fresh
        await _auth.signOut();
        setState(() {
          _isEmailVerified = false;
          _isEmailSent = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show email verification dialog
  Future<void> _showEmailVerificationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A verification email has been sent to your email address. Please check your inbox and click the verification link.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
             'After verifying, return to this screen and click "I\'ve Verified" button below.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive email? "),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Resend verification email
                    _auth.currentUser?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification email resent!')),
                    );
                    _showEmailVerificationDialog();
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
            onPressed: () async {
              if (_auth.currentUser != null) {
                try {
                  await _auth.currentUser!.reload();
                  if (_auth.currentUser!.emailVerified) {
                    setState(() {
                      _isEmailVerified = true;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email verified successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email not verified yet. Please check your inbox and click the verification link.')),
                    );
                  }
                } catch (e) {
                  debugPrint('Error checking verification: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
           child: const Text('I\'ve Verified'),
          ),
        ],
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
                // Email Field with Verify Button
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        hintText: 'username@gmail.com',
                        labelText: 'Email',
                        enabled: !_isEmailVerified,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading || _isEmailVerified ? null : _verifyEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEmailVerified ? Colors.green : Colors.white,
                        foregroundColor: _isEmailVerified ? Colors.white : Colors.blue.shade800,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      child: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEmailVerified ? 'Verified ✓' : 'Verify Email'),
                    ),
                  ],
                ),
                if (_isEmailSent && !_isEmailVerified)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Verification email sent! Check your inbox and click the link, then click "Verify Email" again',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                // Phone Number Field (no verification)
                _buildTextField(
                  controller: _phoneController,
                  hintText: '+92XXXXXXXXXX',
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  helperText: 'Include country code (e.g., +92)',
                ),
                const SizedBox(height: 10),
                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  labelText: 'Password',
                  obscureText: true,
                  enabled: !_isEmailVerified,
                ),
                const SizedBox(height: 10),
                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Re-type your password',
                  labelText: 'Confirm Password',
                  obscureText: true,
                  enabled: !_isEmailVerified,
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
                      onTap: _isLoading ? null : _signInWithGoogle,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.asset(
                                'assets/images/google.png',
                                height: 30,
                                width: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _isLoading ? null : _signInWithGoogle, // Same method for Gmail
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.asset(
                                'assets/images/gmail.png',
                                height: 30,
                                width: 30,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
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
  
  // Google Sign In implementation
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      
      // If the user cancels the sign-in flow, return early
      if (gUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for the user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Check if the email already exists
      final isNewUser = await _checkIfNewUser(gUser.email);

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // If this is a new user, store their information in Firestore
      if (isNewUser) {
        try {
          await _storeGoogleUserInFirestore(userCredential.user!, gUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        } catch (firestoreError) {
          debugPrint('Firestore error: $firestoreError');
          // Continue despite Firestore error - user is still authenticated
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully, but profile data could not be saved.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
      }

      // Navigate to home screen regardless of Firestore success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google Sign-In failed. Please try again.';
      
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'An account already exists with the same email address.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The Google credential is invalid or has expired.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check if the user is new
  Future<bool> _checkIfNewUser(String email) async {
    try {
      // First, check if the email exists as a Firebase Auth user
      List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty && !methods.contains('google.com')) {
        // Email exists but not with Google auth
        throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'An account already exists with the same email address but different sign-in method.'
        );
      }
      
      if (methods.contains('google.com')) {
        // User already exists with Google sign-in
        return false;
      }
      
      // Don't check Firestore - rely solely on Auth methods
      return true;
    } catch (e) {
      debugPrint('Error checking if user is new: $e');
      rethrow;
    }
  }

  // Store Google user info in Firestore
  Future<void> _storeGoogleUserInFirestore(User user, GoogleSignInAccount googleUser) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': googleUser.displayName ?? '',
        'email': googleUser.email,
        'phoneNumber': user.phoneNumber ?? '',
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        'authProvider': 'google',
        'photoURL': googleUser.photoUrl ?? '',
      });
    } catch (e) {
      debugPrint('Error storing Google user: $e');
      rethrow;
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