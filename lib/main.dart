import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // アプリ起動前に位置情報の使用許諾を求める
  Future(() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 拒否されていればダイアログを出す
      await Geolocator.requestPermission();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  // 位置情報を取得できているか
  bool _hasPosition = false;

  // mapを表示した時の中心地（初期値は適当に東京駅にしておく）
  LatLng _center = const LatLng(35.6814999, 139.7654987);

  // ピンをさしておく位置のSet
  final Set<Marker> _markers = {
    const Marker(
        markerId: MarkerId("1"),
        position: LatLng(35.6814999, 139.7654987),
        infoWindow: InfoWindow(title: "東京駅")),
    Marker(
        markerId: const MarkerId("2"),
        position: const LatLng(35.4683206, 139.6228339),
        infoWindow: const InfoWindow(title: "横浜駅"),
        icon: BitmapDescriptor.defaultMarkerWithHue(30)),
    Marker(
        markerId: const MarkerId("3"),
        position: const LatLng(35.8802697, 139.6121077),
        infoWindow: const InfoWindow(title: "浦和駅"),
        icon: BitmapDescriptor.defaultMarkerWithHue(210)),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  // 現在地を取得
  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _center = LatLng(position.latitude, position.longitude);
    setState(() {
      _hasPosition = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps App'),
          backgroundColor: Colors.green[500],
        ),
        body: Column(
          children: [
            _hasPosition ? _createMap(_center) : const Text('位置情報を取得できませんでした'),
          ],
        ),
      ),
    );
  }

  Widget _createMap(LatLng center) {
    return Expanded(
      child: GoogleMap(
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        // 端末の位置情報を使用する
        myLocationEnabled: true,
        // 端末の位置情報を地図の中心に表示するボタンを表示する
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(target: center, zoom: 10),
        // マーカを表示する
        markers: _markers,
      ),
    );
  }
}
