import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/utils.dart';

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
  bool _isSendInputDone = false;

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

    await widget.recordFile.copy('${appDocDirectory.path}/input.wav');
    inputFile = io.File('${appDocDirectory.path}/input.wav');
    logger.d("inputFile length: ${await inputFile.length()}");
  }

  _sendInput() async {
    logger.d('send input start...');
    setState(() {
      _isSendInputDone = false;
    });
    try {
      var dio = Dio();
      var formData = FormData.fromMap({
        '': await MultipartFile.fromFile(
          widget.recordFile.path,
          filename: 'input.wav',
        ),
      });
      var response = await dio.post(
        'http://${getServerIp()}:${getServerPort()}/upload',
        data: formData,
      );
      if (response.statusCode == 200) {
        logger.d(response.data['result']);
        if (response.data['result'] == 'success') {
          setState(() {
            _isSendInputDone = true;
          });
          showSnackBar('분석 완료', context);
        }
      } else {
        showSnackBar('send input error', context);
      }
    } catch (e) {
      logger.d(e);
    }
  }

  _running() async {
    logger.d('runnig start...');
    try {
      var dio = Dio();
      var foldersetResponse = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/folderset',
      );
      logger.d('foldersetResponse>>>$foldersetResponse');
      if (foldersetResponse.statusCode == 200) {
        // if(foldersetResponse.data)
      }

      var runningResponse = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/running',
      );
      logger.d('runningResponse>>>$runningResponse');
    } catch (e) {
      logger.d(e);
    }
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
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('분석 데이터 보내기'),
                      onPressed: () async {
                        await _makeInputFile();
                        await _sendInput();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('Running'),
                      onPressed: () async {
                        await _running();
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
                    height: 20,
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
