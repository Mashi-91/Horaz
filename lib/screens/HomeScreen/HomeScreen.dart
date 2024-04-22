import 'export.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: HomeScreenWidget.buildAppBarSection(),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CommonWidget.buildLinearButtonWithIcon(
                //   onTap: () async {
                //   },
                //   text: 'add tags',
                // ),
                // const SizedBox(height: 20),
                HomeScreenWidget.buildCommunityRoomSection(),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: HomeScreenWidget.buildSingleRoomSection(),
            ),
          ),
        ],
      ),
    );
  }
}
