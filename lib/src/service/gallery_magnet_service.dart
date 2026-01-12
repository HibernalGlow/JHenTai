import 'dart:async';
import 'package:get/get.dart';
import 'package:jhentai/src/model/gallery.dart';
import 'package:jhentai/src/model/gallery_torrent.dart';
import 'package:jhentai/src/network/eh_request.dart';
import 'package:jhentai/src/utils/eh_spider_parser.dart';
import 'package:jhentai/src/service/log.dart';
import 'package:jhentai/src/service/jh_service.dart';

GalleryMagnetService galleryMagnetService = GalleryMagnetService();

class GalleryMagnetService with JHLifeCircleBeanErrorCatch implements JHLifeCircleBean {
  final RxMap<int, String> magnetCache = <int, String>{}.obs;
  final RxSet<int> fetchingGids = <int>{}.obs;
  
  final _fetchQueue = <Gallery>[];
  bool _isProcessingQueue = false;

  @override
  Future<void> doInitBean() async {}

  @override
  Future<void> doAfterBeanReady() async {}

  String? getMagnet(int gid) => magnetCache[gid];

  bool isFetching(int gid) => fetchingGids.contains(gid);

  void fetchAllMagnets(List<Gallery> galleries) {
    for (var gallery in galleries) {
      if (!magnetCache.containsKey(gallery.gid) && !fetchingGids.contains(gallery.gid)) {
        if (!_fetchQueue.any((g) => g.gid == gallery.gid)) {
          _fetchQueue.add(gallery);
        }
      }
    }
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _fetchQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_fetchQueue.isNotEmpty) {
      final gallery = _fetchQueue.removeAt(0);
      if (magnetCache.containsKey(gallery.gid)) continue;

      fetchingGids.add(gallery.gid);
      try {
        final List<GalleryTorrent> torrents = await ehRequest.requestTorrentPage<List<GalleryTorrent>>(
          gallery.gid,
          gallery.token,
          EHSpiderParser.torrentPage2GalleryTorrent,
        );
        
        if (torrents.isNotEmpty) {
          final torrent = torrents.firstWhere((t) => !t.outdated, orElse: () => torrents.first);
          magnetCache[gallery.gid] = torrent.magnetUrl;
        } else {
          // Store empty string to indicate no torrents found
          magnetCache[gallery.gid] = '';
        }
      } catch (e) {
        log.error('Failed to fetch magnet for ${gallery.gid}', e);
        // Maybe retry later? For now just skip
      } finally {
        fetchingGids.remove(gallery.gid);
      }
      
      // Wait a bit to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isProcessingQueue = false;
  }
}
