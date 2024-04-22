import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

class GetFileIcon extends StatelessWidget {
  final String fileName;
  final double? size;

  const GetFileIcon(this.fileName, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String extension = fileName.toLowerCase().split('.').last;
    String svgAsset = 'assets/extensions/$extension-extension.svg';

    return FutureBuilder<bool>(
      future: _checkSvgAssetExistence(svgAsset),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking asset existence
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.data!) {
          // If an error occurs or the asset does not exist, show the default file icon
          return SvgPicture.asset('assets/extensions/txt-extension.svg',
              height: size, width: size);
        } else {
          // If the asset exists, display the SVG
          return SvgPicture.asset(
            svgAsset,
            width: size,
            height: size,
          );
        }
      },
    );
  }

  Future<bool> _checkSvgAssetExistence(String svgAsset) async {
    try {
      // Load the SVG asset as a string
      String svgString = await rootBundle.loadString(svgAsset);
      // Check if the SVG string is not empty
      return svgString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
