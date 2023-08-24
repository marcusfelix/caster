import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkPreview extends StatelessWidget {
  LinkPreview({required Key key, required this.data, required this.index}) : super(key: key);

  final int index;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxWidth: 414),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: InkWell(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.9 / 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: data["image"] != null ? Image.network(
                          data["image"],
                          fit: BoxFit.cover,
                        ) : Container(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.5)),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimaryContainer, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            index.toString(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.background),
                          ),
                        )
                      )
                    ],
                  )
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    runSpacing: 4,
                    children: [
                      Text(data["title"], maxLines: 2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                      Text(data["description"] ?? "", maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.5))),
                    ],
                  ),
                )
              ],
            ),
            onTap: () {
              launchUrlString(data["url"]);
            },
          ),
        ),
      ),
    );
  }
}
