import 'dart:typed_data'; // ByteData, Uint8List 사용을 위해 추가
import 'package:flutter/services.dart'; // rootBundle 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui; // ui 라이브러리를 사용하기 위해 추가

class MapContainer extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapContainer({required this.latitude, required this.longitude});

  @override
  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerIcon();
  }

  Future<void> _loadCustomMarkerIcon() async {
    final ui.Image resizedImage = await _loadAndResizeImage(
      'assets/gps_dot.png', // 사용자의 이미지 경로
      width: 24, // 아이콘의 너비 (픽셀 단위)
      height: 24, // 아이콘의 높이 (픽셀 단위)
    );

    final ByteData? byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final Uint8List resizedImageData = byteData.buffer.asUint8List();

      final BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(resizedImageData);
      setState(() {
        _customMarkerIcon = customIcon;
      });
    }
  }

  Future<ui.Image> _loadAndResizeImage(String assetPath, {required int width, required int height}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      height: 250,
      width: 400,
      decoration: BoxDecoration(
        color: Color(0xFF2478C2),
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _customMarkerIcon == null
          ? Center(child: CircularProgressIndicator()) // 로딩 인디케이터 표시
          : GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true, // 사용자의 현재 위치 표시
        zoomControlsEnabled: false, // 줌 컨트롤 비활성화
        compassEnabled: true, // 나침반 활성화
        mapToolbarEnabled: false, // 지도 도구 비활성화 (Google 지도 앱으로 이동하는 버튼)
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(_mapStyle);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 17.5,
        ),
        markers: {
          Marker(
            markerId: MarkerId('location_marker'),
            position: LatLng(widget.latitude, widget.longitude),
            icon: _customMarkerIcon!, // 커스텀 마커 아이콘 사용
          ),
        },
      ),
    );
  }

  // JSON 스타일 문자열
  final String _mapStyle = '''[
    {
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "elementType": "labels.icon",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi",
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.business",
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "poi.school",
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "transit.station",
        "elementType": "labels.text",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "landscape.natural",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#f5f5f2"
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "landscape.man_made",
        "elementType": "geometry.fill",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "visibility": "on"
            }
        ]
    },
    {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "visibility": "simplified"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "stylers": [
            {
                "visibility": "simplified"
            },
            {
                "color": "#ffffff"
            }
        ]
    },
    {
        "featureType": "road.local",
        "stylers": [
            {
                "color": "#ffffff"
            }
        ]
    },
    {
        "featureType": "water",
        "stylers": [
            {
                "color": "#71c8d4"
            }
        ]
    },
    {
        "featureType": "landscape",
        "stylers": [
            {
                "color": "#e5e8e7"
            }
        ]
    },
    {
        "featureType": "poi.park",
        "stylers": [
            {
                "color": "#8ba129"
            }
        ]
    },
    {
        "featureType": "road",
        "stylers": [
            {
                "color": "#ffffff"
            }
        ]
    }
  ]''';
}
