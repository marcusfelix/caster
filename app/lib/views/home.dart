
import 'package:app/controllers/service_controller.dart';
import 'package:app/views/threads.dart';
import 'package:app/views/current_playing.dart';
import 'package:app/views/library.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Home extends StatefulWidget {
  const Home({
    super.key
  });


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return Scaffold(
      key: services.scaffoldKey,
      body: TabBarView(
        controller: controller, 
        children: [
          const Library(
            key: ValueKey("library"),
          ),
          const CurrentPlaying(
            key: ValueKey("current-playing"),
          ),
          Threads(
            key: const ValueKey("threads"),
          ),
        ]
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.onBackground,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom), 
        child: TabBar(
          controller: controller,
          indicator: const BoxDecoration(
            color: Colors.transparent
          ), 
          labelColor: Theme.of(context).colorScheme.background, 
          unselectedLabelColor: Theme.of(context).colorScheme.background.withOpacity(0.3), 
          tabs: [
            Tab(
              icon: Icon(PhosphorIcons.bold.list),
            ),
            Tab(
              icon: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer, 
                  borderRadius: const BorderRadius.all(Radius.circular(20)
                )),
                child: Icon(
                  PhosphorIcons.fill.play,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 20,
                ),
              )
            ),
            Tab(
              icon: Icon(PhosphorIcons.bold.chatCentered),
            )
          ]
        ),
      ),
    );
  }
}