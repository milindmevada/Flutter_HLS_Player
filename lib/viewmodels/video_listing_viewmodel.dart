import 'dart:io';

import 'package:dio/dio.dart';
import 'package:encrypted_video_player/app_constants.dart';
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

  Future<String> getVideoPath() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    final fileName = 'segment_0.ts';
    final pathComponents = [docDirectory.path, fileName];
    final localFilePath = p.joinAll(pathComponents);
    return localFilePath;
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
    await downloadAudioSegments();
    final segmentsResponse = await dio.get(
      masterPlaylist.mediaPlaylistUrls[index].toString(),
    );
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
        final pathComponents = [docDirectory.path, 'segments', fileName];
        final localFilePath = p.joinAll(
          pathComponents.toList().cast<String>(),
        );
        try {
          await dio.download(url, localFilePath);
        } catch (_) {}
      }
    }
    await createSegmentsConcatFile();
    await createVideoFile();
    currentDownloadingIndex = -1;
  }

  @action
  Future<void> downloadAudioSegments() async {
    if (masterPlaylist == null) {
      return;
    }
    final segmentsResponse = await dio.get(
      masterPlaylist.audios.first.url.toString(),
    );
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
        final pathComponents = [docDirectory.path, 'audio_segments', fileName];
        final localFilePath = p.joinAll(
          pathComponents.toList().cast<String>(),
        );
        try {
          await dio.download(url, localFilePath);
        } catch (_) {}
      }
    }
  }

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
  }

  Future<void> createSegmentsConcatFile() async {
    await createAudioSegmentsConcatFile();
    final directory = await getApplicationDocumentsDirectory();
    final List<String> pathList = [];
    //Video Segments
    final path = p.joinAll([directory.path, 'segments']);
    if (!Directory(path).existsSync()) {
      Directory(path).create(recursive: true);
    }
    final list = Directory(path).listSync();
    final totalSegments = list.length;
    List.generate(totalSegments, (index) {
      pathList.add("file '${directory.path}/segments/segment_$index.ts'");
    });

    final allTsString = pathList.join("\n").toString();
    final File file = File('${directory.path}/all.txt');
    await file.writeAsString(allTsString);
  }

  Future<void> createAudioSegmentsConcatFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<String> pathList = [];
    //Audio Segments
    final path = p.joinAll([directory.path, 'audio_segments']);
    if (!Directory(path).existsSync()) {
      Directory(path).create(recursive: true);
    }
    final list = Directory(path).listSync();
    final totalSegments = list.length;
    List.generate(totalSegments, (index) {
      pathList.add("file '${directory.path}/audio_segments/segment_$index.ts'");
    });

    final allTsString = pathList.join("\n").toString();
    final File file = File('${directory.path}/allAudio.txt');
    await file.writeAsString(allTsString);
  }

  @action
  Future<void> fetchDownloadedVideo() async {
    final directory = await getApplicationDocumentsDirectory();
    directory.listSync().forEach((element) {
      print(element.path);
    });
    final outPutFilePath = p.joinAll([directory.path, "final.mp4"]);
    if (File(outPutFilePath).existsSync()) {
      downloadedFile = File(outPutFilePath);
    }
  }
}
