import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  GlobalKey qrKey = GlobalKey();
  var qrText = "Scan Code Here...";
  var message = "";
  QRViewController controller;

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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: Column(children: <Widget>[
      Expanded(
        flex: 5,
        child: QRView(key: qrKey,
            overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderColor: Colors.lightGreenAccent,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300),
            onQRViewCreated: _onQRViewCreate),
      ),
      Expanded(
        flex: 1,
        child: Center(
          child: Text('$qrText'),
        ),
      ),
    ],));
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
        postData(scannedData);
      }
    });
  }

  Future<String> postData(scannedData) async {
    var url = "http://192.168.0.10/qrcode/index.php";
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

}