import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gsheets/gsheets.dart';

/// Your google auth credentials
///
/// how to get credentials - https://medium.com/@a.marenkov/how-to-get-credentials-for-google-sheets-456b7e88c430
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets1-393813",
  "private_key_id": "715dc06a90da439a6784d6d5b5446d73e32e18aa",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCXCw6MqqFLrLl1\nYNt/x7SKC5f3jfabRohWXrs4JU/C0o4CA/jx1SqMQL/YT7mR5MSYNpSKz5shwLFB\nDx/Y4bSnQEeDqdMM+lJOlTQHmQKpkRlTShm6IMmr/yAMfrJ2JckLakYPiu+VIUvm\n4VbML5YIc8KsYSJMhOZFoybju80hie2CXZgCvENznXuEmLy5zEcuMPnfw+tAroRi\nNZo3Dvtz+Njrx2k7bDat0DhB37e7Ud7bhvYeXrL7sMcNuxiy+sGaw8tgUL6BG6WB\nIJxhQtsIhQdySJLB488RQsv1OJK7mSSK2vJiWokouwIsfEmeGFouTBqljXjECCRH\nkeKZeQWlAgMBAAECgf9i8zwdaGExnmJHd/8V3uEMiP2fKlZH4E3uJScKJBIXDPXC\ncwVIvhOkhGBGmdIDsOadCh78Gxx62GbJ7mLdrOjrPNvKZZ7d7QkEcjIP2TkSzBhZ\neDeyJCPBlVwOjzY4oji9202CH8GK8TnfHhBj1fwTghJy5t/mxA2DNmqNwTZXk/c3\njDglKzBIzPLp1fT4/vE9VEOWCckA8iYN8pgWhsZY/qTwUIv+P3jdlu1Hv6KElmca\nRsEjg5OaKM2hFU/cyGcw5Hxp8ttxz7O3vpqOtlaCaRs7B74Uo0yfwKzkhvVG4i3X\n7wbs8IbOC3G4IEIbyvTdfl+keFX+Ik3shUetBqECgYEAzJIxV1z16im64gh2rdFA\nIDQi6IUd6orOF9TF7dmK/2cyxUbpIbjJ6yh/CsPBFXu0Gb59ZsMhlEGa8EeFs4wQ\nSBfmKYfhaKEb2wABuSxvKu8S0/5fP3dShrMkAjeu7Hbf9e3C9ikH+h29MeA681G7\nA8Y8wF6mJnuo3+ywwMdibx0CgYEAvQPpRX34WOb9G9aFeXDPt2zV32HryakxmfAZ\ntjc9D+qGwk1Hm72YoTNwoj47w//7Ekf+9Rh64iL/i3Qfvd6wiiwevoy0bOIzf/yo\nJiVaARGwYzfd3gcPqwznCkpOEy6LIk9g8WFvEwuuBmOAojpgZJCNeogIW/1vrBBr\nSRKDAikCgYEAm3YN4SJYD5ee2d8ssXLvlImKbcGbtn29mQatU8+affVi8+CrkmDn\nsbmYsgmJVlYny9ijW9C2WABzSl5QEN5EEUV4N993QRgOHyOmK57E7I+6czhAEe8P\n3CWPG9BNMo40LKR/IKqV0VGAUcLhib92q6uex2ImSeB3uZQZzqa2+1ECgYAKuF8R\nnuxn9mnim08krR5K0/RpX/9kh6EVjwWWTRm8flu4R3PJRH6UnftEaG0xV6Jgzg6K\nziGiE8QUn7hxJ2Ex5QC1Y/uTtVygZK8QwsuRBfTQG8oMnq/nzqqH7eDxu5EOmBvy\ndMk89kufdyNDkDYJXh14FqEKvpwH0UKUeWVOyQKBgQCbx+55lqYLH366Cas3t6Y5\nomK/lSbcQobt11it5EHnXKjZCNdJs8KRz4J7IoZl+lUU7zwK+kv2HcHtXGOI9P70\nJ2Kbuf2tUMaLjFefoFgqJyIPU/0OaP99TCoxqkT1ZG9a8wwMR8l3nItMKh6u0IAC\ncZxq9Axmd53Pu3UgEW06yw==\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets1@gsheets1-393813.iam.gserviceaccount.com",
  "client_id": "103301161868394051520",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets1%40gsheets1-393813.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

/// Your spreadsheet id
///
/// It can be found in the link to your spreadsheet -
/// link looks like so https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit#gid=0
/// [YOUR_SPREADSHEET_ID] in the path is the id your need
const _spreadsheetId = '1cR2r9plrdguDJb4_k3NfKOmAqQF6Ef7SpN1HV263fMk';

