import 'dart:io';

import 'package:encrypted_video_player/viewmodels/video_listing_viewmodel.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoListingPage extends StatelessWidget {
  static const route = '/';

  @override
  Widget build(BuildContext context) {
    return Provider<VideoListingViewModel>(
      create: (context) => VideoListingViewModel(),
      child: Builder(
        builder: (context) {
          final viewModel = Provider.of<VideoListingViewModel>(context);
          return Scaffold(
            appBar: AppBar(
              title: Text('HSL Video Player'),
            ),
            body: SafeArea(
              child: Observer(
                builder: (context) => viewModel.qualityFetching
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Observer(
                              builder: (context) => viewModel.downloadedFile !=
                                      null
                                  ? _VideoPlayer(
                                      filePath: viewModel.downloadedFile.path,
                                    )
                                  : Center(child: Text("No Video Available")),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Select Quality to Download",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Expanded(
                            child: Observer(
                              builder: (context) => ListView.separated(
                                itemCount: viewModel.availableQuality.length,
                                separatorBuilder: (context, index) => Container(
                                  height: 1,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                itemBuilder: (context, index) => Observer(
                                  builder: (context) => ListTile(
                                    title:
                                        Text(viewModel.availableQuality[index]),
                                    trailing: viewModel
                                                .currentDownloadingIndex ==
                                            index
                                        ? SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(),
                                          )
                                        : null,
                                    onTap: viewModel.currentDownloadingIndex !=
                                            -1
                                        ? null
                                        : () =>
                                            viewModel.downloadSegments(index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String filePath;

  const _VideoPlayer({Key key, this.filePath}) : super(key: key);

  @override
  __VideoPlayerState createState() => __VideoPlayerState();
}

class __VideoPlayerState extends State<_VideoPlayer> {
  FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(
        File(widget.filePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(flickManager: flickManager);
  }
}
