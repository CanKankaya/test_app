import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../main.dart';

import 'package:test_app/route_test_screens/route_test_2.dart';

class RouteTest1 extends StatefulWidget {
  const RouteTest1({Key? key}) : super(key: key);

  @override
  State<RouteTest1> createState() => _RouteTest1State();
}

class _RouteTest1State extends State<RouteTest1> with RouteAware {
  @override
  void didPush() {
    log('Test1: Called didPush');
    super.didPush();
  }

  @override
  void didPop() {
    log('Test1: Called didPop');
    super.didPop();
  }

  @override
  void didPopNext() {
    log('Test1: Called didPopNext');
    super.didPopNext();
  }

  @override
  void didPushNext() {
    log('Test1: Called didPushNext');
    super.didPushNext();
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false,
        title: const Text('Flutter RouteAware Test Page 1'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RouteTest2(),
                      ),
                    );
                  },
                  child: const Text("RouteTest1")),
            ],
          ),
        ),
      ),
    );
  }
}
