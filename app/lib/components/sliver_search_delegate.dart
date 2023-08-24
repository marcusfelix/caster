import 'dart:math';
import 'package:app/controllers/service_controller.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  SliverSearchDelegate({
    this.onSearch,
    this.onChange
  });

  final TextEditingController controller = TextEditingController();
  final Function? onSearch;
  final Function? onChange;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final services = ServiceContext.of(context).controller;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Container(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: services.configs.value["search_string"],
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
            border: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            suffixIcon: IconButton(
              onPressed: onSearch != null ? () => onSearch!(controller.text) : null,
              icon: Icon(
                PhosphorIcons.bold.magnifyingGlass,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
          onChanged: onChange != null ? (value) => onChange!(value) : null,
          onFieldSubmitted: onSearch != null ? (value) => onSearch!(value) : null,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        )
      ),
    );
  }

  @override
  double get maxExtent => max(48, 48);

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverSearchDelegate oldDelegate) {
    return false;
  }
}
