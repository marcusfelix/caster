import 'package:app/components/large_button.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    Key? key
  }) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String _name = "";
  String _email = "";
  String _password = "";
  String? _error;
  bool _working = false;

  Future<User?> create(services) async {
    setState(() => _working = true);
    // Creating user
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password).then((auth) async {
      await auth.user?.updateDisplayName(_name);
      return auth.user;
    }).catchError((e){
      setState(() {
        _working = false;
        _error = e.message;
      });
    });
  }

  void throwError(String message){
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
       message,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onErrorContainer
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.errorContainer
    ));
  }

  bool validate() => _name.isNotEmpty && _email.isNotEmpty && _password.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          services.configs.value["create_account_string"],
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: services.configs.value["name_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _name = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: services.configs.value["email_string"],
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    onChanged: (String value) => setState(() => _email = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: services.configs.value["password_string"],
                    ),
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
              ],
            ),
          ),
          LargeButton(
            label: services.configs.value["create_account_string"],
            working: _working,
            viewPadding: true,
            onPressed: validate() ? () => create(services).then((value) => value != null ? Navigator.of(context).pop(value) : null) : null,
          )
        ],
      ),
    );
  }

}
