import 'dart:io';

import 'package:dio/dio.dart';
import 'package:encrypted_video_player/app_constants.dart';
import 'package:encrypted_video_player/service/encryption_helper.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'video_listing_viewmodel.g.dart';

// ignore_for_file: use_setters_to_change_properties

class VideoListingViewModel = _VideoListingViewModel
    with _$VideoListingViewModel;

abstract class _VideoListingViewModel with Store {
  final dio = Dio();
  final encryptionHelper = EncryptionHelper();
  Uri playlistUri = Uri.parse(AppConstants.assetUrl);

  _VideoListingViewModel() {
    fetchDownloadedVideo();
    getQualities();
  }

  @observable
  bool isVideoDownloaded = false;

  @observable
  String videoPath;

  @observable
  HlsMasterPlaylist masterPlaylist;

  @observable
  bool qualityFetching = false;

  @observable
  int currentDownloadingIndex = -1;

  @observable
  File downloadedFile;

  @computed
  ObservableList<String> get availableQuality {
    if (masterPlaylist == null) {
      return ObservableList.of([]);
    }
    final qualities = masterPlaylist.variants
        .map((e) => "${e.format.width}*${e.format.height}")
        .toList();
    return ObservableList.of(qualities);
  }

  @action
  Future<void> getQualities() async {
    try {
      qualityFetching = true;
      final response = await dio.get(AppConstants.assetUrl);
      final playlistUri = Uri.parse(AppConstants.assetUrl);
      final playList = await HlsPlaylistParser.create().parseString(
        playlistUri,
        (response.data as String),
      );
      if (playList is HlsMasterPlaylist) {
        masterPlaylist = playList;
      }
    } catch (_) {} finally {
      qualityFetching = false;
    }
  }

  @action
  Future<void> downloadSegments(int index) async {
    if (masterPlaylist == null) {
      return;
    }
    currentDownloadingIndex = index;
    await downloadAllSegments(
      url: masterPlaylist.mediaPlaylistUrls[index].toString(),
      segment: 'segment',
    );
    await downloadAllSegments(
      url: masterPlaylist.audios.first.url.toString(),
      segment: 'audio_segment',
    );
    await createSegmentsConcatFile(
      segment: 'segment',
      fileName: 'all.txt',
    );
    await createSegmentsConcatFile(
      segment: 'audio_segment',
      fileName: 'allAudio.txt',
    );
    await createVideoFile();
    currentDownloadingIndex = -1;
  }

  @action
  Future<void> downloadAllSegments({String url, String segment}) async {
    final segmentsResponse = await dio.get(url);
    final segmentsData = await HlsPlaylistParser.create().parseString(
      playlistUri,
      segmentsResponse.data as String,
    );
    if (segmentsData is HlsMediaPlaylist) {
      for (final element in segmentsData.segments) {
        final uri = Uri.parse(element.url);
        final pathSegment = List.from(uri.pathSegments);
        pathSegment.removeWhere((element) => element.contains(".."));
        final url =
            "https://bitdash-a.akamaihd.net/content/MI201109210084_1/${pathSegment.join("/")}";
        final docDirectory = await getApplicationDocumentsDirectory();
        final fileName = pathSegment.last;
        final pathComponents = [docDirectory.path, segment, fileName];
        final localFilePath = p.joinAll(
          pathComponents.toList().cast<String>(),
        );
        try {
          await dio.download(url, localFilePath);
        } catch (_) {}
      }
    }
  }

  @action
  Future<void> createVideoFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final allFilePath = p.joinAll([directory.path, "all.txt"]);
    final audioAllFilePath = p.joinAll([directory.path, "allAudio.txt"]);
    final outPutFilePath = p.joinAll([directory.path, "output.mp4"]);
    final audioOutPutFilePath = p.joinAll([directory.path, "audio.wav"]);
    final finalVideoPath = p.joinAll([directory.path, "final.mp4"]);
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    await _flutterFFmpeg.execute(
      '-f concat -safe 0 -i $allFilePath -c:v libx264 -c:a copy $outPutFilePath',
    );
    await _flutterFFmpeg.execute(
      '-f concat -safe 0 -i $audioAllFilePath -c:v libx264 -c:a copy $audioOutPutFilePath',
    );
    await _flutterFFmpeg.execute(
      '-i $audioOutPutFilePath -i $outPutFilePath $finalVideoPath',
    );
    downloadedFile = File(finalVideoPath);
    await encryptionHelper.encryptFile();
    await File(finalVideoPath).delete();
    await File(outPutFilePath).delete();
    await File(audioOutPutFilePath).delete();
    await File(allFilePath).delete();
    await File(audioAllFilePath).delete();
    await File(p.joinAll([directory.path, "audio_segment"])).delete(
      recursive: true,
    );
    await File(p.joinAll([directory.path, "segment"])).delete(
      recursive: true,
    );
  }

  Future<void> createSegmentsConcatFile({
    String segment,
    String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final List<String> pathList = [];

    final path = p.joinAll([directory.path, segment]);
    if (!Directory(path).existsSync()) {
      Directory(path).create(recursive: true);
    }
    final list = Directory(path).listSync();
    final totalSegments = list.length;
    List.generate(totalSegments, (index) {
      pathList.add("file '${directory.path}/$segment/segment_$index.ts'");
    });

    final allTsString = pathList.join("\n").toString();
    final File file = File('${directory.path}/$fileName');
    await file.writeAsString(allTsString);
  }

  @action
  Future<void> fetchDownloadedVideo() async {
    final directory = await getApplicationDocumentsDirectory();
    directory.listSync().forEach((element) {
      print(element.path);
    });
    final outPutFilePath = p.joinAll([directory.path, "finalenc.aes"]);
    if (File(outPutFilePath).existsSync()) {
      await encryptionHelper.decryptFile();
      final decryptedFile = p.joinAll([directory.path, "final.mp4"]);
      if (File(decryptedFile).existsSync()) {
        downloadedFile = File(decryptedFile);
        Future.delayed(Duration(seconds: 2)).then(
          (value) => File(decryptedFile).delete(),
        );
      }
    }
  }
}
