import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/child_ui/home_screen/home_screen.dart';
import 'package:asthmaapp/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

enum Menu { child }

class CustomActions extends StatefulWidget {
  final List? children;
  final Realm realm;
  final String? deviceToken, deviceType;
  CustomActions({
    super.key,
    required this.children,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<CustomActions> createState() => _CustomActionsState();
}

class _CustomActionsState extends State<CustomActions> {
  @override
  Widget build(BuildContext context) {
    bool menuOpened = false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PopupMenuButton<Menu>(
          color: AppColors.primaryWhite,
          icon: SvgPicture.asset(
            'assets/svgs/user_assets/profile.svg',
            color: AppColors.primaryWhite, // Customize icon color
            width: 32,
          ),
          offset: const Offset(0, 42),
          onSelected: (Menu item) {
            print('Selected item: ${item.toString()}');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog(
                  type: 'child',
                  title: 'Add a child',
                  content: 'Do you have a child with asthma?',
                  optionOne: () {
                    Navigator.of(context).pop();
                  },
                  optionTwo: () {
                    Navigator.of(context).pop();
                  },
                );
              },
            );
            setState(() {
              menuOpened = false; // Close the menu after selection
            });
          },
          itemBuilder: (BuildContext context) {
            if (widget.children == null || widget.children!.isEmpty) {
              return <PopupMenuEntry<Menu>>[
                const PopupMenuItem<Menu>(
                  height: 2,
                  enabled: false,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                  ),
                ),
                const PopupMenuItem<Menu>(
                  height: 32,
                  value: Menu.child,
                  child: Text(
                    'Add a child',
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                const PopupMenuItem<Menu>(
                  height: 2,
                  enabled: false,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                  ),
                ),
              ];
            } else {
              return widget.children!.map((child) {
                return PopupMenuItem<Menu>(
                  enabled: false,
                  child: ListTile(
                    onTap: () {
                      print('${child['childID']}');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            realm: widget.realm,
                            deviceToken: widget.deviceToken,
                            deviceType: widget.deviceType,
                            childId: child['childID'],
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    leading: SvgPicture.asset(
                      'assets/svgs/user_assets/child.svg', // Customize icon color
                      width: 32,
                    ),
                    title: Text(
                      '${child['firstName']} ${child['lastName']}',
                      style: const TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                );
              }).toList();
            }
          },
          onCanceled: () {
            setState(() {
              menuOpened = false; // Close the menu if canceled
            });
          },
          onOpened: () {
            setState(() {
              menuOpened = true; // Open the menu
            });
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              menuOpened = !menuOpened; // Toggle menu open/close
            });
          },
          child: SvgPicture.asset(
            menuOpened
                ? 'assets/svgs/user_assets/arrow_up.svg'
                : 'assets/svgs/user_assets/arrow_down.svg',
            color: AppColors.primaryWhite, // Customize arrow color
            width: 16,
          ),
        ),
      ],
    );
  }
}
