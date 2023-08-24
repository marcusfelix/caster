import 'package:app/components/large_button.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ThreadEdit extends StatefulWidget {
  const ThreadEdit({
    super.key,
    this.thread
  });

  final Thread? thread;

  @override
  State<ThreadEdit> createState() => _ThreadEditState();
}

class _ThreadEditState extends State<ThreadEdit> {
  late Thread _thread;
  bool _working = false;

  @override
  void initState() {
    _thread = widget.thread ?? Thread(
      id: "",
      name: "",
      cover: "",
      last: "",
      updated: DateTime.now()
    );
    super.initState();
  }

  Future save() {
    final services = ServiceContext.of(context).controller;
    if (widget.thread == null) {
      _thread.updated = DateTime.now();
      return services.firestore.collection("threads").doc().set(_thread.toJson());
    } else {
      _thread.updated = DateTime.now();
      return services.firestore.collection("threads").doc(_thread.id).update(_thread.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(PhosphorIcons.bold.x),
        ),
        title: Text(services.configs.value[widget.thread == null ? "new_thread_string" : "edit_thread_string"]),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(PhosphorIcons.bold.hash, color: Theme.of(context).colorScheme.onSecondaryContainer)
            ),
            title: Text(services.configs.value["thread_icon_string"]),
            onTap: (){},
          ),
          const SizedBox(height: 8),
          ListTile(
            title: TextFormField(
              initialValue: widget.thread?.name ?? "",
              maxLength: 32,
              decoration: InputDecoration(
                labelText: services.configs.value["thread_name_string"],
              ),
              onChanged: (value) => setState(() => _thread.name = value),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LargeButton(
        label: services.configs.value["save_string"],
        working: _working,
        viewPadding: true,
        onPressed: () {
          setState(() => _working = true);
          save().then((value) => Navigator.of(context).pop());
          setState(() => _working = false);
        },
      ),
    );
  }
}