import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Menu { child }

class CustomActions extends StatefulWidget {
  const CustomActions({super.key});

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
            'assets/svgs/profile.svg',
            color: AppColors.primaryWhite, // Customize icon color
            width: 32,
          ),
          offset: const Offset(0, 42),
          onSelected: (Menu item) {
            print('Selected item: ${item.toString()}');
            setState(() {
              menuOpened = false; // Close the menu after selection
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
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
              child: Text('Add a child'),
            ),
            const PopupMenuItem<Menu>(
              height: 2,
              enabled: false,
              child: Divider(
                height: 1,
                thickness: 1,
              ),
            ),
          ],
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
                ? 'assets/svgs/arrow_up.svg'
                : 'assets/svgs/arrow_down.svg',
            color: AppColors.primaryWhite, // Customize arrow color
            width: 16,
          ),
        ),
      ],
    );
  }
}
