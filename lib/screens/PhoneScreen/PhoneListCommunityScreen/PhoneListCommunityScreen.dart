import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/config/AppRoutes.dart';
import 'package:horaz/constants/AppConst.dart';
import 'package:horaz/models/CallHistoryModel.dart';
import 'package:horaz/screens/AddCommunityScreen/AddCommunityWidget.dart';
import 'package:horaz/screens/PhoneScreen/PhoneListCommunityScreen/PhoneListCommunityController.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:horaz/screens/PhoneScreen/PhoneScreenWidget.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class PhoneListCommunityScreen extends GetView<PhoneListCommunityController> {
  const PhoneListCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments;
    return Scaffold(
      appBar: PhoneScreenWidget.buildAppBarSection(isBack: true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: Get.width,
            height: 48,
            child: GetBuilder<PhoneListCommunityController>(builder: (_) {
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
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GetBuilder<PhoneListCommunityController>(builder: (_) {
              final filteredData =
                  _filterDataByTags(data, controller.selectedTags);
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final convertData = CallHistoryModel.fromJson(
                      filteredData[index] as Map<String, dynamic>);
                  final tagColor = AppUtils.getColorBasedOnTag(
                      convertData.roomTag.toString());
                  return PhoneScreenWidget.buildCommunityHistoryTile(
                    members: convertData,
                    tagColor: tagColor,
                  groupData: filteredData
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Map<dynamic, dynamic>> _filterDataByTags(
      RxList<Map<dynamic, dynamic>> data, List<String> selectedTags) {
    if (selectedTags.isEmpty) {
      return data.toList();
    }
    return data.where((item) => selectedTags.contains(item['roomTag'])).toList();
  }
}
