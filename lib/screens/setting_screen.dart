import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _ipEditingController = TextEditingController();
  final TextEditingController _portEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      var box = Hive.box('settingBox');
      var ip = box.get('ip') ?? '';
      if (ip.toString().isEmpty) {
        box.put('ip', '127.0.0.1');
      }
      ip = box.get('ip') ?? '';
      _ipEditingController.text = ip.toString();

      var port = box.get('port') ?? '';
      if (port.toString().isEmpty) {
        box.put('port', '9999');
      }
      port = box.get('port') ?? '';
      _portEditingController.text = port.toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ipEditingController.dispose();
    _portEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                TextField(
                  controller: _ipEditingController,
                  decoration: const InputDecoration(
                    hintText: 'IP 를 입력하세요',
                  ),
                ),
                TextField(
                  controller: _portEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Port 를 입력하세요',
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    var box = Hive.box('settingBox');
                    box.put('ip', _ipEditingController.text.trim());
                    box.put('port', _portEditingController.text.trim());
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
