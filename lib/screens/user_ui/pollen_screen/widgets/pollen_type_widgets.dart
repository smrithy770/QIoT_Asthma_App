import 'package:asthmaapp/screens/user_ui/pollen_screen/widgets/pollen_gauge_widgets.dart';
import 'package:flutter/material.dart';

class PollenType extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final Function onTap;

  const PollenType({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: PollenGauge(
              value: value,
              color: color,
              label: label,
            ),
          ),
        ],
      ),
    );
  }
}
