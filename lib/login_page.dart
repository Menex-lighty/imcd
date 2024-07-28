import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'admin_home_page.dart';
import 'user_home_page.dart';
import 'login_state.dart' as login_state_file;

class LoginPage extends StatefulWidget {
  static String id = '/LoginPage';

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  String usernameOrPhoneNumber = '';
  String password = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => login_state_file.LoginState(),
      child: Consumer<login_state_file.LoginState>(
        builder: (context, loginState, child) {
          return Scaffold(
            body: ModalProgressHUD(
              inAsyncCall: loginState.showSpinner,
              color: Colors.blueAccent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [
                      Colors.orange.shade900,
                      Colors.orange.shade800,
                      Colors.orange.shade400,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FadeInUp(
                              duration: const Duration(milliseconds: 1000),
                              child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 40)),
                            ),
                            const SizedBox(height: 10),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1300),
                              child: const Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 60),
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'Admin'),
                                  Tab(text: 'User'),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildAdminLogin(context, loginState),
                                    _buildUserLogin(context, loginState),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminLogin(BuildContext context, login_state_file.LoginState loginState) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(225, 95, 27, .3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  usernameOrPhoneNumber = value;
                },
                decoration: InputDecoration(
                  hintText: "Username",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  errorText: loginState.wrongUsernameOrPhone ? 'Invalid Username' : null,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  password = value;
                  loginState.updatePasswordRules(value);
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  errorText: loginState.wrongPassword ? 'Invalid Password' : null,
                ),
              ),
            ),
            _buildPasswordRules(loginState),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1500),
              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1600),
              child: MaterialButton(
                onPressed: () async {
                  loginState.toggleSpinner(true);
                  await Future.delayed(const Duration(seconds: 1)); // Simulate API call
                  if (!mounted) return;
                  if (usernameOrPhoneNumber == 'Admin' && password == 'Admin') {
                    Navigator.pushReplacementNamed(context, AdminHomePage.id);
                  } else {
                    loginState.toggleWrongUsernameOrPhone(true);
                    loginState.toggleWrongPassword(true);
                  }
                  loginState.toggleSpinner(false);
                },
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLogin(BuildContext context, login_state_file.LoginState loginState) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(225, 95, 27, .3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  usernameOrPhoneNumber = value;
                },
                decoration: InputDecoration(
                  hintText: "Phone number",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  errorText: loginState.wrongUsernameOrPhone ? 'Invalid Phone number' : null,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  password = value;
                  loginState.updatePasswordRules(value);
                },
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  errorText: loginState.wrongPassword ? 'Invalid Password' : null,
                ),
              ),
            ),
            _buildPasswordRules(loginState),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1500),
              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1600),
              child: MaterialButton(
                onPressed: () async {
                  loginState.toggleSpinner(true);
                  await Future.delayed(const Duration(seconds: 1)); // Simulate API call
                  if (!mounted) return;
                  if (usernameOrPhoneNumber == '1234567890' && password == 'User') {
                    Navigator.pushReplacementNamed(context, UserHomePage.id);
                  } else {
                    loginState.toggleWrongUsernameOrPhone(true);
                    loginState.toggleWrongPassword(true);
                  }
                  loginState.toggleSpinner(false);
                },
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRules(login_state_file.LoginState loginState) {
    return Visibility(
      visible: loginState.showPasswordRules,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                loginState.hasUppercase ? Icons.check : Icons.close,
                color: loginState.hasUppercase ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              const Text("One Uppercase"),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                loginState.hasDigits ? Icons.check : Icons.close,
                color: loginState.hasDigits ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              const Text("One number"),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                loginState.hasLowercase ? Icons.check : Icons.close,
                color: loginState.hasLowercase ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              const Text("One Lowercase"),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                loginState.hasSpecialCharacters ? Icons.check : Icons.close,
                color: loginState.hasSpecialCharacters ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              const Text("One Special Character"),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                loginState.passwordLength ? Icons.check : Icons.close,
                color: loginState.passwordLength ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              const Text("At least 8 characters"),
            ],
          ),
        ],
      ),
    );
  }
}
