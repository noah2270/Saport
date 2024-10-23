import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';

class DataFetcher {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 리스너 구독 관리를 위한 변수들
  StreamSubscription? _adminSubscription;
  StreamSubscription? _robotSubscription;
  StreamSubscription? _patrolLogSubscription;
  StreamSubscription? _patrolInstructionSubscription;
  StreamSubscription? _weatherAlertSubscription;
  StreamSubscription? _patrolRoutineSubscription;
  StreamSubscription? _areaSubscription;


  // 어드민 정보만 불러오기
  Future<void> fetchAdminData() async {
  QuerySnapshot querySnapshot = await _db.collection('Administrator').get();
  administrators = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  print("Administrator data loaded");
  }

  // 어드민 정보에 대한 실시간 리스너 설정
  void startListeningForAdminChanges() {
    _db.collection('Administrator').snapshots().listen((snapshot) {
      administrators = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("Administrator data updated");
    });
  }

  // Firestore의 실시간 리스너 설정
  void startListeningForChanges() {
    _adminSubscription = _db.collection('Administrator').snapshots().listen((snapshot) {
      administrators = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("Administrator data updated");
    });

    _robotSubscription = _db.collection('Robot').snapshots().listen((snapshot) {
      robots = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("Robot data updated");
    });

    _patrolLogSubscription = _db.collection('PatrolLog').snapshots().listen((snapshot) {
      patrolLogs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("PatrolLog data updated");
    });

    _patrolInstructionSubscription = _db.collection('PatrolInstruction').snapshots().listen((snapshot) {
      patrolInstructions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("PatrolInstruction data updated");
    });

    _weatherAlertSubscription = _db.collection('WeatherAlert').snapshots().listen((snapshot) {
      weatherAlerts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("WeatherAlert data updated");
    });

    _patrolRoutineSubscription = _db.collection('PatrolRoutine').snapshots().listen((snapshot) {
      patrolRoutines = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("PatrolRoutine data updated");
    });

    _areaSubscription = _db.collection('Area').snapshots().listen((snapshot) {
      areas = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print("Area data updated");
    });
  }

  // Firestore 리스너를 정리하는 메서드
  void stopListeningForChanges() {
    _adminSubscription?.cancel();
    _robotSubscription?.cancel();
    _patrolLogSubscription?.cancel();
    _patrolInstructionSubscription?.cancel();
    _weatherAlertSubscription?.cancel();
    _patrolRoutineSubscription?.cancel();
    _areaSubscription?.cancel();

    print("All Firestore listeners have been canceled.");
  }

  // Firestore에서 데이터를 한 번 가져오는 메서드 (필요한 경우)
  Future<Map<String, dynamic>> fetchFromFirestore() async {
    Map<String, dynamic> firestoreData = {};

    firestoreData['Administrator'] = await _fetchCollection('Administrator');
    firestoreData['Robot'] = await _fetchCollection('Robot');
    firestoreData['PatrolLog'] = await _fetchCollection('PatrolLog');
    firestoreData['PatrolInstruction'] = await _fetchCollection('PatrolInstruction');
    firestoreData['WeatherAlert'] = await _fetchCollection('WeatherAlert');
    firestoreData['PatrolRoutine'] = await _fetchCollection('PatrolRoutine');
    firestoreData['Area'] = await _fetchCollection('Area');

    return firestoreData;
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(String collectionPath) async {
    QuerySnapshot querySnapshot = await _db.collection(collectionPath).get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
