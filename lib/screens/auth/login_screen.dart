import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../onboarding/language_selection_screen.dart';
import '../onboarding/caregiver_intro_screen.dart';
import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';
import 'register_screen.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen>
      createState() =>
          _LoginScreenState();
}

class _LoginScreenState
    extends State<
        LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  bool obscurePassword = true;
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
  Future<void> login() async {

    setState(() => loading = true);

    final error =
        await AuthService.login(

      email:
          emailController.text
              .trim(),

      password:
          passwordController.text
              .trim(),
    );

    setState(() => loading = false);

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }
TextInput.finishAutofillContext();
    if (mounted) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
    const CaregiverIntroScreen(),
        ),
      );
    }
  }

  Future<void>
      forgotPassword() async {

    if (emailController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Enter your email first",
          ),
        ),
      );

      return;
    }

    final error =
        await AuthService
            .resetPassword(

      emailController.text
          .trim(),
    );

    if (error != null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(error),
        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Password reset email sent",
          ),
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
    "login",
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
            AutofillGroup(

  child: Column(

    children: [

      TextField(

        controller: emailController,

        autofillHints: const [

          AutofillHints.email,

          AutofillHints.username,
        ],

        keyboardType:
            TextInputType.emailAddress,

        textInputAction:
            TextInputAction.next,

        decoration: InputDecoration(

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

        autofillHints: const [
          AutofillHints.password,
        ],

        obscureText:
            obscurePassword,

        textInputAction:
            TextInputAction.done,

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
                  : Icons.visibility_off,
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
    ],
  ),
),



            Align(

              alignment:
                  Alignment.centerRight,

              child: TextButton(

                onPressed:
                    forgotPassword,

                child: Text(
  AppStrings.text(
    "forgot_password",
    currentLanguage,
  ),
),
              ),
            ),

            

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    loading
                        ? null
                        : login,

                child: Text(

                  loading

    ? AppStrings.text(
        "logging_in",
        currentLanguage,
      )

    : AppStrings.text(
        "login",
        currentLanguage,
      ),
                ),
              ),
            ),

            const SizedBox(
                height: 16),

            
            TextButton(

  onPressed: () {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>
    const RegisterScreen(),
      ),
    );
  },

  child: Text(

    AppStrings.text(
      "register_prompt",
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