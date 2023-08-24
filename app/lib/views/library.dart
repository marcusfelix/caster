import 'package:app/components/episode_tile.dart';
import 'package:app/components/sliver_search_delegate.dart';
import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:app/views/auth.dart';
import 'package:app/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with AutomaticKeepAliveClientMixin<Library> {
  String _search = "";
  

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          services.configs.value["app_name_string"],
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        centerTitle: Theme.of(context).appBarTheme.centerTitle,
        actions: [
          IconButton(
            onPressed: () {
              if (services.auth.currentUser != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => Settings(
                  user: services.auth.currentUser!,
                )));
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Auth(
                      withNavigator: true,
                    ),
                  ),
                );
              }
            },
            icon: Icon(PhosphorIcons.bold.userCircle, size: 28),
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: Container(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: services.configs.value["search_string"],
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  suffixIcon: IconButton(
                    onPressed: null,
                    icon: Icon(
                      PhosphorIcons.regular.magnifyingGlass,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() => _search = value),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
            ),
          ),
        )
      ),
      body: ValueListenableBuilder<List<Episode>>(
      valueListenable: services.episodes,
      builder: (context, List<Episode> episodes, _) {
        final filtered = episodes.where((episode) => _search != "" ? episode.title.toLowerCase().contains(_search.toLowerCase()) : true).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (BuildContext context, int index) {
            return EpisodeTile(
              key: ValueKey(filtered.elementAt(index).id),
              episode: filtered.elementAt(index)
            );
          }
        );
      })
    );
  }

  @override
  bool get wantKeepAlive => true;
}
