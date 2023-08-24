import 'package:app/components/large_button.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginWithEmail extends StatefulWidget {
  const LoginWithEmail({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginWithEmail> createState() => _LoginWithEmailState();
}

class _LoginWithEmailState extends State<LoginWithEmail> {
  String _email = "";
  String _password = "";
  String? _error;
  bool _working = false;

  Future<UserCredential?> login(services) async {
    setState(() => _working = true);
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password).catchError((e) {
      setState(() {
        _working = false;
        _error = e.message;
      });
    });
  }

  void forgot(services) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["password_reset_string"]),
        content: Text(services.configs.value["you_will_receive_email_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
              Navigator.of(context).pop();
            },
            child: Text(services.configs.value["cancel_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  bool validate() => (validateEmail(_email) && _password.isNotEmpty);

  bool validateEmail(String email) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          services.configs.value["login_with_email_string"],
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                    child: TextFormField(
                      key: const Key("email"),
                      keyboardType: TextInputType.emailAddress,
                      decoration: decoration(services.configs.value["email_string"]),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      onChanged: (String value) => setState(() => _email = value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: TextFormField(
                      key: const Key("password"),
                      obscureText: true,
                      decoration: decoration(services.configs.value["password_string"]),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      onChanged: (String value) => setState(() => _password = value),
                    ),
                  ),
                  if (_error != null) Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  validateEmail(_email) ? TextButton(onPressed: () => forgot(services), child: Text(services.configs.value["forgot_password_string"].toUpperCase())) : Container()
                ],
              ),
            ),
          ),
          LargeButton(
            label: services.configs.value["login_string"],
            working: _working,
            viewPadding: true,
            onPressed: validate() ? () {
              login(services).then((auth) {
                if(auth != null){
                  Navigator.of(context).pop(auth);
                }
              });
            } : null,
          ),
        ],
      ),
    );
  }

  InputDecoration decoration(String label) => InputDecoration(
    labelText: label,
    hintStyle: const TextStyle(color: Colors.black54),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.primary),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.black26),
    ),
    border: const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.black26),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Colors.black12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
    ),
  );
}
