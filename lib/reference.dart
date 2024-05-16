import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;
//fetch data from database
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Fluuter is boring"),
        ),
        //dynamic rendering;infinte containers,
        //data to be retrieved from backend for finite containers
        // body: ListView.builder(itemBuilder: (_, index) {
        //   return Container(
        //     color:
        //         Colors.primaries[Random().nextInt(Colors.primaries.length)],
        //     width: 500,
        //     height: 500,
        //   );
        // })
        //for scrolling
        // body: ListView(
        //   scrollDirection: Axis.horizontal,
        //   addAutomaticKeepAlives: false,
        //   children: [
        //     Container(
        //       color: Colors.blue,
        //       width: 200,
        //       height: 50,
        //     ),
        //     Container(
        //       color: Colors.red,
        //       width: 200,
        //       height: 50,
        //     ),
        //     Container(
        //       color: Colors.yellow,
        //       width: 200,
        //       height: 50,
        //     ),
        //   ],
        // ),

        body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$count', style: const TextStyle(fontSize: 60)),
              //add button
              FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    count++;
                  });
                },
              ),
              //subtract button
              FloatingActionButton(
                child: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    count--;
                  });
                },
              )
            ]),

        // footer navbar
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: "Home",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.info),
        //       label: "About",
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.school),
        //       label: "School",
        //     )
        //   ],
        // ),
      ),
    );
  }
}
