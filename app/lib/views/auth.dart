import 'package:app/components/large_button.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:app/views/create_account.dart';
import 'package:app/views/login_with_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Auth extends StatelessWidget {
  Auth({
    Key? key, 
    this.withNavigator = false
  }) : super(key: key);

  final bool withNavigator;

  Future signWithGoogle(context, ServiceController services) async {
    // Trigger the authentication flow
    //final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    //final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
    return Future.error("Not implemented");
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          services.configs.value["welcome_to_app_string"],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimaryContainer
        ),
        automaticallyImplyLeading: false,
        leading: withNavigator ? IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ) : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 32, 16, MediaQuery.of(context).viewPadding.bottom + 32),
            child: Column(
              children: ([]).map<Widget>((e) => Column(
                children: [
                  LargeButton(
                    label: "",
                    onPressed: () {}
                  ),
                  const SizedBox(height: 16),
                ],
              )).toList()..addAll([
                LargeButton(
                  label: services.configs.value["login_with_google_string"],
                  widget: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    children: [
                      Image.asset(
                        "assets/google.png", 
                        width: 24, 
                        height: 24
                      ),
                      Text(
                        services.configs.value["login_with_google_string"],
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w600, 
                          color: Colors.grey.shade700
                        ),
                      ),
                    ],
                  ),
                  rounded: true,
                  backgroundColor: Colors.grey.shade200,
                  onPressed: () {
                    signWithGoogle(context, services);
                  }
                ),
                const SizedBox(height: 16),
                LargeButton(
                  label: services.configs.value["login_with_email_string"],
                  rounded: true,
                  onPressed: () {
                    showModalBottomSheet<UserCredential?>(
                      context: context, 
                      isScrollControlled: true,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        margin: MediaQuery.of(context).viewInsets,
                        child: const LoginWithEmail()
                      )
                    ).then((UserCredential? value) => value != null ? Navigator.of(context).pop(value) : null);
                  }
                ),
                const SizedBox(height: 16),
                LargeButton(
                  label: services.configs.value["create_account_string"],
                  backgroundColor: Theme.of(context).colorScheme.background,
                  color: Theme.of(context).colorScheme.onBackground,
                  rounded: true,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context, 
                      isScrollControlled: true,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        margin: MediaQuery.of(context).viewInsets,
                        child: const CreateAccount()
                      )
                    ).then((value) => value != null ? Navigator.of(context).pop(value) : null);
                  }
                )
              ]),
            )
          ),
        ],
      ),
    );
  }
}
