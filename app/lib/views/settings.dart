import 'dart:io';

import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/uploads.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Settings extends StatefulWidget {
  const Settings({
    Key? key,
    required this.user
  }) : super(key: key);

  final User user;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _name;
  late String _email;
  late String? _photo;
  bool _working = false;

  @override
  void initState() {
    _name = widget.user.displayName!;
    _email = widget.user.email!;
    _photo = widget.user.photoURL;
    super.initState();
  }

  Future save(ServiceController services) async {
    setState(() => _working = true);
    await services.auth.currentUser!.updateDisplayName(_name);
    setState(() => _working = false);
  }

  Future upload(ServiceController services) async {
    setState(() => _working = true);

    // Pick a image file
    File? image = await filePicker();

    if(image == null) return;

    // Resize
    File thumb = await resizeImage(image, const Size(120, 120));

    // Upload
    String? url = await uploadFile(services, thumb, "images/profiles", services.auth.currentUser!.uid, services.auth.currentUser!.uid);

    if(url == null) return;

    // Update user
    await services.auth.currentUser!.updatePhotoURL(url);
    setState(() {
      _photo = url;
      _working = false;
    });
  }

  void changePassword() {
    final services = ServiceContext.of(context).controller;

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
              services.auth.sendPasswordResetEmail(email: _email);
              Navigator.of(context).pop();
            },
            child: Text(services.configs.value["continue_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  void logout() async {
    final services = ServiceContext.of(context).controller;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["logout_string"]),
        content: Text(services.configs.value["are_you_shure_question_string"]),
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
              services.auth.signOut().then((value) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            },
            child: Text(services.configs.value["logout_string"].toUpperCase()),
          )
        ],
      ),
    );
  }

  void delete() {
    final services = ServiceContext.of(context).controller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["delete_account_question_string"]),
        content: Text(services.configs.value["this_action_will_delete_string"]),
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
              // Reauthenticate
              widget.user.delete().then((value) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            },
            child: Text(
              services.configs.value["delete_string"].toUpperCase(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        ],
      ),
    );
  }

  void clear() async {
    final services = ServiceContext.of(context).controller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(services.configs.value["clear_local_data_question_string"]),
        content: Text(services.configs.value["this_action_will_clear_string"]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              services.configs.value["cancel_string"].toUpperCase(),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Delete all local files
              List<FileSystemEntity> files = services.directory?.listSync() ?? [];
              for (FileSystemEntity file in files) {
                try {
                  file.deleteSync();
                } catch(e){
                  print(e);
                }
              }
              Navigator.of(context).pop();
            },
            child: Text(
              services.configs.value["clear_string"].toUpperCase(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        ],
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
        title: Text(
          services.configs.value["settings_string"],
        ),
        actions: [
          IconButton(
            onPressed: _working ? null : () => save(services).then((value) => Navigator.of(context).pop()), 
            icon: _working ? SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary)
              )
            ) : Icon(
              PhosphorIcons.bold.checkCircle, 
              size: 28
            )
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 16), children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: _photo != null ? NetworkImage(_photo!) : null,
            ),
            title: Text(services.configs.value["upload_profile_image_string"]),
            onTap: () => upload(services),
            trailing: Icon(
              PhosphorIcons.bold.uploadSimple,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3)
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            initialValue: _name,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: services.configs.value["name_string"]
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            onChanged: (String value) => setState(() => _name = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextFormField(
            initialValue: _email,
            keyboardType: TextInputType.emailAddress,
            enabled: false,
            decoration: InputDecoration(
              labelText: services.configs.value["email_string"]
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        const SizedBox(height: 42),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => changePassword(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              services.configs.value["change_password_string"].toUpperCase(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => logout(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              services.configs.value["logout_string"].toUpperCase(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => delete(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              services.configs.value["delete_account_string"].toUpperCase(),
            ),
          ),
        ),
        !kIsWeb ? Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextButton(
            onPressed: () => clear(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
              services.configs.value["clear_local_data_string"].toUpperCase(),
            ),
          ),
        ) : Container(),
      ]),
    );
  }
}
