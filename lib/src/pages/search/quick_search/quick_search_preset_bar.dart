import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/config/ui_config.dart';
import 'package:jhentai/src/model/search_config.dart';
import 'package:jhentai/src/service/quick_search_service.dart';
import 'package:jhentai/src/utils/search_util.dart';

/// Saved search presets, laid out right below the search field so that one tap applies one.
class QuickSearchPresetBar extends StatelessWidget {
  const QuickSearchPresetBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuickSearchService>(
      builder: (_) {
        List<MapEntry<String, SearchConfig>> entries = quickSearchService.quickSearchConfigs.entries.toList();

        return SizedBox(
          height: UIConfig.quickSearchPresetBarHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: entries.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, int index) {
              if (index == 0) {
                return Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: Text('saveCurrentSearch'.tr, style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: handleAddQuickSearch,
                  ),
                );
              }

              MapEntry<String, SearchConfig> entry = entries[index - 1];

              return Center(
                child: GestureDetector(
                  onLongPress: () => quickSearchService.handleUpdateQuickSearch(entry),
                  child: ActionChip(
                    label: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    labelStyle: TextStyle(color: UIConfig.ehTagTextColor(context)),
                    backgroundColor: UIConfig.ehTagBackGroundColor(context),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => newSearch(rewriteSearchConfig: entry.value),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
