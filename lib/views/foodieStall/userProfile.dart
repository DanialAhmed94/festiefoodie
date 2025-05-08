import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:festiefoodie/views/foodieStall/addStallView/viewallFestivals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../apis/updateProfile.dart';
import '../../utilities/scaffoldBackground.dart';
import '../../utilities/sharedPrefs.dart';
import 'addStallView/addStallView.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? userName;
  String? email;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool isUpdating = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    // Fetch the user name asynchronously.
    getUserName().then((fetchedName) {
      setState(() {
        userName = fetchedName;
        _usernameController.text = userName ?? "";// e.g. "John Doe"
      });
    });

    getUserEmail().then((fetchedEmail) {
      setState(() {
        email = fetchedEmail;
        _emailController.text = email ?? "";// e.g. "John Doe"

      });
    });
    // Add listeners to all focus nodes to scroll to the field when focused.
    _emailFocus.addListener(() => _scrollToFocusedField(_emailFocus));
    _usernameFocus.addListener(() => _scrollToFocusedField(_usernameFocus));
    _passwordFocus.addListener(() => _scrollToFocusedField(_passwordFocus));
    _confirmPasswordFocus.addListener(() => _scrollToFocusedField(_confirmPasswordFocus));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          150.0, // Adjust this value based on the position of your fields
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      body: Stack(
        children: [
          // Background SVG image
          Positioned.fill(
            child: SvgPicture.asset(
              AppConstants.scaffoldBackground,
              fit: BoxFit.cover,
            ),
          ),
          // AppBar positioned at the top
          Positioned(
            top: screenHeight * 0.02,
            left: horizontalPadding,
            right: horizontalPadding,
            child: _buildAppBar(),
          ),
          // Main content with form and Sign In button
          Positioned(
            top: screenHeight * 0.1,
            left: screenHeight * 0.01,
            right: screenHeight * 0.01,
            bottom: screenHeight * 0.01,
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF272727).withOpacity(0.2),
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: Colors.black),
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_usernameFocus);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Username TextField
                        TextFormField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          readOnly: false,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF272727).withOpacity(0.2),
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            suffixIcon: Icon(Icons.edit, color: Colors.white),
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: Colors.black),
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: _obscureOldPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF272727).withOpacity(0.2),
                            hintText: 'Old Password',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureOldPassword = !_obscureOldPassword;
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: Colors.black),
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password TextField
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF272727).withOpacity(0.2),
                            hintText: 'New Password',
                            hintStyle: TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(color: Colors.black),
                          onEditingComplete: () {
                            _confirmPasswordFocus.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Sign In Button
                  GestureDetector(
                    onTap: isUpdating
                        ? null
                        : () async {
                      if (_usernameController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please fill in all fields',
                              style: TextStyle(color: Colors.white),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black87,
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: Colors.orange,
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                        return;
                      }
                      if (_confirmPasswordController.text.trim().length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('New password must be at least 8 characters long', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: Colors.white,
                              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        isUpdating = true;
                      });

                      try {
                        await updateUserProfile(
                          context,
                          _usernameController.text.trim(),
                          _passwordController.text.trim(),
                          _confirmPasswordController.text.trim(),
                        );
                      } catch (e) {
                        // Optionally handle unexpected errors
                      } finally {
                        if (mounted) {
                          setState(() {
                            isUpdating = false;
                          });
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6900),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:  isUpdating
                            ?CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ):Text(
                          "Update",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return  AppBar(
      backgroundColor: Colors.transparent,
      title: const Text(
        "Edit Profile",
        style: TextStyle(
          fontFamily: "inter-semibold",
          fontSize: 32,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: SvgPicture.asset(AppConstants.backIcon, height: 50),
      ),
    );
  }
}
