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
  List<String> _crilist = [];

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
      logger.d('response>>>$response');
      if (response.statusCode == 200) {
        setState(() {
          _crilist = response.data
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('\'', '')
              .split(',');
          logger.d('_crilist>>>$_crilist');
        });
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
                  child: Container(
                    width: double.infinity,
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: _crilist
                            .map((c) => Text(
                                  c,
                                ))
                            .toList(),
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
}
