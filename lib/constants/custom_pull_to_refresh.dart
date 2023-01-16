import 'package:crowdpad_task/constants/app_colors.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../controllers/app_video_controller.dart';

Widget buildCustomPullToRefresh({required Widget child}) {
  AppVideoController appVideoController = Get.find();
  double _offsetArmedValue = 220;
  return CustomRefreshIndicator(
    onRefresh: () => appVideoController.getVideosAndThumb(),
    offsetToArmed: _offsetArmedValue,
    builder: (context, child, controller) => AnimatedBuilder(
        animation: controller,
        child: child,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                color: AppColors.primaryColor,
              ),
              SizedBox(
                width: double.infinity,
                height: _offsetArmedValue * controller.value,
                child: const RiveAnimation.network(
                  'https://public.rive.app/community/runtime-files/809-1634-rocket-demo.riv',
                ),
              ),
              Transform.translate(
                offset: Offset(
                  0.0,
                  _offsetArmedValue * controller.value,
                ),
                child: child,
              )
            ],
          );
        }),
    child: child,
  );
}
