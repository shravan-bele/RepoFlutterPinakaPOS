import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Widgets/widget_custom_num_pad.dart';
import '../Home/fast_key_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _password = List.filled(6, ""); // Password storage

  // Update password on digit press
  void _updatePassword(String value) {
    for (int i = 0; i < _password.length; i++) {
      if (_password[i].isEmpty) {
        setState(() {
          _password[i] = value; // Fill the field with the digit pressed
        });
        if (kDebugMode) {
          print("Password updated: $_password");
        } // Print password after update
        break;
      }
    }
  }

  // Delete single password character with animation
  void _deletePassword() {
    for (int i = _password.length - 1; i >= 0; i--) {
      if (_password[i].isNotEmpty) {
        setState(() {
          _password[i] = ""; // Clear only the last entered field
        });
        if (kDebugMode) {
          print("Password deleted: $_password");
        } // Print password after deletion
        break;
      }
    }
  }

  // Clear all fields with animation by resetting them one by one
  void _clearPassword() {
    setState(() {
      // Clear the fields one by one to trigger the animation on each field
      for (int i = 0; i < _password.length; i++) {
        _password[i] = ""; // Reset each field with animation
      }
    });
    if (kDebugMode) {
      print("Password cleared: $_password");
    } // Print password after clearing all fields
  }

  @override
  Widget build(BuildContext context) {
    // Get device orientation
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Logo Section
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1E2745), // background: #1E2745
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/app_logo.svg', // Path to your SVG
                  height: 150, // Set the height of the logo
                ),
              ),
            ),
          ),

          // Right Side - Login Interface
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Secure Password Fields with Animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      // Adjust padding based on orientation
                      double paddingValue = isPortrait ? 8.5 : 12.5;
                      return Padding(
                        padding:  EdgeInsets.symmetric(horizontal: paddingValue),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            key: ValueKey<int>(index), // Unique key to trigger animation
                            width: isPortrait ? 50.0 : 70.0,
                            height: isPortrait ? 50.0 : 70.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF), //background: #FFFFFF;
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: Center(
                              child: _password[index].isEmpty
                                  ? SvgPicture.asset(
                                'assets/svg/password_placeholder.svg', // Path to your empty image
                                width: 15, // Set appropriate width
                                height: 15, // Set appropriate height
                              )
                                  : SvgPicture.asset(
                                'assets/svg/password_placeholder_fill.svg',
                                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                width: 15, // Set appropriate width
                                height: 15, // Set appropriate height
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Custom NumPad
                  CustomNumPad(
                    onDigitPressed: (value) {
                      _updatePassword(value);
                    },
                    onClearPressed: () {
                      _clearPassword();
                    },
                    onDeletePressed: () {
                      _deletePassword();
                    },
                  ),

                  const SizedBox(height: 32),

                  // Login Button Below NumPad
                  SizedBox(
                    width: MediaQuery.of(context).size.width / (isPortrait ? 7.3 : 7.2), // Dynamic width
                    height: MediaQuery.of(context).size.height / (isPortrait ? 20.0 : 10.0), // Dynamic width
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle login press
                        if (kDebugMode) {
                          print("Login pressed");
                        }
                        /// FastKeyScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const FastKeyScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2745), // background: #1E2745
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}