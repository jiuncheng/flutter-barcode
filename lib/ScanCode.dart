import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:http/http.dart' as http;

class ScanCode extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode>{
  GlobalKey qrKey = GlobalKey();
  var qrText = "Scan Code Here...";
  var message = "";
  QRViewController controller;
  DateTime backButtonOnPressedTime;

  String url = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _handleBackBtnPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scan Code'),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () {
              controller.toggleFlash();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                controller.pauseCamera();
                Navigator.pushNamed(context, '/Settings').then((value) => controller.resumeCamera());
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              // flex: 5,
              child: QRView(key: qrKey,
                  overlay: QrScannerOverlayShape(
                      borderRadius: 10,
                      borderColor: Colors.lightGreenAccent,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300),
                  onQRViewCreated: _onQRViewCreate),
            ),
        ],
        )
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;

    _loadUrl().then((url) {
      
      controller.scannedDataStream.listen((scandata) {
        if (!scandata.isEmpty) {
          var scannedData = scandata;
          controller.pauseCamera();
          postData(scannedData, url);
        }
      });

    });
  }

  Future<String> postData(scannedData, String loadedUrl) async {

    String url = loadedUrl;
    var data = {};
    data["scanCode"] = scannedData;
    var body = json.encode(data);
    http.Response response = await http.post(
        Uri.encodeFull(url),
        body: body,
        headers: {"Accept": "application/json"}
    );

    if (response.statusCode == 200) {

      var resdata = json.decode(response.body);

      setState(() {
        message = resdata["status"];
        qrText = resdata["code"];
      });

      confirmation(scannedData).then((result) {
        if (result == true) {
          controller.resumeCamera();
        } else {
          SystemNavigator.pop();
        }
      });

    } else {

      setState(() {
        message = "Unable to Connect";
      });

      errorDialog().then((result) {
        if (result == true) {
          controller.resumeCamera();
        } else {
          SystemNavigator.pop();
        }
      });

    }
  }

  Future<bool> confirmation(String scannedData) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text('$message')
          ),
          content: Text('Code: $scannedData\n\nDo you want to scan again?'),
          actions: <Widget>[
            FlatButton(
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

  Future<bool> errorDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
                '$message',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
            ),
          ),
          content: Text('Do you want to scan again?'),
          actions: <Widget>[
            FlatButton(
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

  Future<void> _resetUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  Future<String> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = "http://192.168.0.10/qrcode/index.php";

    if (prefs.containsKey('url')) {
      url = prefs.getString('url');
      return url;
    } else {
      return url;
    }
    
  }

  Future<bool> _handleBackBtnPressed() async {
    DateTime currentTime = DateTime.now();

    bool backButton = backButtonOnPressedTime == null || currentTime.difference(backButtonOnPressedTime) > Duration(seconds: 2);
    if (backButton == true) {
      backButtonOnPressedTime = currentTime;

      Fluttertoast.showToast(
        msg: 'Double Click to Exit',
        backgroundColor: Colors.black,
        textColor: Colors.white
      );

      return false;
    }
    SystemNavigator.pop();
    return true;
  }
}