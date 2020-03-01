import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

import 'ScanCode.dart';
import 'Settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: <String, WidgetBuilder> {
        '/ScanCode' : (context) => ScanCode(),
        '/Settings' : (context) => Settings()
      },
    );
  }

}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login>{

  bool _rememberMe = false;
  String loginError = '';
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF000000).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: usernameController,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans'
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.account_circle, 
                color: Colors.white,
              ),
              hintText: 'Enter your username',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xFF000000).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            textInputAction: TextInputAction.done,
            onSubmitted: _handleSubmitted,
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock, 
                color: Colors.white,
              ),
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OpenSans'
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckBox() {
    return Container(
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe, 
              checkColor: Colors.green, 
              activeColor: Colors.white, 
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              }
            ),
          ),
          Text(
            'Remember me',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans'
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => _loginUser(context),
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.yellowAccent[100],
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans'
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _loadUser(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF536976),
                    Color(0xFFEEC0C6),
                  ],
                  stops: [0.4, 1],
                ),
              ),
            ),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(), 
                padding: EdgeInsets.symmetric(
                  horizontal: 40.0, 
                  vertical: 35.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.settings),
                          color: Colors.white,
                          onPressed: () => Navigator.pushNamed(context, '/Settings'),
                        ),
                      ],
                    ),
                    SizedBox(height: 47.0),
                    Text(
                      'Sign In',
                      style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'OpenSans',
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _buildUsernameTF(),
                    SizedBox(height: 30.0),
                    _buildPasswordTF(),
                    // _buildForgotPasswordBtn(),
                    SizedBox(height: 10.0),
                    _buildRememberMeCheckBox(),
                    _buildLoginBtn(),
                  ],
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loginUser(BuildContext context) {
    FocusScope.of(context).unfocus();

    final username = usernameController.text;
    final password = passwordController.text;

    if (_rememberMe == true) {
      _setRememberMe(username, password).then((value) {
        if (_validateUser(username, password) == true) {
          Navigator.pushNamed(context, '/ScanCode');
        } else {
          showErrorSnackbar(context);
        }
      });
    } else {
      _resetUser().then((value) {
        if (_validateUser(username, password) == true) {
          Navigator.pushNamed(context, '/ScanCode');
        } else {
          showErrorSnackbar(context);
        }
      });
    }
  }

  bool _loadUser(BuildContext context) {
    _getUser().then((user) {
      if (user != null) {
        if (_validateUser(user[0], user[1]) == true) {
          Navigator.pushNamed(context, '/ScanCode');
        } else {
          print('Invalid Credentials');
        }
      }
    });
  }

  bool _validateUser(String username, String password) {
    if (username == 'admin' && password == 'admin') {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _setRememberMe(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> user = List(2);
    user[0] = username;
    user[1] = password;

    await prefs.setStringList('user', user);
  }

  Future<List> _getUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user')) {
      final List user = prefs.getStringList('user');
      return user;
    } else {
      return null;
    }
  }

  Future<void> _resetUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  void _handleSubmitted(String value) {
    _loginUser(context);
  }

  void showErrorSnackbar(BuildContext context) {
    Flushbar(
      icon: Icon(
        Icons.cancel,
        size: 28,
        color: Colors.redAccent,
      ),
      messageText: Text(
        'Username or password is invalid',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0
        ),
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: Colors.redAccent,
      shouldIconPulse: false,
    )..show(context);
  }

}