class GoogleSheets {
  Future<String> insertData(_googleSheetID, data) async {
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_googleSheetID);
    var sheet = ss.worksheetByTitle('Sheet1');
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('Sheet1');
    await sheet.values.insertValue('Kode Barcode', column: 1, row: 1);
    var getAllData = await sheet.values.column(1);
    var isFound = false;
    debugPrint("len : ${getAllData.length}");
    for (var values in getAllData) {
      if (data == values) {
        isFound = true;
        return "Duplikat Data";
        // break;
      }
    }
    if (!isFound) {
      var rowCount = getAllData.length + 1;
      await sheet.values.insertValue(data, column: 1, row: rowCount);
      return "Added to Google Sheet";
      // sheet.values.map.appendRow(data);
    }
    return "Failed";
  }

  Future<List<String>> getAllData(_googleSheetID) async {
    List<String> list = [];
    final gsheets = GSheets(_credentials);
    final ss = await gsheets.spreadsheet(_googleSheetID);
    var sheet = ss.worksheetByTitle('Sheet1');
    list = await sheet!.values.column(1);
    return list;
  }

  StreamController<List<String>> controller = StreamController<List<String>>();
  StreamSink<List<String>> get counterSink => controller.sink;
  Stream<List<String>> get counterStream => controller.stream;

  void getData() async {
    final gsheets = GSheets(_credentials);
    final ss = await gsheets.spreadsheet(_spreadsheetId);
    var sheet = ss.worksheetByTitle('Sheet1');
    List<String> list = await sheet!.values.column(1);
    List<String> temp = [];
    temp.add(list[0]);
    for (int i = list.length - 1; i >= 1; i--) {
      debugPrint(list[i]);
      temp.add(list[i]);
    }
    counterSink.add(temp);
  }

  // controller.stream.listen((event) {
  //     print(event);
  //   });

  void init() async {
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_spreadsheetId);

    // print(ss.data.namedRanges.byName.values
    //     .map((e) => {
    //           'name': e.name,
    //           'start':
    //               '${String.fromCharCode((e.range?.startColumnIndex ?? 0) + 97)}${(e.range?.startRowIndex ?? 0) + 1}',
    //           'end':
    //               '${String.fromCharCode((e.range?.endColumnIndex ?? 0) + 97)}${(e.range?.endRowIndex ?? 0) + 1}'
    //         })
    //     .join('\n'));

    // get worksheet by its title
    var sheet = ss.worksheetByTitle('Sheet1');
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('Sheet1');

    // update cell at 'B2' by inserting string 'new'
    await sheet.values.insertValue('new', column: 2, row: 2);
    // prints 'new'
    print(await sheet.values.value(column: 2, row: 2));
    // get cell at 'B2' as Cell object
    final cell = await sheet.cells.cell(column: 2, row: 2);
    // prints 'new'
    print(cell.value);
    // update cell at 'B2' by inserting 'new2'
    await cell.post('new2');
    // prints 'new2'
    print(cell.value);
    // also prints 'new2'
    print(await sheet.values.value(column: 2, row: 2));

    // insert list in row #1
    final firstRow = ['index', 'letter', 'number', 'label'];
    await sheet.values.insertRow(1, firstRow);
    // prints [index, letter, number, label]
    print(await sheet.values.row(1));

    // insert list in column 'A', starting from row #2
    final firstColumn = ['0', '1', '2', '3', '4'];
    await sheet.values.insertColumn(1, firstColumn, fromRow: 2);
    // prints [0, 1, 2, 3, 4, 5]
    print(await sheet.values.column(1, fromRow: 2));

    // insert list into column named 'letter'
    final secondColumn = ['a', 'b', 'c', 'd', 'e'];
    await sheet.values.insertColumnByKey('letter', secondColumn);
    // prints [a, b, c, d, e, f]
    print(await sheet.values.columnByKey('letter'));

    // insert map values into column 'C' mapping their keys to column 'A'
    // order of map entries does not matter
    final thirdColumn = {
      '0': '1',
      '1': '2',
      '2': '3',
      '3': '4',
      '4': '5',
    };
    await sheet.values.map.insertColumn(3, thirdColumn, mapTo: 1);
    // prints {index: number, 0: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6}
    print(await sheet.values.map.column(3));

    // insert map values into column named 'label' mapping their keys to column
    // named 'letter'
    // order of map entries does not matter
    final fourthColumn = {
      'a': 'a1',
      'b': 'b2',
      'c': 'c3',
      'd': 'd4',
      'e': 'e5',
    };
    await sheet.values.map.insertColumnByKey(
      'label',
      fourthColumn,
      mapTo: 'letter',
    );
    // prints {a: a1, b: b2, c: c3, d: d4, e: e5, f: f6}
    print(await sheet.values.map.columnByKey('label', mapTo: 'letter'));

    // appends map values as new row at the end mapping their keys to row #1
    // order of map entries does not matter
    final secondRow = {
      'index': '5',
      'letter': 'f',
      'number': '6',
      'label': 'f6',
    };
    await sheet.values.map.appendRow(secondRow);
    // prints {index: 5, letter: f, number: 6, label: f6}
    print(await sheet.values.map.lastRow());

    // get first row as List of Cell objects
    final cellsRow = await sheet.cells.row(1);
    // update each cell's value by adding char '_' at the beginning
    cellsRow.forEach((cell) => cell.value = '_${cell.value}');
    // actually updating sheets cells
    await sheet.cells.insert(cellsRow);
    // prints [_index, _letter, _number, _label]
    print(await sheet.values.row(1));
  }
}
