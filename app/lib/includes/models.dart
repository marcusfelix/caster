
// Class model for podcast episode
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Episode {
  final String id;
  final String title;
  final String description;
  final String url;
  final String? cover;
  final Duration duration;
  final DateTime date;
  final Uri? audio;
  final File local;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.cover,
    required this.duration,
    required this.date,
    this.audio,
    required this.local,
  });
}

// Class model for channel
class Thread {
  final String id;
  String name;
  String cover;
  String last;
  DateTime updated;

  Thread({
    required this.id,
    required this.name,
    required this.cover,
    required this.last,
    required this.updated,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "cover": cover,
      "last": last,
      "updated": updated.millisecondsSinceEpoch,
    };
  }
}

// Class for user profile
class Profile {
  final String uid;
  final String name;
  final String? photo;
  final bool online;

  Profile({
    required this.uid,
    required this.name,
    this.photo,
    this.online = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "photo": photo,
    };
  }
}

// Class model for a message
class Message {
  final String id;
  String body;
  final Profile user;
  List<Map<String, dynamic>> metadata;
  DateTime created;

  Message({
    required this.id,
    required this.body,
    required this.user,
    required this.metadata,
    required this.created,
  });

  factory Message.empty(User user) => Message(
    id: user.uid,
    body: "",
    user: Profile(
      uid: user.uid,
      name: user.displayName ?? "",
      photo: user.photoURL,
      online: false,
    ),
    metadata: [],
    created: DateTime.now()
  );

  Map<String, dynamic> toJson() {
    return {
      "body": body,
      "user": user.toJson(),
      "metadata": metadata,
      "created": created.millisecondsSinceEpoch,
    };
  }
}

final channelsTransformer = StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<Thread>>.fromHandlers(
  handleData: (data, sink) {
    final channels = <Thread>[];
    data.docs.forEach((element) {
      channels.add(Thread(
        id: element.id,
        name: element.data()['name'],
        cover: element.data()['cover'],
        last: element.data()['last'],
        updated: DateTime.fromMillisecondsSinceEpoch(element.data()['updated']),
      ));
    });
    sink.add(channels);
  }
);

final messagesTransformer = StreamTransformer<QuerySnapshot<Map<String, dynamic>>, List<Message>>.fromHandlers(
  handleData: (data, sink) {
    final messages = <Message>[];
    data.docs.forEach((element) {
      messages.add(Message(
        id: element.id,
        body: element.data()['body'],
        user: Profile(
          uid: element.data()['user']['uid'],
          name: element.data()['user']['name'],
          photo: element.data()['user']['photo'],
          online: false,
        ),
        metadata: List<Map<String, dynamic>>.from(element.data()['metadata']),
        created: DateTime.fromMillisecondsSinceEpoch(element.data()['created']),
      ));
    });
    sink.add(messages);
  }
);