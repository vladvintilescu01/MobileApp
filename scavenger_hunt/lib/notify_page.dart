import 'hunting_page.dart';
import 'package:flutter/material.dart';
import 'new_guided_hunt_page.dart';
class NotifyPage extends StatelessWidget {
  const NotifyPage({Key? key}) : super(key: key);

  final List<String> notifications = const [
    'Alice found the first clue!',
    'Bob completed task 3!',
    'Your team unlocked a new challenge!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

    );
  }
}