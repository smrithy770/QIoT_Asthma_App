import 'dart:async';
import 'dart:io';

import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';

class CustomDrawer extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final VoidCallback onClose;
  final Function(String) itemName;

  const CustomDrawer({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.onClose,
    required this.itemName,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserModel? userModel;
  String? remoteEducationPDFpath = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = getUserData(widget.realm);
    });
    getUserData(widget.realm);

    downloadPdfFile(userModel?.educationalPlan).then((f) {
      logger.d("Download education files: ${f.path}");
      setState(() {
        remoteEducationPDFpath = f.path;
      });
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  Future<File> downloadPdfFile(String? url) async {
    Completer<File> completer = Completer();
    try {
      final filename = url?.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url!));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      logger.d("Download files");
      logger.d("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      logger.d('Error parsing asset file: $e');
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
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
                        width: 24,
                        height: 24,
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
                  // Home Screen
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
                  // Divider
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  // Peakflow Screen
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
                  // Divider
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  // Inhaler Screen
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/peakflow.svg',
                    name: 'Inhaler',
                    onTap: () {
                      widget.itemName('Inhaler');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/inhaler_record_screen', // Named route
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
                  // Divider
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  // Steroid Dose Screen
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
                  // Divider
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  // Asthma Control Test Screen
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/act.svg',
                    name: 'Asthma Control Test(ACT)',
                    onTap: () {
                      widget.itemName('Asthma Control Test(ACT)');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/asthma_control_test_record_screen', // Named route
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
                  // Divider
                  const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  // Fitness and Stress Screen
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/fitness.svg',
                    name: 'Fitness and Stress',
                    onTap: () {
                      widget.itemName('Fitness and Stress');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/fitness_stress_record_screen', // Named route
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
                    assetPath: 'assets/svgs/user_assets/device.svg',
                    name: 'Device',
                    onTap: () {
                      widget.itemName('Device');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/device_screen', // Named route
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
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/reports_screen', // Named route
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
                    assetPath: 'assets/svgs/user_assets/pollen.svg',
                    name: 'Pollen',
                    onTap: () {
                      widget.itemName('Pollen');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/pollen_screen', // Named route
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
                    assetPath: 'assets/svgs/user_assets/education.svg',
                    name: 'Education',
                    onTap: () {
                      widget.itemName('Education');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/education_screen', // Named route
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                          'path': remoteEducationPDFpath,
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
                    assetPath: 'assets/svgs/user_assets/about.svg',
                    name: 'About',
                    onTap: () {
                      widget.itemName('About');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/about_screen', // Named route
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
                    assetPath: 'assets/svgs/user_assets/profile.svg',
                    name: 'Profile',
                    onTap: () {
                      widget.itemName('Profile');
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/profile_screen', // Named route
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

                  //////////////////////////////////////////////
           /*       const Divider(
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFD7D7D7),
                  ),
                  CustomDrawerListItem(
                    assetPath: 'assets/svgs/user_assets/profile.svg',
                    name: 'Change Password',
                    onTap: () {
                      widget.itemName('Change Password');
                      Navigator.pushNamed(
                        context,
                        '/change_password', // Named route
                        arguments: {
                          'realm': widget.realm,
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                  ),*/
                  //////////////////////////////////////////////
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
                      final status = jsonResponse['status'];

                      if (status == 200) {
                        widget.realm.write(() {
                          widget.realm.delete(userModel);
                        });
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
