import 'dart:convert';
import 'dart:io';
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

  var generalUrl = "";
  var specificUrl = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Code'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _resetUser();
            Navigator.pop(context);
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
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scandata) {

      if (!scandata.isEmpty) {
        var scannedData = scandata;
        controller.pauseCamera();
        getUrl(scannedData);
      }
    });
  }

  void getUrl(scannedData) {
    _loadUrl().then((value) {
      postData(scannedData, value[0], value[1]);
    });
  }

  Future<String> postData(scannedData, String generalUrl, String specificUrl) async {

    var url = 'http://' + generalUrl + '/' + specificUrl;
    print(url);
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

      confirmation().then((result) {
        if (result == true) {
          controller.resumeCamera();
        } else {
          exit(0);
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
          exit(0);
        }
      });

    }
  }

    Future<bool> confirmation() async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text('$message')
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

  Future<List> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String generalUrl = "192.168.0.10";
    String specificUrl = "qrcode/index.php";
    List data = List(2);

    if (prefs.containsKey('generalurl') && prefs.containsKey('specificurl')) {
      generalUrl = prefs.getString('generalurl');
      specificUrl = prefs.getString('specificurl');
      data[0] = generalUrl;
      data[1] = specificUrl;
    } else {
      data[0] = generalUrl;
      data[1] = specificUrl;
    }

    return data;
  }

}