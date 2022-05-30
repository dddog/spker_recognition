import 'package:flutter/material.dart';

class CrilistScreen extends StatefulWidget {
  const CrilistScreen({Key? key}) : super(key: key);

  @override
  State<CrilistScreen> createState() => _CrilistScreenState();
}

class _CrilistScreenState extends State<CrilistScreen> {
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
