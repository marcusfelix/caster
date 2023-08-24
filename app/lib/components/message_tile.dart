

import 'package:app/components/link_preview.dart';
import 'package:app/includes/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTile extends StatelessWidget {
  MessageTile({required Key key, required this.message}) : super(key: key);

  final Message message;

  // RegExp for detecting links in messages http or https
  final RegExp exp = RegExp(r"(http|https)://[^\s]+");

  @override
  Widget build(BuildContext context) {
    
    return Material(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      image: message.user.photo != null ? DecorationImage(
                        image: NetworkImage(message.user.photo!),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    alignment: Alignment.center,
                    child: message.user.photo != null ? null : Text(
                      message.user.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14, 
                        color: Theme.of(context).colorScheme.secondary, 
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Builder(builder: (BuildContext context) {
                  List<String> strings = [
                    message.body
                  ];
                  
                  final Iterable<RegExpMatch> matches = exp.allMatches(message.body);

                  if (matches.isNotEmpty) {
                    strings = [];
                    int last = 0;
                    int index = 1;
                    matches.forEach((match) {
                      final String url = message.body.substring(match.start, match.end);
                      strings.add(message.body.substring(last, match.start));
                      strings.add(index.toString());
                      strings.add(url);
                      last = match.end;
                      index++;
                    });
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              message.user.name,
                              style: TextStyle(
                                fontSize: 14, 
                                color: Theme.of(context).colorScheme.primary, 
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                DateFormat.yMMMd().format(message.created),
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: strings.map((span) => isNumeric(span) ? WidgetSpan(
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.onBackground),
                              child: Text(
                                span,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.background, 
                                  fontSize: 8, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ) : isLink(span) ? WidgetSpan(
                            child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              child: Text(truncate(span), style: TextStyle(color: isLink(span) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground, fontSize: 16)),
                              onTap: () {
                                launchUrl(Uri.parse(span));
                              },
                            ),
                          )
                        ) : TextSpan(
                          text: span, 
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground, 
                            fontSize: 16
                          )
                        )).toList()),
                      ),
                      ...(message.metadata.map((data) => LinkPreview(
                        key: Key(data["url"] ?? ""),
                        data: Map<String, dynamic>.from(data),
                        index: message.metadata.indexWhere((e) => e["url"] == data["url"]) + 1,
                      )).toList())
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLink(String str) => str.startsWith("http") || str.startsWith("mailto");

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  String truncate(String text, {length = 24, omission = '...'}) {
    return Uri.parse(text).host.replaceAll("www.", "");
  }
}
