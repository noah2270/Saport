import 'package:flutter/material.dart';
import 'api_service.dart'; // ApiService import

const int SaportBlue = 0xFF2A558C;
const int IconGray = 0xFFC0C0C0;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();

  String _email = '';
  String _username = '';
  String _password = '';
  String _passwordCheck = '';
  String _memberNum = '';
  String _phoneNum = '';
  String _workspace = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordCheckController.dispose();
    super.dispose();
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
        leading: const BackButton(
          color: Colors.white,
        ),
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
                    children: [
                      _buildTextInput(
                        hintText: '사원 번호',
                        icon: Icons.numbers,
                        onSaved: (value) => _memberNum = value!,
                        validator: _validateNotEmpty,
                      ),
                      _buildTextInput(
                        hintText: '비밀번호',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: _passwordController,
                        onSaved: (value) => _password = value!,
                        validator: _validateNotEmpty,
                      ),
                      _buildTextInput(
                        hintText: '비밀번호 재입력',
                        icon: Icons.check,
                        obscureText: true,
                        controller: _passwordCheckController,
                        onSaved: (value) => _passwordCheck = value!,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return '비밀번호가 일치하지 않습니다.';
                          }
                          return null;
                        },
                      ),
                      _buildTextInput(
                        hintText: '[선택]이메일(비밀번호 찾기용)',
                        icon: Icons.email_outlined,
                        onSaved: (value) => _email = value!,
                        validator: (value) => null, // 선택적인 필드로서 검증이 필요하지 않음
                      ),
                    ],
                  ),
                  _buildInputContainer(
                    children: [
                      _buildTextInput(
                        hintText: '사용자 이름',
                        icon: Icons.person_outline,
                        onSaved: (value) => _username = value!,
                        validator: _validateNotEmpty,
                      ),
                      _buildTextInput(
                        hintText: '휴대전화 번호',
                        icon: Icons.phone_outlined,
                        onSaved: (value) => _phoneNum = value!,
                        validator: _validateNotEmpty,
                      ),
                      _buildTextInput(
                        hintText: '근무지',
                        icon: Icons.work_outline,
                        onSaved: (value) => _workspace = value!,
                        validator: _validateNotEmpty,
                      ),
                    ],
                  ),
                  _buildSignUpButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required List<Widget> children}) {
    return Container(
      height: 40.0 * children.length, // 높이를 적절히 조정
      width: 300,
      margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
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
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildTextInput({
    required String hintText,
    required IconData icon,
    required FormFieldSetter<String>? onSaved,
    required FormFieldValidator<String>? validator,
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    return Container(
      height: 38,
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: TextFormField(
        controller: controller,
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
        validator: validator,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      height: 40,
      width: 300,
      margin: EdgeInsets.fromLTRB(30, 50, 30, 10),
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
        onPressed: _signUp,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Color(SaportBlue)),
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
        child: Text(
          '회 원 가 입',
          style: TextStyle(
            fontFamily: 'BlackHanSans',
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 새로운 사용자 정보 저장
      Map<String, dynamic> newUser = {
        'admin_id': int.parse(_memberNum),
        'admin_password': _password,
        'admin_email': _email.isNotEmpty ? _email : null,
        'admin_name': _username,
        'admin_phone_number': _phoneNum,
        'admin_workspace': _workspace,
      };

      ApiService apiService = ApiService(baseUrl:'http://192.168.202.96:3000/api/'); // Base URL 수정 필요

      try {
        final response = await apiService.sendRequest(
          endpoint: 'data/administrators',
          method: 'POST',
          body: newUser,
        );

        if (response.statusCode == 201) { // 서버에서 201 상태 코드를 반환하는 경우
          print('회원가입 성공: $_memberNum $_username');
          Navigator.pop(context);
        } else {
          print('회원가입 실패: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입에 실패했습니다. 나중에 다시 시도해 주세요.')),
          );
        }
      } catch (e) {
        print('회원가입 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 항목 미입력입니다.';
    }
    return null;
  }
}
