import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:spker_recognition/hive_util.dart';
import 'package:spker_recognition/log_util.dart';
import 'package:spker_recognition/utils.dart';

class CrilistScreen extends StatefulWidget {
  const CrilistScreen({Key? key}) : super(key: key);

  @override
  State<CrilistScreen> createState() => _CrilistScreenState();
}

class _CrilistScreenState extends State<CrilistScreen> {
  bool _isCrilist = false;
  bool _isFileLen = false;
  List<String> _crilist = [];
  List<String> _filelen = [];

  List<Cri> _dataList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _getCrilist();
    });
  }

  _getCrilist() async {
    setState(() {
      _isCrilist = true;
    });
    logger.d('_getCrilist start...');
    try {
      var dio = Dio();
      var response = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/crilist',
      );
      logger.d('crilist response>>>$response');
      if (response.statusCode == 200) {
        _crilist = response.data
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('\'', '')
            .split(',');
        logger.d('_crilist>>>$_crilist');
        setState(() {
          for (var element in _crilist) {
            _dataList.add(Cri(element, ''));
          }
          logger.d('cri datalist>>>${_dataList.map((e) => e.name)}');
        });

        await _getFilelen();
      }
    } catch (e) {
      logger.d(e);
      // showAlertDialog('ERROR', '${e.toString()}', context);
      showSnackBar('Crilist error', context);
    } finally {
      setState(() {
        _isCrilist = false;
      });
    }
  }

  _getFilelen() async {
    setState(() {
      _isFileLen = true;
    });
    logger.d('_getFilelen start...');
    try {
      var dio = Dio();
      var response = await dio.get(
        'http://${getServerIp()}:${getServerPort()}/filelen',
      );
      logger.d('filelen response>>>$response');
      if (response.statusCode == 200) {
        _filelen = response.data
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('\'', '')
            .split(',');
        logger.d('_filelen>>>$_filelen');
        setState(() {
          if (_dataList.length == _filelen.length) {
            for (int i = 0; i < _dataList.length; i++) {
              _dataList[i].size = _filelen[i].trim();
            }
            logger.d(
                'filelen datalist>>>${_dataList.map((e) => '${e.name}/${e.size}')}');
          } else {
            showSnackBar('등록된 사람과 파일길이의 수가 서로 다릅니다.', context);
          }
        });
      }
    } catch (e) {
      logger.d(e);
      // showAlertDialog('ERROR', '${e.toString()}', context);
      showSnackBar('Filelen error', context);
    } finally {
      setState(() {
        _isFileLen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                color: Colors.blue,
                                child: const Center(
                                  child: Text(
                                    '등록된 인물 이름',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                color: Colors.blue,
                                child: const Center(
                                  child: Text(
                                    '등록된 파일 개수',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: _dataList
                                .map(
                                  (c) => _buildRow(c),
                                )
                                .toList(),
                          ),
                        ),
                      ],
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
    );
  }

  Widget _buildRow(Cri c) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 3,
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.lightBlue.shade100,
                child: Center(
                  child: Text(
                    c.name,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                height: 40,
                color: Colors.lightBlue.shade100,
                child: Center(
                  child: Text(
                    c.size,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

class Cri {
  String name = '';
  String size = '';

  Cri(
    this.name,
    this.size,
  );
}
