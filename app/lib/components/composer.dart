import 'dart:io';

import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:app/includes/uploads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.user,
    required this.thread
  });

  final User user;
  final Thread thread;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final TextEditingController body = TextEditingController();
  late Message message;
  bool _working = false;

  Uuid uuid = const Uuid();

  @override
  void initState() {
    message = Message.empty(widget.user);
    super.initState();
  }

  void send() async {
    // Do nothing if text field is empty
    if (body.text.isEmpty) return;

    // Setting state to working
    setState(() => _working = true);
    final services = ServiceContext.of(context).controller;

    // Updating data
    message.created = DateTime.now();
    message.body = body.text;

    // Creating message on database
    await services.firestore.collection("threads").doc(widget.thread.id).collection("messages").add(message.toJson());
    await services.firestore.collection("threads").doc(widget.thread.id).update({
      "last": message.body,
      "updated": message.created.millisecondsSinceEpoch 
    });

    // Clearing text field
    body.clear();
    setState(() {
      message = Message.empty(widget.user);
      _working = false;
    });
  }

  Future upload(ServiceController services) async {
    setState(() => _working = true);

    // Pick a image file
    File? image = await filePicker();

    if(image == null) return;

    // Resize
    File thumb = await resizeImage(image, const Size(100, 100));

    // Upload
    String? url = await uploadFile(services, thumb, "images/threads", uuid.v4(), widget.user.uid);

    if (url != null) {
      setState(() => body.text += "${body.text} $url");
    }

    setState(() => _working = false);
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;
    
    return Container(
      color: Theme.of(context).colorScheme.onBackground,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom : MediaQuery.of(context).viewPadding.bottom),
      child: TextFormField(
        controller: body,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          hintText: services.configs.value["your_next_message_string"],
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.background.withOpacity(0.3)
          ),
          border: InputBorder.none,
          prefixIcon: IconButton(
            onPressed: () => upload(services),
            icon: Icon(
              PhosphorIcons.regular.imageSquare,
              color: Theme.of(context).colorScheme.background,
              size: 24,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: _working ? null : () => send(),
            icon: _working ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.background),
              ),
            ) : Icon(
              PhosphorIcons.regular.checkCircle,
              color: Theme.of(context).colorScheme.background,
              size: 24,
            ),
          )
        ),
        style: TextStyle(
          fontSize: 16, 
          color: Theme.of(context).colorScheme.background
        ),
      ),
    );
  }
}