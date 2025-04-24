import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Blocs/Auth/login_bloc.dart';
import '../../Constants/text.dart';
import '../../Database/db_helper.dart';
import '../../Database/user_db_helper.dart';
import '../../Helper/api_response.dart';
import '../../Models/Auth/login_model.dart';
import '../../Repositories/Auth/login_repository.dart';
import '../../Widgets/widget_custom_num_pad.dart';
import '../../Widgets/widget_loading.dart';
import '../Home/fast_key_screen.dart';
import '../../Widgets/widget_error.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _password = List.filled(6, "");
  late LoginBloc _bloc;
  final UserDbHelper _userDbHelper = UserDbHelper();
  bool _hasErrorShown = false; // 👈 // Build #1.0.16 : Track if error is already shown

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc(LoginRepository());
  //  _checkExistingUser(); // Un comment this line if auto login needed
  }

  Future<void> _checkExistingUser() async {
    bool isLoggedIn = await _userDbHelper.isUserLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FastKeyScreen()),
      );
    }
  }

  void _updatePassword(String value) {
    for (int i = 0; i < _password.length; i++) {
      if (_password[i].isEmpty) {
        setState(() {
          _password[i] = value;
        });
        if (kDebugMode) {
          print("Password updated : $_password");
        }

        // Auto-submit when 6 digits are entered
        // if (i == 5) {
        //   _handleLogin();
        // }
        break;
      }
    }
  }

  void _deletePassword() {
    for (int i = _password.length - 1; i >= 0; i--) {
      if (_password[i].isNotEmpty) {
        setState(() {
          _password[i] = "";
        });
        if (kDebugMode) {
          print("Password deleted: $_password");
        }
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
    }
  }

  bool _validatePin() { // Build #1.0.13
    if (_password.any((digit) => digit.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit PIN',
          style: TextStyle(color: Colors.red))),
      );
      return false;
    }
    return true;
  }

  void _handleLogin() {
    if (!_validatePin()) return;
    _hasErrorShown = false; // Build #1.0.16: Reset error flag before login
    final pin = _password.join();
    _bloc.fetchLoginToken(LoginRequest(pin));
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Row(
        children: [
          // Left Side - Logo Section
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1E2745),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/app_logo.svg',
                  height: 150,
                ),
              ),
            ),
          ),

          // Right Side - Login Interface
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Password Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        double paddingValue = isPortrait ? 8.5 : 12.5;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: paddingValue),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey<int>(index),
                              width: isPortrait ? 50.0 : 70.0,
                              height: isPortrait ? 50.0 : 70.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Center(
                                child: _password[index].isEmpty
                                    ? SvgPicture.asset(
                                  'assets/svg/password_placeholder.svg',
                                  width: 15,
                                  height: 15,
                                )
                                    : SvgPicture.asset(
                                  'assets/svg/password_placeholder.svg',
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black, BlendMode.srcIn),
                                  width: 15,
                                  height: 15,
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
                      onDigitPressed: _updatePassword,
                      onClearPressed: _clearPassword,
                      onDeletePressed: _deletePassword,
                      actionButtonType: ActionButtonType.delete,
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width /
                          (isPortrait ? 7.3 : 7.2),
                      height: MediaQuery.of(context).size.height /
                          (isPortrait ? 20.0 : 10.0),
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2745), // Background color: #1E2745
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // In LoginScreen.dart - update the ElevatedButton's child widget
                        child: StreamBuilder<APIResponse<LoginResponse>>(
                          stream: _bloc.loginStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data?.status) {
                                case Status.LOADING:
                                  return Center(
                                    child: Loading(
                                      loadingMessage: snapshot.data?.message,
                                    ),
                                  );

                                case Status.COMPLETED:
                                  if (snapshot.data?.data?.token != null) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const FastKeyScreen()),
                                      );
                                    });
                                    return Center(
                                      child: Loading(
                                        loadingMessage: TextConstants.loading,
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Text(
                                        snapshot.data?.data?.message ?? "",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }

                                case Status.ERROR:
                                  if (!_hasErrorShown) { // 👈 Ensure error is shown only once
                                    _hasErrorShown = true;
                                    WidgetsBinding.instance.addPostFrameCallback((_) { // Build #1.0.16
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            snapshot.data?.message ?? "Login failed. Please try again.",
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                          backgroundColor: Colors.black, // ✅ Black background
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    });
                                  }
                                // return Center(
                                  //   child: Text(
                                  //     snapshot.data?.message ?? "Something went wrong",
                                  //     textAlign: TextAlign.center,
                                  //     style: const TextStyle(
                                  //       fontWeight: FontWeight.w600,
                                  //       fontSize: 16,
                                  //       color: Colors.red,
                                  //     ),
                                  //   ),
                                  // );
                                default:
                                  break;
                              }
                            }
                            return const Center(
                              child: Text(
                                TextConstants.loginBtnText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}