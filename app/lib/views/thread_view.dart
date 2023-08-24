import 'package:app/components/composer.dart';
import 'package:app/components/message_tile.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:app/views/threads_edit.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ThreadView extends StatelessWidget {
  ThreadView({
    super.key,
    required this.thread
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.arrowLeft),
        ),
        title: Text(thread.name),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context, 
                isScrollControlled: true,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: MediaQuery.of(context).viewInsets,
                  child: ThreadEdit(
                    thread: thread
                  )
                )
              );
            },
            icon: Icon(PhosphorIcons.bold.pencilSimple),
          ),
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: services.firestore.collection("threads").doc(thread.id).collection("messages").snapshots().transform(messagesTransformer),
        builder: (context, messages) {
          return ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: (messages.data ?? []).map((message) => MessageTile(
              key: Key(message.id), 
              message: message
            )).toList()
          );
        }
      ),
      bottomNavigationBar: services.auth.currentUser != null ? Composer(
        user: services.auth.currentUser!,
        thread: thread
      ) : null,
    );
  }

}