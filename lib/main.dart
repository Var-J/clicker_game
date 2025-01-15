import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clicker Game',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _level = 1;
  int _exp = 0;
  int _maxExp = 100;
  int _counter = 30;
  int _maxCounter = 30; // TODO: Make Health bar
  int _attack = 1;
  int _statPoint = 0;
  int _critChance = 10;
  int _critDamage = 50;
  bool isCrit = false;
  int _attackSpeed = 1000;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(milliseconds: _attackSpeed), (Timer t) => _decrementCounter());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _decrementCounter() {
    setState(() {
      int actualDamage;
      var random = Random();
      var critRng = random.nextInt(100);

      if (critRng <= _critChance) {
        isCrit = true;
        actualDamage = (_attack * (100 + _critDamage) / 100).round();
      } else {
        isCrit = false;
        actualDamage = _attack;
      }

      if (_counter <= actualDamage) {
        var expGained = ((15 + 10 * _level + _maxCounter) * (1 + (_level - 1) / 19)).round();
        _exp += expGained.round();

        if (_exp >= _maxExp) {
          _exp -= _maxExp;
          _level++;
          _statPoint+= 3;
          _maxExp += ((_level * 40) * (1 + (_level - 1) / 17)).round();

          if (_level % 5 == 0) {
            _statPoint += 2;
          }

          if (_level % 3 == 0) {
            _attack++;
          }
        }

        var min = _level * 10 * (1 + (_level - 1 ) / 8).round();
        var newHp = min + random.nextInt(30 + (45 * _level - 1));

        _counter = newHp;
        _maxCounter = newHp;
      } else {
        _counter -= actualDamage;
      }
    });
  }

  void _increaseDamage() {
    setState(() {
      if (_statPoint > 0) {
        _attack++;
        _statPoint--;
      }
    });
  }

  void _increaseCritChance() {
    setState(() {
      if (_statPoint > 0 && _critChance < 100) {
        _critChance += 2;
        _statPoint--;
      }
    });
  }

  void _increaseCritDamage() {
    setState(() {
      if (_statPoint > 0) {
        _critDamage += 10;
        _statPoint--;
      }
    });
  }

  void _increaseAttackSpeed() {
    setState(() {
      if (_statPoint > 0 && _attackSpeed > 200) {
        final newAttackSpeed = _attackSpeed - 30;
        _attackSpeed = newAttackSpeed;
        timer?.cancel();
        timer = Timer.periodic(Duration(milliseconds: newAttackSpeed), (Timer t) => _decrementCounter());
        _statPoint--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _decrementCounter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 100)),
                    SizedBox(width: 300, height: 10, child: (
                        LinearProgressIndicator(value: _counter / _maxCounter, borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.green,)
                    ),),
                    SizedBox(height: 10),
                    Row(
                      spacing: 10,
                      children: [
                        Text(
                          '$_counter${isCrit ? "!" : ""}',
                          style: TextStyle(fontSize: 20, color: isCrit ? Colors.red : Colors.black),
                        ),
                        Text('/', style: TextStyle(fontSize: 20)),
                        Text('$_maxCounter', style: TextStyle(fontSize: 20),)
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text("Level", style: TextStyle(fontSize: 30)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 1,
                        children: [
                          Text('$_level.', style: TextStyle(fontSize: 30, height: 0, color: Colors.deepOrange)),
                          Text((_exp / _maxExp * 100).round().toString().padLeft(2, "0"), style: TextStyle(fontSize: 20, ))
                        ],
                      ),
                      SizedBox(width: 300, height: 10, child: (
                          LinearProgressIndicator(value: _exp / _maxExp, color: Colors.yellow.shade600, backgroundColor: Colors.yellowAccent.shade100, borderRadius: BorderRadius.circular(30),)
                      ),),
                      SizedBox(height: 20),
                      Text("Stats", style: TextStyle(fontSize: 20)),
                      Text("Points"),
                      Text("$_statPoint"),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(onPressed: _increaseDamage, child: Column(
                            children: [
                              Text("Attack"),
                              Text("$_attack")
                            ],
                          )),
                          TextButton(onPressed: _increaseCritChance, child: Column(
                            children: [
                              Text("Crit. Chance"),
                              Text("$_critChance %")
                            ],
                          )),
                          TextButton(onPressed: _increaseCritDamage, child: Column(
                            children: [
                              Text("Crit. Damage"),
                              Text("$_critDamage %")
                            ],
                          )),
                          TextButton(onPressed: _increaseAttackSpeed, child: Column(
                            children: [
                              Text("Att. Speed"),
                              Text("${_attackSpeed / 1000} s")
                            ],
                          )),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
