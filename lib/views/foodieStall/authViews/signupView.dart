import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import '../../../annim/transiton.dart';
import '../../../apis/authentication/signup.dart';
import '../../../utilities/authenticationBackground.dart';
import 'loginView.dart';

// 1) Add an _isLoading boolean
class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase instance
  final FocusNode _confirmPasswordFocus =
      FocusNode(); // Added confirm password focus
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Added confirm password controller
  bool _isVerificationStep = false; // Verification state
  bool _obscurePassword = true; // Password visibility
  bool _obscureConfirmPassword = true; // Confirm password visibility
  User? _firebaseUser; // Firebase user reference

  // Add these methods for email verification
  Future<void> _createFirebaseUserAndSendVerification() async {
    // First check form validation state
    if (!_formKey.currentState!.validate()) {
      // If invalid, manually trigger validation UI update
      _formKey.currentState!.validate();
      return;
    }

    // Additional client-side checks as fallback
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all required fields', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;
      await _firebaseUser!.sendEmailVerification();

      setState(() => _isVerificationStep = true);
      _showMessage('Verification email sent to $email');

    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak (min 6 characters)';
      } else if (e.code == 'email-already-in-use') {
        message = 'Account already exists for this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      }
      _showMessage(message, isError: true);

    } catch (e) {
      _showMessage('An unexpected error occurred', isError: true);

    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _checkEmailVerificationAndSignUp() async {
    setState(() => _isLoading = true);
    try {
      await _firebaseUser!.reload();
      _firebaseUser = _auth.currentUser;

      if (_firebaseUser!.emailVerified) {
        await signUp(
          context,
          _usernameController.text,
          _emailController.text,
          '',
          Future.value([]),
          '',
          '',
          _passwordController.text,
        );
      } else {
        _showMessage('Email not verified yet', isError: true);
      }
    } catch (e) {
      _showMessage('Verification check failed', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red : Colors.green, // Light black
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.orange,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  // 1) Track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
// Add confirm password focus listener
    _confirmPasswordFocus
        .addListener(() => _scrollToFocusedField(_confirmPasswordFocus));

    _emailFocus.addListener(() => _scrollToFocusedField(_emailFocus));
    _usernameFocus.addListener(() => _scrollToFocusedField(_usernameFocus));
    _passwordFocus.addListener(() => _scrollToFocusedField(_passwordFocus));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          150.0, // Adjust based on your layout
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticationBackgroundScaffold(
      child: SingleChildScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppConstants.foodielogo, height: 150, width: 150),
            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF272727).withOpacity(0.2),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_usernameFocus);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Username TextField
                  TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF272727).withOpacity(0.2),
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white),
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black),
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      // Existing decoration
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),

                      filled: true,
                      fillColor: const Color(0xFF272727).withOpacity(0.2),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.black),
                  ),

                  const SizedBox(height: 20),

                  // Add confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF272727).withOpacity(0.2),
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Colors.black26),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text)
                        return 'Passwords don\'t match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // SignUp Button
            // Updated signup button logic
            if (!_isVerificationStep) ...[
              GestureDetector(
                onTap: _createFirebaseUserAndSendVerification,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6900),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.5,
                          )
                        : const Text("SignUp",style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
            ],

            if (_isVerificationStep) ...[
              // Add verification UI elements
              GestureDetector(
                onTap: _checkEmailVerificationAndSignUp,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6900),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: const Text(
                                "I've verified my email",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  _firebaseUser?.sendEmailVerification();
                  _showMessage("Verification email sent",isError: false);
                },
                child: const Text(
                  "Resend verification email",
                  style: TextStyle(color: Color(0xFFFF6900)),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Already have an account? Sign In
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: "Sign In",
                    style: const TextStyle(
                      color: Color(0xFFFF6900),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          FadePageRouteBuilder(widget: const LoginView()),
                        );
                      },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:festiefoodie/constants/appConstants.dart';
// import '../../../annim/transiton.dart';
// import '../../../apis/authentication/signup.dart';
// import '../../../utilities/authenticationBackground.dart';
// import 'loginView.dart';
//
// // 1) Add an _isLoading boolean
// class SignupView extends StatefulWidget {
//   const SignupView({super.key});
//
//   @override
//   State<SignupView> createState() => _SignupViewState();
// }
//
// class _SignupViewState extends State<SignupView> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _emailFocus = FocusNode();
//   final FocusNode _usernameFocus = FocusNode();
//   final FocusNode _passwordFocus = FocusNode();
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   // 1) Track loading state
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _emailFocus.addListener(() => _scrollToFocusedField(_emailFocus));
//     _usernameFocus.addListener(() => _scrollToFocusedField(_usernameFocus));
//     _passwordFocus.addListener(() => _scrollToFocusedField(_passwordFocus));
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _emailFocus.dispose();
//     _usernameFocus.dispose();
//     _passwordFocus.dispose();
//     _emailController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToFocusedField(FocusNode focusNode) {
//     if (focusNode.hasFocus) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollController.animateTo(
//           150.0, // Adjust based on your layout
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AuthenticationBackgroundScaffold(
//       child: SingleChildScrollView(
//         controller: _scrollController,
//         keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(AppConstants.foodielogo, height: 150, width: 150),
//             const SizedBox(height: 30),
//
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Email TextField
//                   TextFormField(
//                     controller: _emailController,
//                     focusNode: _emailFocus,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: const Color(0xFF272727).withOpacity(0.2),
//                       hintText: 'Email',
//                       hintStyle: const TextStyle(color: Colors.black26),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       prefixIcon: const Icon(Icons.email, color: Colors.white),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.next,
//                     style: const TextStyle(color: Colors.black),
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(_usernameFocus);
//                     },
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Username TextField
//                   TextFormField(
//                     controller: _usernameController,
//                     focusNode: _usernameFocus,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: const Color(0xFF272727).withOpacity(0.2),
//                       hintText: 'Username',
//                       hintStyle: const TextStyle(color: Colors.black26),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       prefixIcon: const Icon(Icons.person, color: Colors.white),
//                     ),
//                     keyboardType: TextInputType.name,
//                     textInputAction: TextInputAction.next,
//                     style: const TextStyle(color: Colors.black),
//                     onEditingComplete: () {
//                       FocusScope.of(context).requestFocus(_passwordFocus);
//                     },
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Password TextField
//                   TextFormField(
//                     controller: _passwordController,
//                     focusNode: _passwordFocus,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: const Color(0xFF272727).withOpacity(0.2),
//                       hintText: 'Password',
//                       hintStyle: const TextStyle(color: Colors.black26),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       prefixIcon: const Icon(Icons.lock, color: Colors.white),
//                     ),
//                     keyboardType: TextInputType.visiblePassword,
//                     textInputAction: TextInputAction.done,
//                     style: const TextStyle(color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // SignUp Button
//             GestureDetector(
//               // 2) Make onTap async and call signUp
//               onTap: () async {
//                 // Optional form check
//                 if (_formKey.currentState!.validate()) {
//                   setState(() {
//                     _isLoading = true;
//                   });
//
//                   // Call the signUp API with needed fields
//                   await signUp(
//                     context,
//                     _usernameController.text,       // fullName
//                     _emailController.text,          // email
//                     '',                              // phone (empty)
//                     Future.value([]),               // images (empty)
//                     '',                              // organization (empty)
//                     '',                              // organization address (empty)
//                     _passwordController.text,        // password
//                   );
//
//                   setState(() {
//                     _isLoading = false;
//                   });
//
//                 }
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFF6900),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 // 3) Show CircularProgressIndicator if loading
//                 child: Center(
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 2.5,
//                   )
//                       : const Text(
//                     "SignUp",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // Already have an account? Sign In
//             RichText(
//               text: TextSpan(
//                 text: "Already have an account? ",
//                 style: const TextStyle(color: Colors.black, fontSize: 16),
//                 children: [
//                   TextSpan(
//                     text: "Sign In",
//                     style: const TextStyle(
//                       color: Color(0xFFFF6900),
//                       fontWeight: FontWeight.bold,
//                     ),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         Navigator.push(
//                           context,
//                           FadePageRouteBuilder(widget: const LoginView()),
//                         );
//                       },
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
