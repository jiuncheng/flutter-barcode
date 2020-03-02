import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class Settings extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>{

  String fullUrl = "http://192.168.0.10/qrcode/index.php";

  TextEditingController urlController = TextEditingController();

  Widget _buildUrlTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'URL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
        Container(
          height: 60.0,
          child: TextField(
            controller: urlController,
            style: TextStyle(
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              hintText: 'Enter general url',
              hintStyle: TextStyle(
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildURLBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: RaisedButton(
        elevation: 5.0,
         onPressed: () => _saveSettings(),
        padding: EdgeInsets.all(13.0),
        color: Colors.greenAccent[200],
        child: Text(
          'Save Settings',
          style: TextStyle(
            fontSize: 15.0,
            fontFamily: 'OpenSans'
          ),
        ),
      ),
    );
  }

  Widget _logoutBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => logoutDialog().then((status) {
          if (status == true) {
            _resetUser().then((status) { 
              if (status == true) { Navigator.of(context).popUntil((route) => route.isFirst); }
            });
          }
        }),
        padding: EdgeInsets.all(13.0),
        color: Colors.redAccent[100],
        child: Text(
          'Logout User',
          style: TextStyle(
            fontSize: 15.0,
            fontFamily: 'OpenSans'
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 35.0
            ),
            child: Column(
              children: <Widget>[
                _buildUrlTF(),
                Text(
                  'Full URL: $fullUrl',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _logoutBtn(context),
                    _buildURLBtn(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String url = "http://192.168.0.10/qrcode/index.php";

    if (prefs.containsKey('url')) {
      url = prefs.getString('url');
      urlController.text = url;
    } else {
      urlController.text = url;
      _saveSettings();
    }

    setState(() {
      fullUrl = url;
    });

  }

  Future<bool> _saveSettings() async {
    FocusScope.of(context).unfocus();
    String url = urlController.text;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('url', url);

    showSuccessSnackbar(context, 'Settings Saved.');

    _loadSettings();
    return true;
  }

  Future<bool> _resetUser() async {
    FocusScope.of(context).unfocus();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');

    return true;
  }

  void showSuccessSnackbar(BuildContext context, String message) {
    Flushbar(
      icon: Icon(
        Icons.check,
        size: 32,
        color: Colors.lightGreenAccent[400],
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18.0
        ),
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: Colors.lightGreenAccent[400],
      shouldIconPulse: false,
    )..show(context);
  }

  Future<bool> logoutDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text('Logout')
          ),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            FlatButton(
              color: Colors.blue,
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ],
          elevation: 24.0,
        );
      },
    );
  }

}