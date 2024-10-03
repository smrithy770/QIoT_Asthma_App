import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PollenGauge extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const PollenGauge({
    Key? key,
    required this.value,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 5,
            showLabels: false,
            showTicks: false,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.4,
              cornerStyle: CornerStyle.bothCurve,
              color: Color.fromARGB(128, 218, 218, 218),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                color: color,
                value: value,
                cornerStyle: CornerStyle.bothCurve,
                width: 0.4,
                sizeUnit: GaugeSizeUnit.factor,
              )
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0.1,
                angle: 90,
                widget: Text(
                  '${value.toStringAsFixed(0)} / 5',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
