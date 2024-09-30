import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/device_screen.dart';
import 'package:asthmaapp/screens/user_ui/education_screen/education_screen.dart';
import 'package:asthmaapp/screens/user_ui/fitness_and_stress_screen/fitness_stress.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/profile_screen.dart';
import 'package:asthmaapp/screens/user_ui/steroid_dose_screen/steroid_dose_screen.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class CustomDrawer extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final String? remoteEducationPDFpath;
  final VoidCallback onClose;
  final Function(String) itemName;

  const CustomDrawer({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    this.remoteEducationPDFpath,
    required this.onClose,
    required this.itemName,
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
                    assetPath: 'assets/svgs/user_assets/home.svg',
                    name: 'Home',
                    onTap: () {
                      widget.itemName('Home');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home', // Named route
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/peakflow.svg',
                    name: 'Peakflow',
                    onTap: () {
                      widget.itemName('Peakflow');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/peakflow_record_screen', // Named route
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/steroid.svg',
                    name: 'Steroid Dose',
                    onTap: () {
                      widget.itemName('Steroid Dose');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/steroid_dose_record', // Named route
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/act.svg',
                    name: 'Asthma Control Test(ACT)',
                    onTap: () {
                      widget.itemName('Asthma Control Test(ACT)');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AsthmaControlTestScreen(
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
                    assetPath: 'assets/svgs/user_assets/fitness.svg',
                    name: 'Fitness and Stress',
                    onTap: () {
                      widget.itemName('Fitness and Stress');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FitnessStressScreen(
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
                    assetPath: 'assets/svgs/user_assets/device.svg',
                    name: 'Device',
                    onTap: () {
                      widget.itemName('Device');
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
                    assetPath: 'assets/svgs/user_assets/notes.svg',
                    name: 'Notes',
                    onTap: () {
                      widget.itemName('Notes');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/notes_screen', // Named route
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/report.svg',
                    name: 'Report',
                    onTap: () {
                      widget.itemName('Report');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/pollen.svg',
                    name: 'Pollen',
                    onTap: () {
                      widget.itemName('Pollen');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/education.svg',
                    name: 'Education',
                    onTap: () {
                      widget.itemName('Education');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                            path: widget.remoteEducationPDFpath,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/about.svg',
                    name: 'About',
                    onTap: () {
                      widget.itemName('About');
                    },
                  ),
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/profile.svg',
                    name: 'Profile',
                    onTap: () {
                      widget.itemName('Profile');
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
                    assetPath: 'assets/svgs/user_assets/logout.svg',
                    name: 'Logout',
                    onTap: () async {
                      UserModel? userModel = getUserData(widget.realm);

                      widget.itemName('Logout');
                      final response =
                          await AuthApi().signout(userModel!.userId);
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
