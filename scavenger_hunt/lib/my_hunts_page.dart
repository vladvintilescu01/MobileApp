import 'package:flutter/material.dart';

class MyHuntsPage extends StatefulWidget {
  const MyHuntsPage({Key? key}) : super(key: key);

  @override
  _MyHuntsPageState createState() => _MyHuntsPageState();
}

class _MyHuntsPageState extends State<MyHuntsPage> {
  // List of hunts and their completion status and progress
  final List<Hunt> hunts = [
    Hunt(name: 'Hunt 1', completedTasks: 3, totalTasks: 5),
    Hunt(name: 'Hunt 2', completedTasks: 5, totalTasks: 5),
    Hunt(name: 'Hunt 3', completedTasks: 1, totalTasks: 4),
    Hunt(name: 'Hunt 4', completedTasks: 4, totalTasks: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hunts'),
      ),
      body: ListView.builder(
        itemCount: hunts.length,
        itemBuilder: (context, index) {
          final hunt = hunts[index];
          final int completedTasks = hunt.completedTasks ?? 0;
          final int totalTasks = hunt.totalTasks ?? 1; // Avoid division by zero
          final completionPercentage = totalTasks > 0
              ? completedTasks / totalTasks
              : 0.0;

          return ListTile(
            leading: Icon(
              completionPercentage == 1.0
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: completionPercentage == 1.0 ? Colors.green : Colors.grey,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hunt.name),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: completionPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      Text(
                        '${(completionPercentage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: completionPercentage == 1.0,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    hunt.completedTasks = hunt.totalTasks;
                  } else {
                    hunt.completedTasks = 0;
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (completionPercentage == 1.0) {
                  hunt.completedTasks = 0;
                } else {
                  hunt.completedTasks = hunt.totalTasks;
                }
              });
            },
          );
        },
      ),
    );
  }
}

// Hunt class to store each hunt's name and task progress
class Hunt {
  final String name;
  int completedTasks;
  final int totalTasks;

  Hunt({required this.name, this.completedTasks = 0, required this.totalTasks});
}
