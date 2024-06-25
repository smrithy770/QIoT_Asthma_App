import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/child_ui/widgets/custom_drawer_list_item.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/peakflow_screen.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class CustomDrawer extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType, firstName;
  final VoidCallback onClose;
  final Function(int) onItemSelected;

  CustomDrawer({
    super.key,
    required this.firstName,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.onClose,
    required this.onItemSelected,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // widget.realm.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return SizedBox(
      width: screenSize.width * 0.8,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            Container(
              height: 128 + kToolbarHeight + statusBarHeight,
              decoration: const BoxDecoration(
                color: AppColors.childPrimaryLightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: statusBarHeight - 16,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/svgs/user_assets/cross.svg',
                              color: AppColors.primaryWhite,
                              width: 32,
                              height: 32,
                            ),
                            onPressed: widget.onClose,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: statusBarHeight - 16,
                          left: 16,
                        ),
                        child: SvgPicture.asset(
                          "assets/svgs/child_assets/child.svg",
                          width: 96,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.firstName!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: AppColors.primaryWhiteText,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comic Neue',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const SizedBox(height: 16),
                  CustomDrawerListItem(
                    backgroundColor: AppColors.childPrimaryPink,
                    assetPath: "assets/svgs/user_assets/home.svg",
                    name: "Home",
                    onTap: () {
                      widget.onItemSelected(0);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDrawerListItem(
                    backgroundColor: AppColors.childPrimaryPurple,
                    assetPath: "assets/svgs/user_assets/act.svg",
                    name: "Asthma Quiz",
                    onTap: () {
                      widget.onItemSelected(3);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDrawerListItem(
                    backgroundColor: AppColors.childPrimaryOrange,
                    assetPath: "assets/svgs/user_assets/fitness.svg",
                    name: "Fitness Quiz",
                    onTap: () {
                      widget.onItemSelected(4);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDrawerListItem(
                    backgroundColor: AppColors.childPrimaryLightBlue,
                    assetPath: "assets/svgs/user_assets/device.svg",
                    name: "Stress Quiz",
                    onTap: () {
                      widget.onItemSelected(5);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDrawerListItem(
                    backgroundColor: AppColors.childPrimaryPink,
                    assetPath: "assets/svgs/user_assets/education.svg",
                    name: "Education",
                    onTap: () {
                      widget.onItemSelected(9);
                    },
                  ),
                  // Add more list items for additional drawer options
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
