import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/screens/crilist_screen.dart';
import 'package:spker_recognition/screens/request_screen.dart';
import 'dart:io' as io;
import 'package:file/local.dart';
import 'package:spker_recognition/screens/response_screen.dart';
import 'package:spker_recognition/screens/setting_screen.dart';
import 'package:spker_recognition/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRunningUploading = false;
  bool _isRecording = false;
  final _audioRecorder = Record();
  FlutterAudioRecorder2? _recorder;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  final LocalFileSystem localFileSystem = const LocalFileSystem();
  // File? _recordFile;

  @override
  void initState() {
    super.initState();
    _isRecording = false;
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.dispose();
  }

  _init() async {
    try {
      bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;

      if (hasPermission) {
        String customPath = '/audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = (await getExternalStorageDirectory())!;
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        // customPath = appDocDirectory.path + customPath;
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder2(customPath, audioFormat: AudioFormat.WAV);

        await _recorder!.initialized;
        // after initialization
        var current = await _recorder!.current(channel: 0);
        logger.d(current);
        // should be "Initialized", if all working fine
        setState(() {
          _currentStatus = current!.status!;
          logger.d(_currentStatus);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      logger.d(e);
    }
  }

  _start() async {
    try {
      await _recorder!.start();
      var recording = await _recorder!.current(channel: 0);
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      logger.d(e);
    }
  }

  Future<io.File> _stop() async {
    var result = await _recorder!.stop();
    logger.d("Stop recording: ${result!.path}");
    logger.d("Stop recording: ${result.duration}");
    io.File file = localFileSystem.file(result.path);
    // _recordFile = localFileSystem.file(result.path);
    logger.d("File length: ${await file.length()}");
    setState(() {
      _isRecording = false;
    });
    return file;
  }

  _running() async {
    logger.d('Running start...');
    try {
      var dio = Dio();
      var foldersetResponse = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/folderset',
      );
      logger.d('foldersetResponse>>>$foldersetResponse');
      if (foldersetResponse.statusCode == 200) {
        if (foldersetResponse.data == 'done') {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResponseScreen(),
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          showSnackBar('Running 실패', context);
        }
      }
    } catch (e) {
      logger.d(e);
      showSnackBar('Running error', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaker Recognition'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: SafeArea(
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
                  child: ElevatedButton(
                    child: Text(_isRecording ? '마이크 녹음 중...' : '마이크 녹음'),
                    onPressed: () async {
                      logger.d('_isRecording>>>$_isRecording');
                      if (_isRecording) {
                        io.File recordFile = await _stop();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestScreen(
                              recordFile: recordFile,
                            ),
                          ),
                        );
                      } else {
                        _start();
                      }
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
                    child: Text(
                      _isRunningUploading ? 'Running 처리중...' : 'Running 시작',
                    ),
                    onPressed: () async {
                      setState(() {
                        _isRunningUploading = true;
                      });
                      await _running();
                      setState(() {
                        _isRunningUploading = false;
                      });
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
                    child: const Text('등록된 사람 목록'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CrilistScreen(),
                        ),
                      );
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
