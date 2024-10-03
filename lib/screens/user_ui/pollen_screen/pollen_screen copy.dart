import 'package:asthmaapp/api/pollen_api.dart';
import 'package:asthmaapp/constants/pollen_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PollenScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const PollenScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<PollenScreen> createState() => _PollenScreenState();
}

class _PollenScreenState extends State<PollenScreen> {
  late Position position;
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(51.509865, -0.118092),
    zoom: 14,
  );
  Marker markers = const Marker(
    markerId: MarkerId('1'),
    position: LatLng(51.509865, -0.118092),
    infoWindow: InfoWindow(title: 'Google'),
  );
  Circle circles = const Circle(
    circleId: CircleId('1'),
    center: LatLng(51.509865, -0.118092),
    radius: 380,
    strokeWidth: 0,
    fillColor: Color.fromARGB(0, 0, 0, 0),
  );
  var pollenData;
  double latitude = 0.0;
  double longitude = 0.0;
  int pollenSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _initializePosition();
  }

  Future<void> _handleRefresh() async {}

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denies permission
      }
    }
    // Permission granted, proceed with getting the location
  }

  void _initializePosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      initialCameraPosition = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14,
      );
      markers = Marker(
        markerId: MarkerId('1'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Home'),
      );
      circles = Circle(
        circleId: CircleId('1'),
        center: LatLng(latitude, longitude),
        radius: 512,
        strokeWidth: 0,
        fillColor: pollenData != null
            ? pollenForegroundColor[pollenData['dailyInfo'][0]['pollenTypeInfo']
                [pollenSelectedIndex]['indexInfo']['value']]
            : Color.fromARGB(0, 0, 0, 0),
      );
    });
    print('Latitude: $latitude, Longitude: $longitude');
  }

  void fetchPollenData() async {
    var data = await PollenDataApi().getPollenData(latitude, longitude);
    setState(() {
      pollenData = data;
      circles = Circle(
        circleId: CircleId('1'),
        center: LatLng(latitude, longitude),
        radius: 512,
        strokeWidth: 0,
        fillColor: pollenBackgroundColor[pollenData != null
            ? pollenData['dailyInfo'][0]['pollenTypeInfo'][pollenSelectedIndex]
                    .containsKey('indexInfo')
                ? pollenData['dailyInfo'][0]['pollenTypeInfo']
                    [pollenSelectedIndex]['indexInfo']['value']
                : 0
            : 0],
      );
    });

    print(
        'Pollen Data: ${pollenData['dailyInfo'][0]['pollenTypeInfo'][pollenSelectedIndex]['indexInfo']?['value'] ?? 0}');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Pollen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        realm: widget.realm,
        deviceToken: widget.deviceToken,
        deviceType: widget.deviceType,
        onClose: () {
          Navigator.of(context).pop();
        },
        itemName: (String name) {
          logger.d(name);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Center(
          child: SizedBox(
            // color: Colors.blue,
            width: screenSize.width,
            height: screenSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: screenSize.height * 0.65,
                  child: GoogleMap(
                    initialCameraPosition: initialCameraPosition,
                    markers: {markers},
                    circles: {circles},
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                  ),
                ),
                SizedBox(
                  height: (screenSize.height * 0.35) -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight,
                  child: Container(
                    // color: Colors.blue,
                    width: screenSize.width,
                    height: screenSize.height * 0.1,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenSize.height * 0.04,
                          child: TextButton(
                            onPressed: () async {
                              fetchPollenData();
                            },
                            child: Text('Fetch Pollen Data'),
                          ),
                        ),
                        SizedBox(
                          height: screenSize.height * 0.04,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Tree
                              SizedBox(
                                width: screenSize.width * 0.3,
                                child: const Text(
                                  'Tree',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Grass
                              SizedBox(
                                width: screenSize.width * 0.3,
                                child: const Text(
                                  'Grass',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Weed
                              SizedBox(
                                width: screenSize.width * 0.3,
                                child: const Text(
                                  'Weed',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenSize.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pollenSelectedIndex = 0;
                                    fetchPollenData();
                                  });
                                },
                                child: SizedBox(
                                  width: screenSize.width * 0.3,
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
                                          color: Color.fromARGB(
                                              128, 218, 218, 218),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            color: pollenBackgroundColor[pollenData !=
                                                    null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][0]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                            ['pollenTypeInfo'][
                                                        0]['indexInfo']['value']
                                                    : 0
                                                : 0],
                                            value: pollenData != null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][0]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                                    [
                                                                    'pollenTypeInfo']
                                                                [0]['indexInfo']
                                                            ['value']
                                                        .toDouble()
                                                    : 0.0
                                                : 0.0,
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
                                              pollenData != null
                                                  ? pollenData['dailyInfo'][0][
                                                                  'pollenTypeInfo']
                                                              [0]
                                                          .containsKey(
                                                              'indexInfo')
                                                      ? '${pollenData['dailyInfo'][0]['pollenTypeInfo'][0]['indexInfo']['value'].toStringAsFixed(0)} / 5'
                                                      : '0 / 5'
                                                  : '0 / 5',
                                              style:
                                                  const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pollenSelectedIndex = 1;
                                    fetchPollenData();
                                  });
                                },
                                child: SizedBox(
                                  width: screenSize.width * 0.3,
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
                                          color: Color.fromARGB(
                                              128, 218, 218, 218),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            color: pollenBackgroundColor[pollenData !=
                                                    null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][1]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                            ['pollenTypeInfo'][
                                                        1]['indexInfo']['value']
                                                    : 0
                                                : 0],
                                            value: pollenData != null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][1]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                                    [
                                                                    'pollenTypeInfo']
                                                                [1]['indexInfo']
                                                            ['value']
                                                        .toDouble()
                                                    : 0.0
                                                : 0.0,
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
                                              pollenData != null
                                                  ? pollenData['dailyInfo'][0][
                                                                  'pollenTypeInfo']
                                                              [1]
                                                          .containsKey(
                                                              'indexInfo')
                                                      ? '${pollenData['dailyInfo'][0]['pollenTypeInfo'][1]['indexInfo']['value'].toStringAsFixed(0)} / 5'
                                                      : '0 / 5'
                                                  : '0 / 5',
                                              style:
                                                  const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pollenSelectedIndex = 2;
                                    fetchPollenData();
                                  });
                                },
                                child: SizedBox(
                                  width: screenSize.width * 0.3,
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
                                          color: Color.fromARGB(
                                              128, 218, 218, 218),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            color: pollenBackgroundColor[pollenData !=
                                                    null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][2]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                            ['pollenTypeInfo'][
                                                        2]['indexInfo']['value']
                                                    : 0
                                                : 0],
                                            value: pollenData != null
                                                ? pollenData['dailyInfo'][0][
                                                            'pollenTypeInfo'][2]
                                                        .containsKey(
                                                            'indexInfo')
                                                    ? pollenData['dailyInfo'][0]
                                                                    [
                                                                    'pollenTypeInfo']
                                                                [2]['indexInfo']
                                                            ['value']
                                                        .toDouble()
                                                    : 0.0
                                                : 0.0,
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
                                              pollenData != null
                                                  ? pollenData['dailyInfo'][0][
                                                                  'pollenTypeInfo']
                                                              [2]
                                                          .containsKey(
                                                              'indexInfo')
                                                      ? '${pollenData['dailyInfo'][0]['pollenTypeInfo'][2]['indexInfo']['value'].toStringAsFixed(0)} / 5'
                                                      : '0 / 5'
                                                  : '0 / 5',
                                              style:
                                                  const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   label: const Text('Refresh'),
      //   icon: const Icon(Icons.refresh),
      //   backgroundColor: const Color(0xFF004283),
      // ),
    );
  }
}
