import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef SuggestionsBuilder = FutureOr<Iterable<String>> Function(
  BuildContext context,
);

class FilterButton extends StatefulWidget {
  final ValueSetter<String> onFilterUpdated;
  final SuggestionsBuilder suggestionsBuilder;

  const FilterButton({
    super.key,
    required this.onFilterUpdated,
    required this.suggestionsBuilder,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<ValueSetter<String>>.has(
          'onFilterUpdated',
          onFilterUpdated,
        ),
      )
      ..add(
        ObjectFlagProperty<SuggestionsBuilder>.has(
          'suggestionsBuilder',
          suggestionsBuilder,
        ),
      );
  }
}

class _FilterButtonState extends State<FilterButton> {
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SearchAnchor(
        searchController: _searchController,
        viewOnSubmitted: _updateAndClose,
        viewTrailing: [
          CloseButton(
            onPressed: () => _updateAndClose(''),
          ),
        ],
        builder: (context, controller) => IconButton(
          onPressed: controller.openView,
          icon: const Icon(Icons.search),
        ),
        suggestionsBuilder: (context, controller) async {
          final suggestions = await widget.suggestionsBuilder(context);
          return [
            for (final suggestion in suggestions)
              if (suggestion.contains(controller.text))
                ListTile(
                  key: Key(suggestion),
                  title: Text(suggestion),
                  onTap: () => _updateAndClose(suggestion),
                ),
          ];
        },
      );

  void _updateAndClose(String text) {
    _searchController.closeView(text);
    widget.onFilterUpdated(text);
  }
}
