import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/gsheet.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  final _googleSheetKey = "gsheetkey";
  final GoogleSheets googleSheets = GoogleSheets();
  final storage = new FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();
  MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    googleSheets.getData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets'),
      ),
      body: FutureBuilder(
        future: Future.wait([readGoogleSheetID()]),
        builder: (context, snapshot) {
          // debugPrint(snapshot.data);
          if (snapshot.hasData) {
            _controller.text = snapshot.data![0]!;
            debugPrint(_controller.text);
          }
          return Container(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Google Sheet ID"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Google Sheet ID',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var googleSheetID = _controller.text;
                    debugPrint("Google ID : ${_controller.text}");
                    await storage.write(
                        key: _googleSheetKey, value: googleSheetID);
                    final qrcode = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QRViewExample(),
                      ),
                    );
                    debugPrint("qrcodeuuu : ${qrcode!.code}");
                    var data = qrcode!.code;
                    var message =
                        await googleSheets.insertData(googleSheetID, data);
                    _showToast(context, message);
                    googleSheets.getData();
                  },
                  child: const Text('Scan Barcode / QRCode '),
                ),
                Flexible(
                  child: listview(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Future<String?> readGoogleSheetID() async {
    return await storage.read(key: _googleSheetKey);
  }

  Widget listview() {
    return StreamBuilder<List<String>>(
      stream: googleSheets.counterStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data;
          var idx = list!.length - 1;
          return Container(
            child: ListView.builder(
              itemCount: list!.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Text(
                          'No',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          list[index],
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: Row(
                      children: [
                        Text("${idx--}"),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(list[index]),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          // Expanded(
          //   flex: 1,
          //   child: FittedBox(
          //     fit: BoxFit.contain,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: <Widget>[
          //         if (result != null)
          //           Text(
          //               'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
          //         else
          //           const Text('Scan a code'),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: <Widget>[
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   await controller?.toggleFlash();
          //                   setState(() {});
          //                 },
          //                 child: FutureBuilder(
          //                   future: controller?.getFlashStatus(),
          //                   builder: (context, snapshot) {
          //                     return Text('Flash: ${snapshot.data}');
          //                   },
          //                 ),
          //               ),
          //             ),
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                   onPressed: () async {
          //                     await controller?.flipCamera();
          //                     setState(() {});
          //                   },
          //                   child: FutureBuilder(
          //                     future: controller?.getCameraInfo(),
          //                     builder: (context, snapshot) {
          //                       if (snapshot.data != null) {
          //                         return Text(
          //                             'Camera facing ${describeEnum(snapshot.data!)}');
          //                       } else {
          //                         return const Text('loading');
          //                       }
          //                     },
          //                   )),
          //             )
          //           ],
          //         ),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: <Widget>[
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   await controller?.pauseCamera();
          //                 },
          //                 child: const Text('pause',
          //                     style: TextStyle(fontSize: 20)),
          //               ),
          //             ),
          //             Container(
          //               margin: const EdgeInsets.all(8),
          //               child: ElevatedButton(
          //                 onPressed: () async {
          //                   await controller?.resumeCamera();
          //                 },
          //                 child: const Text('resume',
          //                     style: TextStyle(fontSize: 20)),
          //               ),
          //             )
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        debugPrint("result : ${result}");
        if (result != null) {
          controller.dispose();
          Navigator.of(context).pop(result);
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
