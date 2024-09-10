import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/device_screen.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/peakflow_screen.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/profile_screen.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class CustomDrawer extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final VoidCallback onClose;
  final Function(int) onItemSelected;

  CustomDrawer({
    super.key,
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
                        width: 32,
                        height: 32,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  CustomDrawerListItem(
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
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/peakflow.svg",
                    name: "Peakflow",
                    onTap: () {
                      widget.onItemSelected(1);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeakflowScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/steroid.svg",
                    name: "Steroid Dose",
                    onTap: () {
                      widget.onItemSelected(2);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/act.svg",
                    name: "Asthma Control Test(ACT)",
                    onTap: () {
                      widget.onItemSelected(3);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/fitness.svg",
                    name: "Fitness and Stress",
                    onTap: () {
                      widget.onItemSelected(4);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/device.svg",
                    name: "Device",
                    onTap: () {
                      widget.onItemSelected(5);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/notes.svg",
                    name: "Notes",
                    onTap: () {
                      widget.onItemSelected(6);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/report.svg",
                    name: "Report",
                    onTap: () {
                      widget.onItemSelected(7);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/pollen.svg",
                    name: "Pollen",
                    onTap: () {
                      widget.onItemSelected(8);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/education.svg",
                    name: "Education",
                    onTap: () {
                      widget.onItemSelected(9);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/about.svg",
                    name: "About",
                    onTap: () {
                      widget.onItemSelected(10);
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/profile.svg",
                    name: "Profile",
                    onTap: () {
                      widget.onItemSelected(11);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: "assets/svgs/user_assets/logout.svg",
                    name: "Logout",
                    onTap: () async {
                      UserModel? userModel = getUserData(widget.realm);

                      widget.onItemSelected(12);
                      final response = await AuthApi().signout(userModel!.id);
                      final jsonResponse = response;
                      final status = jsonResponse['status'] as int;

                      widget.realm.write(() {
                        widget.realm.delete(userModel);
                      });

                      if (status == 200) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SigninScreen(
                              realm: widget.realm,
                              deviceToken: widget.deviceToken,
                              deviceType: widget.deviceType,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        // Handle sign-in failure
                      }
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
