import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class AppVideoController extends GetxController {
  String path = 'videos/';
  UploadTask? uploadTask;
  var videosLinkList = <String>[].obs;
  var videosThumbLinkList = <String>[].obs;
  var isLoading = false.obs;

  var storageRef = FirebaseStorage.instance.ref();

  Future getVideosAndThumb() async {
    isLoading.value = true;
    videosLinkList.clear();
    videosThumbLinkList.clear();
    final allFiles = await storageRef.child('videos/').listAll();

    // for (int i = 0; i < numberOfVideosExists.value; i++) {
    //   videoListRef.add(await allFiles.items[i].getDownloadURL());
    // }

    List<Reference> videosRefList =
        allFiles.items.where((file) => file.name.contains('mp4')).toList();

    List<Reference> videosThumbRefLink =
        allFiles.items.where((file) => file.name.contains('jpeg')).toList();

    for (int i = 0; i < videosRefList.length; i++) {
      videosLinkList.add(await videosRefList[i].getDownloadURL());
    }

    for (int i = 0; i < videosThumbRefLink.length; i++) {
      videosThumbLinkList.add(await videosThumbRefLink[i].getDownloadURL());
    }
    isLoading.value = false;
  }

  Future uploadVideo(File pickedVideo) async {
    String videoPath = ('${path + (videosLinkList.length + 1).toString()}.mp4');
    //? Uploading to Google firebase storage
    final ref = storageRef.child(videoPath);
    uploadTask = ref.putFile(pickedVideo);
    videosLinkList.add('1');
  }

  Future uploadVideoThumbnail(File pickedVideoThumbnail) async {
    String videoThumbnailPath =
        ('${path + (videosThumbLinkList.length + 1).toString()}.jpeg');
    //? Uploading to Google firebase storage
    final ref = storageRef.child(videoThumbnailPath);
    ref.putFile(pickedVideoThumbnail);
    videosThumbLinkList.add('1');
  }
}
