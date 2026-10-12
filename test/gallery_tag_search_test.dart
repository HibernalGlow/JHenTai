import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhentai/src/database/database.dart';
import 'package:jhentai/src/model/gallery_tag.dart';
import 'package:jhentai/src/utils/search_util.dart';
import 'package:jhentai/src/widget/eh_gallery_waterflow_card.dart';

GalleryTag _tag(String namespace, String key) => GalleryTag(tagData: TagData(namespace: namespace, key: key));

void main() {
  group('tagSearchKeyword', () {
    test('builds the same keyword form the details page uses', () {
      expect(tagSearchKeyword(_tag('artist', 'foo')), 'artist:"foo\$"');
    });

    test('keeps the dollar sign that makes the match exact', () {
      expect(tagSearchKeyword(_tag('tag', 'school_uniform')), contains(r'$"'));
    });
  });

  group('tags rendered on a gallery card', () {
    testWidgets('a tap on a card tag reaches the tag handler', (tester) async {
      GalleryTag? tapped;
      final tag = _tag('artist', 'foo');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: WaterFallFlowTag(galleryTag: tag, onTap: (t) => tapped = t)),
          ),
        ),
      );

      await tester.tap(find.text('foo'));
      await tester.pump();

      expect(tapped, same(tag));
    });

    testWidgets('a tap on a card tag does not fall through to the card itself', (tester) async {
      int cardTaps = 0;
      int tagTaps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => cardTaps++,
                child: WaterFallFlowTag(galleryTag: _tag('artist', 'foo'), onTap: (_) => tagTaps++),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('foo'));
      await tester.pump();

      expect(tagTaps, 1);
      expect(cardTaps, 0);
    });

    testWidgets('a tap on the card next to the tag still opens the gallery', (tester) async {
      int cardTaps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => cardTaps++,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WaterFallFlowTag(galleryTag: _tag('artist', 'foo'), onTap: (_) {}),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(tester.getBottomRight(find.text('foo')) + const Offset(0, 20));
      await tester.pump();

      expect(cardTaps, 1);
    });
  });
}
