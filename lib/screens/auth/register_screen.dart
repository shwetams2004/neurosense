import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

import 'login_screen.dart';

class RegisterScreen
    extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen>
      createState() =>
          _RegisterScreenState();
}

class _RegisterScreenState
    extends State<
        RegisterScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  bool obscureConfirmPassword =
      true;

  String currentLanguage =
      "English";

  @override
  void initState() {

    super.initState();

    loadLanguage();
  }

  Future<void> loadLanguage()
      async {

    currentLanguage =
        await LocalStore
            .getLanguage();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> register()
      async {

    setState(() => loading = true);

    if (passwordController.text !=
        confirmPasswordController
            .text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Passwords do not match",
          ),
        ),
      );

      setState(
        () => loading = false,
      );

      return;
    }

    final error =
        await AuthService.register(

      email:
          emailController.text
              .trim(),

      password:
          passwordController.text
              .trim(),
    );

    setState(
      () => loading = false,
    );

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    if (mounted) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "create_account",
            currentLanguage,
          ),
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(

          children: [

            TextField(

              controller:
                  emailController,

              decoration:
                  InputDecoration(

                labelText:
                    AppStrings.text(
                  "email",
                  currentLanguage,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  passwordController,

              obscureText:
                  obscurePassword,

              decoration:
                  InputDecoration(

                labelText:
                    AppStrings.text(
                  "password",
                  currentLanguage,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    obscurePassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  confirmPasswordController,

              obscureText:
                  obscureConfirmPassword,

              decoration:
                  InputDecoration(

                labelText:
                    AppStrings.text(
                  "confirm_password",
                  currentLanguage,
                ),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),

                  onPressed: () {

                    setState(() {

                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    loading
                        ? null
                        : register,

                child: Text(

                  loading

                      ? AppStrings.text(
                          "creating",
                          currentLanguage,
                        )

                      : AppStrings.text(
                          "create_account",
                          currentLanguage,
                        ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextButton(

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const LoginScreen(),
                  ),
                );
              },

              child: Text(

                AppStrings.text(
                  "login_prompt",
                  currentLanguage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}