import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/utils.dart';

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
      _ipEditingController.text = getServerIp();
      _portEditingController.text = getServerPort();
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
                    showSnackBar('저장 완료', context);
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
