import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:horaz/models/StoryModel.dart';
import 'package:horaz/screens/ChatScreen/chat_export.dart';
import 'package:horaz/screens/StoryScreen/StoryController.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as type;
import 'package:horaz/utils/CameraUtils/CustomCamera.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class StoryScreenWidget {
  static AppBar buildAppBarSection() {
    return AppBar(
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Row(
          children: [
            CommonWidget.buildCustomText(
              text: 'Story',
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.searchScreen);
              },
              child: AppUtils.svgToIcon(
                iconPath: 'search-icons.svg',
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildGridEmptyStorySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CommonWidget.buildCustomText(
          text:
              'You have not upload any story yet 😭\nClick in here to upload story',
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  static Widget buildMyStoryEmptySection() {
    return Align(
      alignment: Alignment.center,
      child: CommonWidget.buildCustomText(
        text: 'You have not upload\nany story yet 🥲',
        margin: const EdgeInsets.only(left: 10, top: 24, bottom: 20),
        textAlign: TextAlign.center,
        textStyle: const TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }

  static Widget buildMyStorySection() {
    final controller = Get.find<StoryController>();
    return SizedBox(
      height: 118,
      child: Obx(() {
        if (controller.myStories.isEmpty) {
          return buildMyStoryEmptySection();
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CommonWidget.buildGradientAddButton(
                  margin: const EdgeInsets.only(left: 20),
                  onTap: () {
                    Get.to(() => const CustomCamera());
                  },
                  height: double.infinity,
                  width: 44,
                  radius: 16,
                  iconSize: 16,
                ),
                const SizedBox(width: 8),
                ListView.separated(
                  itemCount: controller.myStories.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final storyModel = controller.myStories[i];
                    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        storyModel.createdAt!);
                    String formattedTime =
                        DateFormat('h:mm a').format(dateTime);
                    return _buildStoryViewTile(
                      closeButton: () {},
                      time: formattedTime,
                      storyItem: storyModel.story,
                      onTap: () {
                        controller.navigateToFullStoryScreen(
                          context: context,
                          storyModel: controller.myStories,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  static Widget buildStoryGridView() {
    final controller = Get.find<StoryController>();
    return Obx(() {
      if (controller.otherUserStories.isEmpty) {
        return buildGridEmptyStorySection();
      } else {
        return GridView.builder(
          itemCount: controller.uniqueStories.length,
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 250,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, i) {
            return _buildStoryGridTile(
              story: controller.uniqueStories[i],
              onTap: () {
                // Get the user ID of the selected story
                final selectedUserId = controller.uniqueStories[i].userId;
                // Filter the list of stories to include only stories of the selected user
                final userStories = controller.otherUserStories
                    .where((story) => story.userId == selectedUserId)
                    .toList();
                controller.navigateToFullStoryScreen(
                  context: context,
                  storyModel: userStories,
                );
              },
            );
          },
        );
      }
    });
  }

  /// Build Empty Section Here
  static Widget _buildStoryGridTile({
    required StoryModel story,
    required Function onTap,
  }) {
    final storyModel = story;
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(storyModel.createdAt!);
    String formattedTime = DateFormat('h:mm a').format(dateTime);

    return InkWell(
      onTap: () => onTap(),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: CachedNetworkImage(
                    imageUrl: story.story.media == StoryMediaType.video
                        ? story.story.videoThumbnail.toString()
                        : story.story.storyUrl ?? '',
                    // Use user image from story data
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CommonWidget.buildCircleAvatar(
                    size: 18,
                    imageUrl: story.userImage,
                  ),
                  const SizedBox(width: 10),
                  CommonWidget.buildCustomText(
                    text: story.userName, // Use user name from story data
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              )
            ],
          ),
          Positioned(
            top: 14,
            right: 20,
            child: Text(
              formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget _buildStoryViewTile({
    required Function onTap,
    required Function closeButton,
    required String time,
    required StoryItem storyItem,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(2),
        color: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: 118,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                image: storyItem.storyUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          storyItem.media == StoryMediaType.video
                              ? storyItem.videoThumbnail.toString()
                              : storyItem.storyUrl ?? '',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              child: InkWell(
                onTap: () => closeButton(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 8,
                    backgroundColor: Color(0xff857FB4),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 20,
              child: Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
