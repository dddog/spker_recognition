import 'package:hive/hive.dart';

String getServerIp() {
  var box = Hive.box('settingBox');
  var ip = box.get('ip') ?? '';
  if (ip.toString().isEmpty) {
    box.put('ip', '127.0.0.1');
  }
  ip = box.get('ip') ?? '';
  return ip.toString();
}

String getServerPort() {
  var box = Hive.box('settingBox');
  var port = box.get('port') ?? '';
  if (port.toString().isEmpty) {
    box.put('port', '9999');
  }
  port = box.get('port') ?? '';
  return port.toString();
}
