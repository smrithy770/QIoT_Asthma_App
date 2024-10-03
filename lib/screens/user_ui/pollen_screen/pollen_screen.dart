import 'dart:io';

import 'package:asthmaapp/api/peakflow_api.dart';
import 'package:asthmaapp/api/pollen_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/constants/pollen_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/pollen_location_model/pollen_data_model.dart';
import 'package:asthmaapp/models/pollen_location_model/pollen_location_model.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/pollen_screen/widgets/pollen_type_widgets.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:realm/realm.dart';

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
  UserModel? userModel;
  Map<String, dynamic> homepageData = {};
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  Position? _currentPosition;

  Map<String, dynamic> peakflowReportData = {};
  List<PollenLocationModel> pollenLocationData = [];
  Map<String, dynamic> pollenData = {};
  List<PollenDataModel> pollenDataList = [];
  Set<Marker> markers = {}; // Dynamic markers set

  DateTime currentDate = DateTime.now();
  int currentMonth = 1;
  int currentYear = 1;

  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(51.509865, -0.118092),
    zoom: 14,
  );

  Set<Circle> circles = {};

  int pollenSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    setState(() {
      currentMonth = currentDate.month;
      currentYear = currentDate.year;
    });
    _loadUserData();
    _handleRefresh(currentMonth, currentYear);
  }

  Future<void> _requestPermissions() async {
    await _permissionService.locationPermission();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      // Store the location data
      setState(() {
        _currentPosition = position;
      });
      _getPollenData();
      // Use the location data (latitude, longitude)
      logger.d('Current Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      // Handle location retrieval error
      CustomSnackBarUtil.showCustomSnackBar('Error retrieving location: $e',
          success: false);
    }
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    if (user != null) {
      setState(() {
        userModel = user;
      });
    }
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  Future<void> _getPollenData() async {
    try {
      final pollenDataRsponse = await PollenDataApi().getPollenData(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (pollenDataRsponse != null) {
        setState(() {
          pollenData = pollenDataRsponse;
        });
      } else {
        logger.e('Failed to fetch pollen data');
      }
    } on SocketException catch (e) {
      logger.e('NetworkException: $e');
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  Future<void> _handleRefresh(int currentMonth, int currentYear) async {
    pollenLocationData.clear();
    try {
      final jsonResponse = await PeakflowApi().getPeakflowHistory(
        userModel!.userId,
        currentMonth,
        currentYear,
        userModel!.accessToken,
      );
      final status = jsonResponse['status'];
      if (status == 200) {
        final payload = jsonResponse['payload'];
        setState(() {
          peakflowReportData = payload;
          // pollenLocationData = payload['peakflow'];
        });
        logger.d('Peakflow Report Data: $peakflowReportData');
        for (var i in peakflowReportData['peakflow']) {
          final longitude = i['location']['coordinates'][0];
          final latitude = i['location']['coordinates'][1];

          // Add pollen location data
          pollenLocationData.add(PollenLocationModel(longitude, latitude));

          markers.add(Marker(
            markerId: MarkerId('${longitude}_$latitude'), // Unique ID
            position: LatLng(latitude, longitude),
            // icon: await BitmapDescriptor.asset(
            //     const ImageConfiguration(
            //         size: Size(48, 48)), // Size of the icon
            //     'assets/pngs/inhaler_location_marker.png'), // Set the PNG icon
            infoWindow: InfoWindow(
              title: 'You used your inhaler here',
              snippet: 'A: ($latitude, $longitude)',
            ),
          ));
          circles.add(Circle(
            circleId: CircleId('${longitude}_$latitude'),
            center: LatLng(latitude, longitude),
            radius: 10,
            strokeWidth: 0,
            fillColor: pollenBackgroundColor[pollenData['dailyInfo'][0]
                            ['pollenTypeInfo'][pollenSelectedIndex]
                        .containsKey('indexInfo') &&
                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                            [pollenSelectedIndex]['indexInfo'] !=
                        null
                ? pollenData['dailyInfo'][0]['pollenTypeInfo']
                    [pollenSelectedIndex]['indexInfo']['value']
                : 0],
          ));
        }
      }
    } on SocketException catch (e) {
      logger.e('NetworkException: $e');
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    final double height = screenSize.height -
        (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/user_assets/user_drawer_icon.svg', // Replace with your custom icon asset path
                width: screenRatio * 10,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pollen',
            style: TextStyle(
              fontSize: screenRatio * 10,
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
        onRefresh: () => _handleRefresh(currentMonth, currentYear),
        child: Center(
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: height * 0.75,
                  child: GoogleMap(
                    initialCameraPosition: initialCameraPosition,
                    markers: markers,
                    circles: circles,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                  ),
                ),
                Container(
                  width: screenSize.width,
                  height: height * 0.25,
                  padding: EdgeInsets.all(
                    screenRatio * 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PollenType(
                        label: 'Grass',
                        value: (pollenData['dailyInfo'] != null &&
                                pollenData['dailyInfo'].isNotEmpty &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'] !=
                                    null &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo']
                                    .isNotEmpty &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'][0]
                                    .containsKey('indexInfo'))
                            ? pollenData['dailyInfo'][0]['pollenTypeInfo'][0]
                                    ['indexInfo']['value']
                                .toDouble()
                            : 0.0,
                        color: pollenBackgroundColor[
                            pollenData['dailyInfo'] != null &&
                                    pollenData['dailyInfo'].isNotEmpty &&
                                    pollenData['dailyInfo'][0]
                                            ['pollenTypeInfo'] !=
                                        null &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                        .isNotEmpty &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                            [0]
                                        .containsKey('indexInfo')
                                ? pollenData['dailyInfo'][0]['pollenTypeInfo']
                                    [0]['indexInfo']['value']
                                : 0],
                        onTap: () {
                          setState(() {
                            circles.clear();
                            pollenSelectedIndex = 0;
                            _getPollenData();
                            _handleRefresh(currentMonth, currentYear);
                          });
                        },
                      ),
                      PollenType(
                        label: 'Tree',
                        value: (pollenData['dailyInfo'] != null &&
                                pollenData['dailyInfo'].isNotEmpty &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'] !=
                                    null &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo']
                                        .length >
                                    1 &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'][1]
                                    .containsKey('indexInfo'))
                            ? pollenData['dailyInfo'][0]['pollenTypeInfo'][1]
                                    ['indexInfo']['value']
                                .toDouble()
                            : 0.0,
                        color: pollenBackgroundColor[
                            pollenData['dailyInfo'] != null &&
                                    pollenData['dailyInfo'].isNotEmpty &&
                                    pollenData['dailyInfo'][0]
                                            ['pollenTypeInfo'] !=
                                        null &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                            .length >
                                        1 &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                            [1]
                                        .containsKey('indexInfo')
                                ? pollenData['dailyInfo'][0]['pollenTypeInfo']
                                    [1]['indexInfo']['value']
                                : 0],
                        onTap: () {
                          setState(() {
                            circles.clear();
                            pollenSelectedIndex = 1;
                            _getPollenData();
                            _handleRefresh(currentMonth, currentYear);
                          });
                        },
                      ),
                      PollenType(
                        label: 'Weed',
                        value: (pollenData['dailyInfo'] != null &&
                                pollenData['dailyInfo'].isNotEmpty &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'] !=
                                    null &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo']
                                        .length >
                                    2 &&
                                pollenData['dailyInfo'][0]['pollenTypeInfo'][2]
                                    .containsKey('indexInfo'))
                            ? pollenData['dailyInfo'][0]['pollenTypeInfo'][2]
                                    ['indexInfo']['value']
                                .toDouble()
                            : 0.0,
                        color: pollenBackgroundColor[
                            pollenData['dailyInfo'] != null &&
                                    pollenData['dailyInfo'].isNotEmpty &&
                                    pollenData['dailyInfo'][0]
                                            ['pollenTypeInfo'] !=
                                        null &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                            .length >
                                        2 &&
                                    pollenData['dailyInfo'][0]['pollenTypeInfo']
                                            [2]
                                        .containsKey('indexInfo')
                                ? pollenData['dailyInfo'][0]['pollenTypeInfo']
                                    [2]['indexInfo']['value']
                                : 0],
                        onTap: () {
                          setState(() {
                            circles.clear();
                            pollenSelectedIndex = 2;
                            _getPollenData();
                            _handleRefresh(currentMonth, currentYear);
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
