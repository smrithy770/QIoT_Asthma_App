import 'package:asthmaapp/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationBottomSheet extends StatefulWidget {
  const NotificationBottomSheet({super.key});

  @override
  State<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _morningController = TextEditingController();

  final TextEditingController _eveningController = TextEditingController();

  // String _timeToString(TimeOfDay time) {
  //   return "${time.hour}:${time.minute} ${time.period.name}";
  // }

  TimeOfDay timeOfDay = TimeOfDay.now();

  Future<void> _selectMorningTime(BuildContext context) async {
    var initialTime =
        const TimeOfDay(hour: 6, minute: 0); // Morning time (6:00 AM)

    var time = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      if (time.period == DayPeriod.pm) {
        // If selected time is in the PM period, show a confirmation dialog
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: 'alert',
              title: 'Time Picker Error',
              content: 'Please select a morning timing',
              optionOne: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      } else {
        setState(() {
          timeOfDay = time;
          _morningController.text =
              "${time.hour}:${time.minute} ${time.period.name}";
        });
      }
    }
  }

  Future _selectEveningTime(BuildContext context) async {
    var initialTime =
        const TimeOfDay(hour: 6, minute: 0); // Morning time (6:00 AM)

    var time = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      if (time.period == DayPeriod.am) {
        // If selected time is in the PM period, show a confirmation dialog
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: 'alert',
              title: 'Time Picker Error',
              content: 'Please select an evening timing',
              optionOne: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      } else {
        setState(() {
          timeOfDay = time;
          _eveningController.text =
              "${time.hour}:${time.minute} ${time.period.name}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      height: 384,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'assets/svgs/user_assets/cross.svg',
                  width: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Text(
            'Please select notification timings',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFF004283),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: screenSize.width,
                    child: const Text(
                      'Morning:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _morningController,
                    onTap: () => _selectMorningTime(context),
                    decoration: const InputDecoration(
                      hintText: 'Select Morning Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: screenSize.width,
                    child: const Text(
                      'Evening:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xFF6C6C6C),
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _eveningController,
                    onTap: () => _selectEveningTime(context),
                    decoration: const InputDecoration(
                      hintText: 'Select Evening Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        screenSize.width * 0.24,
                        56,
                      ),
                      foregroundColor: const Color(0xFFFFFFFF),
                      backgroundColor: const Color(0xFF004283),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
