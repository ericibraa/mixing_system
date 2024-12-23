import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _loginBloc = LoginBloc();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  bool _obscurePasswordText = true;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
      create: (context) => _loginBloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            print("Login success");
            BlocProvider.of<AuthBloc>(context).add(ChangeAuthStatus(
                token: state.token, csrfToken: state.csrfToken));
            context.push("/validation");
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Invalid username or password"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 200),
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/logo/mixing_system.png",
                        fit: BoxFit.cover,
                        width: 270,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Text(
                        "v ${_packageInfo.version}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: TextFormField(
                                controller: usernameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  label: const Text("User SAP"),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'User SAP required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 50),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePasswordText,
                                decoration: InputDecoration(
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePasswordText =
                                            !_obscurePasswordText;
                                      });
                                    },
                                    child: Icon(_obscurePasswordText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  label: const Text("Password"),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _loginBloc.add(SendLoginData(
                                    username: usernameController.text,
                                    password: passwordController.text));
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size.fromHeight(50)),
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}
