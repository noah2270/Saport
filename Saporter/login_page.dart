import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather_service.dart';
import 'globals.dart';
import 'signup_page.dart'; // 회원가입 페이지로의 경로 지정
import 'info_main_page.dart'; // 메인 페이지로의 경로 지정

const int SaportBlue = 0xFF2A558C;
const int IconGray = 0xFFC0C0C0;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _inputID = '';
  String _inputPassword = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // WeatherService 인스턴스 가져오기
      final weatherService = Provider.of<WeatherService>(context, listen: false);
      weatherService.stopPeriodicTimer();
    });
  }

  bool _validateLogin(int adminId, String adminPassword) {
    for (var admin in administrators) {
      if (admin['admin_id'] == adminId && admin['admin_password'] == adminPassword) {
        return true; // 로그인 성공
      }
    }
    return false; // 로그인 실패
  }

  Future<void> _performLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int parsedId = int.tryParse(_inputID) ?? -1;

      if (_validateLogin(parsedId, _inputPassword)) {
        print('Administrators: ${administrators.length}');
        print('Robots: ${robots.length}');
        print('Patrol Logs: ${patrolLogs.length}');
        print('Patrol Instructions: ${patrolInstructions.length}');
        print('Weather Alerts: ${weatherAlerts.length}');
        print('Patrol Routines: ${patrolRoutines.length}');
        print('Areas: ${areas.length}');
        print('로그인 성공: $_inputID');
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InfoMainPage()),
        );
      } else {
        print('로그인 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('아이디 또는 비밀번호가 잘못되었습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'SAPORT',
            style: TextStyle(
              fontFamily: 'BlackHanSans',
              fontSize: 28.0,
              color: Colors.white,
              fontWeight: FontWeight.normal,
              letterSpacing: 2.0,
              wordSpacing: 4.0,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(SaportBlue),
      ),
      backgroundColor: Color(SaportBlue),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildInputContainer(
                    child: Column(
                      children: <Widget>[
                        _buildTextInput(
                          hintText: '아이디',
                          icon: Icons.person,
                          onSaved: (value) => _inputID = value!,
                        ),
                        _buildTextInput(
                          hintText: '비밀번호',
                          icon: Icons.lock,
                          obscureText: true,
                          onSaved: (value) => _inputPassword = value!,
                        ),
                      ],
                    ),
                  ),
                  _buildButton(
                    text: '로 그 인',
                    onPressed: _performLogin, // 수정된 메소드 이름 사용
                  ),
                  _buildTextButton(
                    text: '비밀번호 찾기 | 아이디 찾기 | 회원가입',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      height: 85,
      width: 300,
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: child,
    );
  }

  Widget _buildTextInput({
    required String hintText,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    bool obscureText = false,
  }) {
    return Container(
      height: 40,
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: Icon(
              icon,
              color: Color(IconGray),
              size: 20.0,
            ),
          ),
          hintStyle: TextStyle(fontSize: 12.0),
        ),
        obscureText: obscureText,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 40,
      width: 300,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Color(SaportBlue)),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontFamily: 'BlackHanSans',
              fontSize: 18.0,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 30,
      width: 300,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text),
        style: ButtonStyle(
          overlayColor: MaterialStateColor.resolveWith(
                (states) => Colors.transparent,
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 10.0)),
        ),
      ),
    );
  }
}
