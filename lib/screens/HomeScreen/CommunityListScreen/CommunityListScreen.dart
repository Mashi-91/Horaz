  import 'package:avatar_stack/avatar_stack.dart';
  import 'package:avatar_stack/positions.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/widgets.dart';
  import 'package:get/get.dart';
  import 'package:horaz/config/AppColors.dart';
  import 'package:horaz/config/AppRoutes.dart';
  import 'package:horaz/constants/AppConst.dart';
  import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
  import 'package:horaz/screens/HomeScreen/CommunityListScreen/CommunityListController.dart';
  import 'package:horaz/screens/HomeScreen/HomeScreenWidget.dart';
  import 'package:horaz/utils/AppUtils.dart';
  import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/widgets/CommonWidgets.dart';

  class CommunityListScreen extends GetView<CommunityListController> {
    const CommunityListScreen({super.key});

    @override
    Widget build(BuildContext context) {
      final List<types.Room> data = Get.arguments;
      return Scaffold(
        appBar: HomeScreenWidget.buildAppBarSection(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 14),
              width: Get.width,
              height: 48,
              child: GetBuilder<CommunityListController>(
                builder: (_) {
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConst.tagNames.length,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    separatorBuilder: (context, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final iconNames = AppConst.iconNames[i];
                      final tagTitles = AppConst.tagNames[i];
                      final tagColors = AppConst.tagColors[i];
                      return AddCommunityWidget.buildTagsContainer(
                        iconName: iconNames,
                        tagTitle: tagTitles,
                        tagColor: tagColors,
                        isSelected: controller.selectedTags.contains(tagTitles),
                        onSelect: (val) => controller.selectTag(tagTitles),
                      );
                    },
                  );
                }
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.darkPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CommonWidget.buildCustomText(
                    text: "Community List",
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPurple,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GetBuilder<CommunityListController>(
                builder: (_) {
                  final filteredData = _filterDataByTags(data, controller.selectedTags);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final types.Room room = filteredData[index];
                      final tagColor =
                          AppUtils.getColorBasedOnTag(room.metadata!['Tag']);
                      final dynamic lastMsg = room.lastMessages?.first ?? '';
                      String lastMsgUserName = '';
                      if (lastMsg != '') {
                        lastMsgUserName = lastMsg.author.firstName ?? '';
                      }
                      return _buildCommunityListTile(
                        tagColor: tagColor,
                        imageUrl: room.imageUrl.toString(),
                        lastMsg: HomeScreenWidget.buildSubTitle(lastMsg),
                        lastMsgUserName: lastMsgUserName,
                        title: room.name.toString(),
                        users: room.users
                            .map((user) => NetworkImage(user.imageUrl.toString()))
                            .toList(),
                        onTap: () {
                          Get.toNamed(AppRoutes.chatScreen, arguments: room);
                        },
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildCommunityListTile({
      required String imageUrl,
      required Color tagColor,
      required String title,
      required List<ImageProvider<Object>> users,
      String? lastMsgUserName,
      required Widget lastMsg,
      required Function onTap,
    }) {
      return InkWell(
        onTap: () => onTap(),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(vertical: 12).copyWith(left: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: AppColors.whiteColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                width: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 3,
                      width: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: tagColor,
                      ),
                    ),
                    CommonWidget.buildCustomText(
                      text: title,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (lastMsgUserName != null || lastMsgUserName != '')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonWidget.buildCustomText(
                            text: lastMsgUserName!,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                              fontSize: 12,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SizedBox(
                              child: lastMsg,
                            ),
                          )
                        ],
                      ),
                    const SizedBox(height: 10),
                    AvatarStack(
                      width: 80,
                      height: 30,
                      borderWidth: 1.2,
                      infoWidgetBuilder: (i) {
                        return CircleAvatar(
                          backgroundColor: const Color(0xff1A1167),
                          child: CommonWidget.buildCustomText(
                            text: "+$i",
                            textStyle: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor),
                          ),
                        );
                      },
                      settings: RestrictedPositions(
                        maxCoverage: 0.2,
                        minCoverage: 0.1,
                        laying: StackLaying.first,
                      ),
                      avatars: users,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<types.Room> _filterDataByTags(
        List<types.Room> data, List<String> selectedTags) {
      if (selectedTags.isEmpty) {
        return data;
      }
      return data.where((room) => selectedTags.contains(room.metadata!['Tag']))
          .toList();
    }
  }
