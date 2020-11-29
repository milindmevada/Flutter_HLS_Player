// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_listing_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoListingViewModel on _VideoListingViewModel, Store {
  Computed<ObservableList<String>> _$availableQualityComputed;

  @override
  ObservableList<String> get availableQuality => (_$availableQualityComputed ??=
          Computed<ObservableList<String>>(() => super.availableQuality,
              name: '_VideoListingViewModel.availableQuality'))
      .value;

  final _$isVideoDownloadedAtom =
      Atom(name: '_VideoListingViewModel.isVideoDownloaded');

  @override
  bool get isVideoDownloaded {
    _$isVideoDownloadedAtom.reportRead();
    return super.isVideoDownloaded;
  }

  @override
  set isVideoDownloaded(bool value) {
    _$isVideoDownloadedAtom.reportWrite(value, super.isVideoDownloaded, () {
      super.isVideoDownloaded = value;
    });
  }

  final _$videoPathAtom = Atom(name: '_VideoListingViewModel.videoPath');

  @override
  String get videoPath {
    _$videoPathAtom.reportRead();
    return super.videoPath;
  }

  @override
  set videoPath(String value) {
    _$videoPathAtom.reportWrite(value, super.videoPath, () {
      super.videoPath = value;
    });
  }

  final _$masterPlaylistAtom =
      Atom(name: '_VideoListingViewModel.masterPlaylist');

  @override
  HlsMasterPlaylist get masterPlaylist {
    _$masterPlaylistAtom.reportRead();
    return super.masterPlaylist;
  }

  @override
  set masterPlaylist(HlsMasterPlaylist value) {
    _$masterPlaylistAtom.reportWrite(value, super.masterPlaylist, () {
      super.masterPlaylist = value;
    });
  }

  final _$qualityFetchingAtom =
      Atom(name: '_VideoListingViewModel.qualityFetching');

  @override
  bool get qualityFetching {
    _$qualityFetchingAtom.reportRead();
    return super.qualityFetching;
  }

  @override
  set qualityFetching(bool value) {
    _$qualityFetchingAtom.reportWrite(value, super.qualityFetching, () {
      super.qualityFetching = value;
    });
  }

  final _$currentDownloadingIndexAtom =
      Atom(name: '_VideoListingViewModel.currentDownloadingIndex');

  @override
  int get currentDownloadingIndex {
    _$currentDownloadingIndexAtom.reportRead();
    return super.currentDownloadingIndex;
  }

  @override
  set currentDownloadingIndex(int value) {
    _$currentDownloadingIndexAtom
        .reportWrite(value, super.currentDownloadingIndex, () {
      super.currentDownloadingIndex = value;
    });
  }

  final _$downloadedFileAtom =
      Atom(name: '_VideoListingViewModel.downloadedFile');

  @override
  File get downloadedFile {
    _$downloadedFileAtom.reportRead();
    return super.downloadedFile;
  }

  @override
  set downloadedFile(File value) {
    _$downloadedFileAtom.reportWrite(value, super.downloadedFile, () {
      super.downloadedFile = value;
    });
  }

  final _$getQualitiesAsyncAction =
      AsyncAction('_VideoListingViewModel.getQualities');

  @override
  Future<void> getQualities() {
    return _$getQualitiesAsyncAction.run(() => super.getQualities());
  }

  final _$downloadSegmentsAsyncAction =
      AsyncAction('_VideoListingViewModel.downloadSegments');

  @override
  Future<void> downloadSegments(int index) {
    return _$downloadSegmentsAsyncAction
        .run(() => super.downloadSegments(index));
  }

  final _$downloadAudioSegmentsAsyncAction =
      AsyncAction('_VideoListingViewModel.downloadAudioSegments');

  @override
  Future<void> downloadAudioSegments() {
    return _$downloadAudioSegmentsAsyncAction
        .run(() => super.downloadAudioSegments());
  }

  final _$fetchDownloadedVideoAsyncAction =
      AsyncAction('_VideoListingViewModel.fetchDownloadedVideo');

  @override
  Future<void> fetchDownloadedVideo() {
    return _$fetchDownloadedVideoAsyncAction
        .run(() => super.fetchDownloadedVideo());
  }

  @override
  String toString() {
    return '''
isVideoDownloaded: ${isVideoDownloaded},
videoPath: ${videoPath},
masterPlaylist: ${masterPlaylist},
qualityFetching: ${qualityFetching},
currentDownloadingIndex: ${currentDownloadingIndex},
downloadedFile: ${downloadedFile},
availableQuality: ${availableQuality}
    ''';
  }
}
