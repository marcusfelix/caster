
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

@js.JSExport()
class ConfigController extends ValueNotifier<Map<String, dynamic>> {

  ConfigController(Map<String, dynamic> value) : super(value) {
    final export = js_util.createDartExport(this);
    js_util.setProperty(js_util.globalThis, '_deploid', export);
  }

  @js.JSExport('write')
  write(String key, dynamic data){
    value = {...value, ...{
      "key": DateTime.now().millisecondsSinceEpoch,
      key: data
    }};
    notifyListeners();
  }

  @js.JSExport('load')
  String get load => jsonEncode(value);


}