import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../model/themes.dart';

class LocationItem extends StatelessWidget {
  final double latitude;
  final double longitude;
  final LatLng location;
  final String title;
  final TextStyle style;

  LocationItem(
      {required this.title,
      required this.style,
      required this.latitude,
      required this.longitude,
      Key? key})
      : location = LatLng(latitude, longitude),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.3,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: FlutterMap(
              options: MapOptions(
                center:
                    location, // Set the center of the map to the first location
                keepAlive: true,
                zoom: 17, // Adjust the zoom level as needed
                enableScrollWheel: false,

                interactiveFlags: InteractiveFlag.all &
                    ~InteractiveFlag.rotate &
                    ~InteractiveFlag.drag, // Disable map rotation
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(markers: [
                  Marker(
                    width: 20,
                    height: 20,
                    point: location,
                    builder: (ctx) => Icon(
                      Icons.pin_drop,
                      color: Themes.textColor,
                    ),
                  )
                ])
              ],
            ),
          ),
          title != ''
              ? Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Themes.primaryColorLight.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  width: double.infinity,
                  child: Text(
                    title,
                    style: style,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
