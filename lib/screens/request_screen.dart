import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/screens/response_screen.dart';

class RequestScreen extends StatefulWidget {
  final io.File recordFile;
  RequestScreen({
    required this.recordFile,
    Key? key,
  }) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  Future<void> _makeInputFile() async {
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = (await getExternalStorageDirectory())!;
    }
    io.File inputFile = io.File('${appDocDirectory.path}/input.wav');
    if (await inputFile.exists()) {
      logger.d('exist input file delete...');
      await inputFile.delete();
    }

    widget.recordFile.copy('${appDocDirectory.path}/input.wav');
    inputFile = io.File('${appDocDirectory.path}/input.wav');
    logger.d("inputFile length: ${await inputFile.length()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: TextField(
                      decoration: InputDecoration(hintText: '파일이름을 입력하세요'),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('분석 데이터 보내기'),
                      onPressed: () async {
                        await _makeInputFile();
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ResponseScreen(),
                        //   ),
                        // );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('학습 데이터 보내기'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('메인으로'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
