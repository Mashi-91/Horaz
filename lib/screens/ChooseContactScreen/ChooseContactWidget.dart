import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horaz/config/AppColors.dart';
import 'package:horaz/screens/ChooseContactScreen/ChooseContactController.dart';
import 'package:horaz/widgets/CommonWidgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChooseContactWidget {
  static Widget buildContactListTile({
    required types.User user,
  }) {
    final controller = Get.find<ChooseContactController>();
    return CommonWidget.buildContactTile(
      user: user,
      onTap: () {
        Get.back();
        controller.sendMessageToUser(controller, user);
      },
    );
  }

  static Widget buildContactListTileForContact(Contact contact) {
    final avatarImage = contact.avatar != null && contact.avatar!.isNotEmpty
        ? Image.memory(
            contact.avatar!,
            fit: BoxFit.cover, // Adjust the fit based on your requirements
          )
        : Image.network(
            'https://cdn-icons-png.flaticon.com/512/5357/5357285.png',
            fit: BoxFit.cover, // Adjust the fit based on your requirements
          );
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      tileColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      onTap: () {},
      leading: CircleAvatar(
        radius: 23,
        backgroundImage: avatarImage.image,
      ),
      title: CommonWidget.buildCustomText(
        text: contact.displayName ?? '',
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: CommonWidget.buildCustomText(
        text: contact.emails?.isNotEmpty == true
            ? contact.emails!.first.value.toString()
            : '',
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  static Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
