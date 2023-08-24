import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:app/views/threads_edit.dart';
import 'package:app/views/thread_view.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Threads extends StatelessWidget {
  Threads({
    Key? key
  }) : super(key: key);

  final ValueNotifier<String> search = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(services.configs.value["threads_string"]),
      ),
      body: ValueListenableBuilder(
        valueListenable: search,
        builder: (context, search, _) {
          return StreamBuilder(
            stream: services.firestore.collection("threads").snapshots().transform(channelsTransformer),
            builder: (context, data) {
              final filtered = (data.data ?? []).where((thread) => thread.name.toLowerCase().contains(search.toLowerCase())).toList();
              
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Icon(PhosphorIcons.regular.hash, color: Theme.of(context).colorScheme.onSecondaryContainer)
                    ),
                    title: Text(
                      filtered.elementAt(index).name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    subtitle: Text(
                      filtered.elementAt(index).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(
                        thread: filtered.elementAt(index),
                      )));
                    },
                  );
                },
              );
            }
          );
        }
      ),
      floatingActionButton: services.auth.currentUser != null ? FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.5,
              margin: MediaQuery.of(context).viewInsets,
              child: const ThreadEdit()
            )
          );
        },
        child: Icon(
          PhosphorIcons.regular.plus,
        ),
      ) : null,
    );
    
    // return Scaffold(
    //   body: CustomScrollView(
    //     slivers: [
    //       SliverAppBar(
    //         pinned: true,
    //         floating: true,
    //         leading: null,
    //         automaticallyImplyLeading: false,
    //         title: Text(
    //           services.configs.value["threads_string"],
    //           style: Theme.of(context).appBarTheme.titleTextStyle,
    //         ),
    //         iconTheme: Theme.of(context).appBarTheme.iconTheme,
    //         centerTitle: Theme.of(context).appBarTheme.centerTitle,
    //         backgroundColor: Theme.of(context).colorScheme.primary,
    //       ),
    //       SliverPersistentHeader(
    //         delegate: SliverSearchDelegate(
    //           onSearch: (value) {
    //             search.value = value;
    //             search.notifyListeners();
    //           },
    //         ), 
    //         pinned: true
    //       ),
    //       const SliverToBoxAdapter(
    //         child: SizedBox(height: 16),
    //       ),
    //       ValueListenableBuilder(
    //         valueListenable: search,
    //         builder: (context, search, _) {
    //           return StreamBuilder<List<Thread>>(
    //             stream: services.database.ref("threads").orderByChild("updated").limitToFirst(services.configs.value["thread_limit_number"]).onValue.transform(channelsTransformer),
    //             builder: (context, threads) {
    //               final filtered = (threads.data ?? []).where((thread) => thread.name.toLowerCase().contains(search.toLowerCase())).toList();

    //               return SliverList(delegate: SliverChildBuilderDelegate(
    //                 (BuildContext context, int index) {
    //                   return ListTile(
    //                     leading: CircleAvatar(
    //                       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    //                       child: Icon(PhosphorIcons.bold.hash, color: Theme.of(context).colorScheme.onSecondaryContainer)
    //                     ),
    //                     title: Text(
    //                       filtered.elementAt(index).name,
    //                       style: const TextStyle(
    //                         fontWeight: FontWeight.w600
    //                       ),
    //                     ),
    //                     subtitle: Text(
    //                       filtered.elementAt(index).last,
    //                       maxLines: 1,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                     onTap: (){
    //                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(
    //                         thread: filtered.elementAt(index),
    //                       )));
    //                     },
    //                   );
    //                 },
    //                 childCount: filtered.length,
    //               ));
    //             }
    //           );
    //         }
    //       ),
    //       const SliverToBoxAdapter(
    //         child: SizedBox(height: 68),
    //       ),
    //     ],
    //   ),
    //   floatingActionButton: services.auth.currentUser != null ? FloatingActionButton(
    //     onPressed: () {
    //       showModalBottomSheet(
    //         context: context, 
    //         isScrollControlled: true,
    //         builder: (context) => Container(
    //           height: MediaQuery.of(context).size.height * 0.5,
    //           margin: MediaQuery.of(context).viewInsets,
    //           child: const ThreadEdit()
    //         )
    //       );
    //     },
    //     child: Icon(
    //       PhosphorIcons.bold.plus,
    //     ),
    //   ) : null,
    // );
  }
}