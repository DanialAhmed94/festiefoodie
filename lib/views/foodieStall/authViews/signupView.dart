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

  // 1) Track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

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

            // SignUp Button
            GestureDetector(
              // 2) Make onTap async and call signUp
              onTap: () async {
                // Optional form check
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  // Call the signUp API with needed fields
                  await signUp(
                    context,
                    _usernameController.text,       // fullName
                    _emailController.text,          // email
                    '',                              // phone (empty)
                    Future.value([]),               // images (empty)
                    '',                              // organization (empty)
                    '',                              // organization address (empty)
                    _passwordController.text,        // password
                  );

                  setState(() {
                    _isLoading = false;
                  });

                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6900),
                  borderRadius: BorderRadius.circular(12),
                ),
                // 3) Show CircularProgressIndicator if loading
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    "SignUp",
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
