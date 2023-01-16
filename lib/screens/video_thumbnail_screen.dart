import 'dart:developer';
import 'dart:io';

import 'package:crowdpad_task/constants/app_colors.dart';
import 'package:crowdpad_task/controllers/app_video_controller.dart';
import 'package:crowdpad_task/screens/player_screen.dart';
import 'package:crowdpad_task/screens/uploading_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rive/rive.dart';

import '../constants/custom_pull_to_refresh.dart';

class VideoThumbScreen extends StatefulWidget {
  VideoThumbScreen({Key? key}) : super(key: key);

  @override
  State<VideoThumbScreen> createState() => _VideoThumbScreenState();
}

class _VideoThumbScreenState extends State<VideoThumbScreen> {
  var appVideoController = Get.put(AppVideoController());

  ImagePicker picker = ImagePicker();
  XFile? _pickedVideo;
  File? _video;

  @override
  void initState() {
    appVideoController.getVideosAndThumb();
    super.initState();
  }

  Future pickVideo() async {
    try {
      _pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
      _video = File(_pickedVideo!.path);
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return UploadingScreen(
            pickedVideo: _video!,
          );
        },
      ));
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: const Text('CrowdPad Task'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Upload'),
        icon: const Icon(Icons.upload),
        onPressed: () {
          pickVideo();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => buildCustomPullToRefresh(
                child: appVideoController.videosThumbLinkList.isNotEmpty ||
                        appVideoController.isLoading.value
                    ? GridView.builder(
                        itemCount:
                            appVideoController.videosThumbLinkList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.6,
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12),
                        itemBuilder: (context, index) {
                          if (appVideoController.videosThumbLinkList[index] ==
                              '1') {
                            return Container();
                          } else {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlayerScreen(selectedIndex: index),
                                    ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  appVideoController.videosThumbLinkList[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                        child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ));
                                  },
                                ),
                              ),
                            );
                          }
                        })
                    : ListView(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3),
                          Icon(
                            FontAwesomeIcons.faceFrownOpen,
                            size: 56,
                            color: AppColors.buttonColor,
                          ),
                          Text(
                            '\nUh Oh! You got no videos.\n Upload now and enjoy scrolling.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                color: AppColors.buttonColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              )),
        ),
      ),
    );
  }
}
