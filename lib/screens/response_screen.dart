import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/utils.dart';

class ResponseScreen extends StatefulWidget {
  const ResponseScreen({Key? key}) : super(key: key);

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  String _indatabase = '';
  String _cridetect = '';
  String _voiceAccuracy = '';

  bool _isIndatabase = false;
  bool _isCridetect = false;
  bool _isVoiceAccuracy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _getIndatabase();
      _getCridetect();
      _getVoiceAccuracy();
    });
  }

  _getIndatabase() async {
    setState(() {
      _isIndatabase = true;
    });
    logger.d('_getIndatabase start...');
    try {
      var dio = Dio();
      var response = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/indatabase',
      );
      logger.d('response>>>$response');
      if (response.statusCode == 200) {
        setState(() {
          _indatabase = response.data;
        });
      }
    } catch (e) {
      logger.d(e);
      showSnackBar('indatabase error', context);
    } finally {
      setState(() {
        _isIndatabase = false;
      });
    }
  }

  _getCridetect() async {
    setState(() {
      _isCridetect = true;
    });
    logger.d('_getCridetect start...');
    try {
      var dio = Dio();
      var response = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/cridetect',
      );
      logger.d('response>>>$response');
      if (response.statusCode == 200) {
        setState(() {
          _cridetect = response.data;
        });
      }
    } catch (e) {
      logger.d(e);
      showSnackBar('cridetect error', context);
    } finally {
      setState(() {
        _isCridetect = false;
      });
    }
  }

  _getVoiceAccuracy() async {
    setState(() {
      _isVoiceAccuracy = true;
    });
    logger.d('_getVoiceAccuracy start...');
    try {
      var dio = Dio();
      var response = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/voiceAccuracy',
      );
      logger.d('response>>>$response');
      if (response.statusCode == 200) {
        setState(() {
          _voiceAccuracy = response.data;
        });
      }
    } catch (e) {
      logger.d(e);
      showSnackBar('voiceAccuracy error', context);
    } finally {
      setState(() {
        _isVoiceAccuracy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('?????? ?????? ??????'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(
                          30,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '????????? ???????????? : ',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _isIndatabase
                                      ? '...'
                                      : (_indatabase == '0'
                                          ? '????????? ???????????? ???????????? ????????? ????????????'
                                          : '????????? ???????????? ???????????? ????????? ????????????'),
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Text(
                                '???????????? ???????????? : ',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                _isCridetect
                                    ? '...'
                                    : (_indatabase == '0' ? '' : _cridetect),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              const Text(
                                '????????? : ',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                _isVoiceAccuracy
                                    ? '...'
                                    : (_indatabase == '0'
                                        ? ''
                                        : _voiceAccuracy),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
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
    );
  }
}
