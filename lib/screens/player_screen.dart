import 'package:crowdpad_task/constants/app_colors.dart';
import 'package:crowdpad_task/controllers/app_video_controller.dart';
import 'package:crowdpad_task/screens/video_thumbnail_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../constants/custom_pull_to_refresh.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({super.key, required this.selectedIndex});
  int selectedIndex;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AppVideoController appVideoController = Get.find();
  PageController? pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: widget.selectedIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            buildCustomPullToRefresh(
              child: PageView(
                controller: pageController,
                scrollDirection: Axis.vertical,
                allowImplicitScrolling: false,
                children: appVideoController.videosLinkList.map((videoUrl) {
                  int index = appVideoController.videosLinkList
                      .indexWhere((element) => element == videoUrl);
                  return VideoPlayerCustomWidget(
                    vidUrl: videoUrl,
                    vidThumbUrl: appVideoController.videosThumbLinkList[index],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VideoPlayerCustomWidget extends StatefulWidget {
  VideoPlayerCustomWidget(
      {super.key, required this.vidUrl, required this.vidThumbUrl});
  String vidUrl;
  String vidThumbUrl;

  @override
  State<VideoPlayerCustomWidget> createState() =>
      _VideoPlayerCustomWidgetState();
}

class _VideoPlayerCustomWidgetState extends State<VideoPlayerCustomWidget> {
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    initializePlayer(widget.vidUrl);
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void initializePlayer(String url) {
    _videoPlayerController = VideoPlayerController.network(url);
    _videoPlayerController!.initialize().then((value) {
      setState(() {});
      return _videoPlayerController!.play();
    });
    _videoPlayerController!.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _videoPlayerController!.value.isInitialized
            ? VideoPlayer(_videoPlayerController!)
            : SizedBox.expand(
                child: Image.network(
                widget.vidThumbUrl,
                fit: BoxFit.fill,
              )),
        SizedBox.expand(
          child: InkWell(
            onTap: () {
              setState(() {
                _videoPlayerController!.value.isPlaying
                    ? _videoPlayerController!.pause()
                    : _videoPlayerController!.play();
              });
            },
            child: _videoPlayerController!.value.isInitialized &&
                    !(_videoPlayerController!.value.isPlaying)
                ? const Icon(
                    Icons.play_arrow,
                    size: 86,
                  )
                : const SizedBox.expand(),
          ),
        )
      ],
    );
  }
}
