import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/screens/response_screen.dart';
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
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSendInputUploading = false;

  bool _isAddDataUploading = false;

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

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
    setState(() {});
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
          setState(() {});
          showSnackBar('?????? ??????', context);
        }
      } else {
        showSnackBar('send input error', context);
      }
    } catch (e) {
      logger.d(e);
      showSnackBar('send input error', context);
    }
  }

  _addData(String fileName) async {
    logger.d('addData start...');
    logger.d('fileName>>>$fileName.wav');
    setState(() {
      _isAddDataUploading = true;
    });
    try {
      var dio = Dio();
      var formData = FormData.fromMap({
        '': await MultipartFile.fromFile(
          widget.recordFile.path,
          filename: '$fileName.wav',
        ),
      });
      var response = await dio.post(
        'http://${getServerIp()}:${getServerPort()}/adddata',
        data: formData,
      );
      logger.d(response);
      if (response.statusCode == 200) {
        if (response.data['result'] == 'success') {
          showSnackBar('adddata ??????', context);
        } else {
          showSnackBar('adddata ??????', context);
        }
      } else {
        showSnackBar('adddata error', context);
      }
    } catch (e) {
      logger.d(e);
    } finally {
      setState(() {
        _isAddDataUploading = false;
      });
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
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        hintText: '??????????????? ???????????????',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: Text(
                        _isSendInputUploading
                            ? '?????? ????????? ????????? ???...'
                            : '?????? ????????? ?????????',
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSendInputUploading = true;
                        });
                        await _makeInputFile();
                        await _sendInput();
                        setState(() {
                          _isSendInputUploading = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 150,
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          width: double.maxFinite,
                          child: ElevatedButton(
                            child: Text(
                              _isAddDataUploading
                                  ? '?????? ????????? ????????????...'
                                  : '?????? ????????? ?????????',
                            ),
                            onPressed: () async {
                              if (_textEditingController.text.isEmpty) {
                                showSnackBar('?????? ????????? ???????????????.', context);
                              } else {
                                String fileName =
                                    _textEditingController.text.trim();
                                await _addData(fileName);
                              }
                            },
                          ),
                        ),
                        const Text(
                          '(?????? ???????????? ????????? 10????????? 5????????? ???????????????)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 80,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      child: const Text('????????????'),
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
