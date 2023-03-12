import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:flutter/services.dart' show rootBundle;

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    something();

  }

  Future<void> something() async {
    if (kIsWeb) {
      var file = 'example/test.xlsx';
      var bytes = await File(file).readAsBytesSync();
      //ByteData bytes = await rootBundle.load(file);
      var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      for (var table in decoder.tables.keys) {
        print(table);
        print(decoder.tables[table]!.maxCols);
        print(decoder.tables[table]!.maxRows);
        for (var row in decoder.tables[table]!.rows) {
          print('$row');
        }
      }

      var sheet = decoder.tables.keys.first;
      decoder
        ..updateCell(sheet, 0, 0, "L'oiseau <\"coucou\">")
        ..updateCell(sheet, 1, 0, 'B')
        ..updateCell(sheet, 2, 0, 'C')
        ..updateCell(sheet, 1, 1, 42.3)
        ..insertRow(sheet, 1)
        ..insertRow(sheet, 13)
        ..updateCell(sheet, 0, 13, 'A14')
        ..updateCell(sheet, 0, 12, 'A13')
        ..insertColumn(sheet, 0)
        ..removeRow(sheet, 1)
        ..removeColumn(sheet, 2);

      File(join('test/out/${basename(file)}'))
        ..createSync(recursive: true)
        ..writeAsBytesSync(decoder.encode());

      print('************************************************************');
      for (var table in decoder.tables.keys) {
        print(table);
        print(decoder.tables[table]!.maxCols);
        print(decoder.tables[table]!.maxRows);
        for (var row in decoder.tables[table]!.rows) {
          print('$row');
        }
      }
    } else {
      // var file = 'example/test.xlsx';
      // var bytes = File(file).readAsBytes();
      // //ByteData bytes = await rootBundle.load(file);
      // var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      // for (var table in decoder.tables.keys) {
      //   print(table);
      //   print(decoder.tables[table]!.maxCols);
      //   print(decoder.tables[table]!.maxRows);
      //   for (var row in decoder.tables[table]!.rows) {
      //     print('$row');
      //   }
      // }
      //
      // var sheet = decoder.tables.keys.first;
      // decoder
      //   ..updateCell(sheet, 0, 0, "L'oiseau <\"coucou\">")
      //   ..updateCell(sheet, 1, 0, 'B')
      //   ..updateCell(sheet, 2, 0, 'C')
      //   ..updateCell(sheet, 1, 1, 42.3)
      //   ..insertRow(sheet, 1)
      //   ..insertRow(sheet, 13)
      //   ..updateCell(sheet, 0, 13, 'A14')
      //   ..updateCell(sheet, 0, 12, 'A13')
      //   ..insertColumn(sheet, 0)
      //   ..removeRow(sheet, 1)
      //   ..removeColumn(sheet, 2);
      //
      // File(join('test/out/${basename(file)}'))
      //   ..createSync(recursive: true)
      //   ..writeAsBytesSync(decoder.encode());
      //
      // print('************************************************************');
      // for (var table in decoder.tables.keys) {
      //   print(table);
      //   print(decoder.tables[table]!.maxCols);
      //   print(decoder.tables[table]!.maxRows);
      //   for (var row in decoder.tables[table]!.rows) {
      //     print('$row');
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
