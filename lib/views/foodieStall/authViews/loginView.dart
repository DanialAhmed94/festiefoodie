import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/views/foodieStall/authViews/signupView.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import '../../../apis/authentication/login.dart';
import '../../../utilities/authenticationBackground.dart';
import '../foofieStallHome.dart';

// 1) Add an _isLoading boolean to track API call state
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 1) This will let us show/hide the progress indicator
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => _scrollToFocusedField(_emailFocus));
    _passwordFocus.addListener(() => _scrollToFocusedField(_passwordFocus));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          150.0, // Adjust this value based on your layout
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
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    decoration: InputDecoration(
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
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Sign In Button
            GestureDetector(
              // 2) Make onTap async, call LogInApi, toggle _isLoading
              onTap: () async {
                setState(() => _isLoading = true);

                await LogInApi(
                  context,
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );

                setState(() => _isLoading = false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6900),
                  borderRadius: BorderRadius.circular(12),
                ),
                // 3) Conditionally show CircularProgressIndicator or "Sign In"
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  )
                      : const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            RichText(
              text: TextSpan(
                text: "Don’t have an account? ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: "Create account",
                    style: const TextStyle(
                      color: Color(0xFFFF6900),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          FadePageRouteBuilder(widget: const SignupView()),
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
