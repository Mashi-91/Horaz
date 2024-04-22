import 'package:flutter/material.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/utils/AppUtils.dart';
import 'package:horaz/widgets/CommonWidgets.dart';

class AddCommunityWidget {
  static Widget buildTextField({
    TextEditingController? textEditingController,
    String? initialValue,
    Function(String)? onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonWidget.buildCustomText(
          text: 'Title',
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 50,
          child: TextFormField(
            onChanged: onChanged,
            initialValue: initialValue,
            keyboardType: TextInputType.text,
            controller: textEditingController,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.whiteColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.whiteColor),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.whiteColor,
              contentPadding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildTagsContainer({
    required String iconName,
    required String tagTitle,
    required Color tagColor,
    required bool isSelected,
    double? verticalPadding,
    double? horizontalPadding,
    required Function(bool) onSelect,
  }) {
    return InkWell(
      onTap: () {
        onSelect(!isSelected);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 18, vertical: verticalPadding ?? 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? tagColor : AppColors.whiteColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppUtils.svgIconInString(iconName, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonWidget.buildCustomText(
                  text: tagTitle,
                  textStyle: TextStyle(
                    color: isSelected
                        ? AppColors.whiteColor
                        : AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isSelected)
                  Container(
                    height: 3,
                    width: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: tagColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildMemberTile(room) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 8,
        onTap: () {},
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),
        title: CommonWidget.buildCustomText(
          text: 'Members',
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
            fontSize: 14,
          ),
        ),
        minVerticalPadding: 20,
        subtitle: CommonWidget.buildCustomText(
          text: '${room.users.length} Members',
          textStyle: TextStyle(
            fontWeight: FontWeight.w300,
            color: AppColors.blackColor,
            fontSize: 8,
          ),
        ),
        trailing: Icon(
          Icons.add_rounded,
          size: 18,
          color: AppColors.blackColor,
        ),
      ),
    );
  }
}
