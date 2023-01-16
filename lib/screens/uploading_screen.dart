import 'dart:io';
import 'dart:typed_data';

import 'package:crowdpad_task/controllers/app_video_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class UploadingScreen extends StatefulWidget {
  UploadingScreen({super.key, required this.pickedVideo});
  File pickedVideo;

  @override
  State<UploadingScreen> createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen> {
  AppVideoController appVideoController = Get.find();
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.pickedVideo)
      ..initialize().then((value) {
        _videoPlayerController.play();
        setState(() {});
      });
    _videoPlayerController.setLooping(true);

    makeVideoThumbnail();
    appVideoController.uploadVideo(widget.pickedVideo);
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future makeVideoThumbnail() async {
    String? videoThumbnail = await VideoThumbnail.thumbnailFile(
      video: widget.pickedVideo.path, imageFormat: ImageFormat.JPEG,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      maxWidth: 300,
      quality: 100,
    );
    File videoThumbnailFile = File(videoThumbnail!);
    appVideoController.uploadVideoThumbnail(videoThumbnailFile);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Uploading...'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !_videoPlayerController.value.isInitialized
                  ? Container()
                  : Expanded(
                      child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: VideoPlayer(
                          _videoPlayerController,
                        ),
                      ),
                    )),
              progressBar(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget progressBar() => StreamBuilder<TaskSnapshot>(
        stream: appVideoController.uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            double progress = data!.bytesTransferred / data.totalBytes;
            if (progress == 1) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });
              return Container();
            } else {
              return SizedBox(
                height: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey,
                      color: Colors.green,
                    ),
                    Center(
                      child: Text(
                        '${(100 * progress).roundToDouble()}%}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            return const SizedBox(height: 50);
          }
        },
      );
}
