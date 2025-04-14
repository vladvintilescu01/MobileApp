import 'package:flutter/material.dart';

class MyGuidedHuntsPage extends StatelessWidget {
  const MyGuidedHuntsPage({Key? key}) : super(key: key);

  final List<GuildHunt> guidedHunts = const [
    GuildHunt(name: 'Forest Adventure', startTime: '10:00 AM', endTime: '2:00 PM'),
    GuildHunt(name: 'City Scavenger', startTime: '1:00 PM', endTime: '5:00 PM'),
    GuildHunt(name: 'Mountain Quest', startTime: '9:00 AM', endTime: '12:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Guided Hunts'),
      ),
      body: ListView.builder(
        itemCount: guidedHunts.length,
        itemBuilder: (context, index) {
          final hunt = guidedHunts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(hunt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Start: ${hunt.startTime} - End: ${hunt.endTime}'),
              trailing: ElevatedButton(
                onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_guided_hunt_page',
                      arguments: {'huntName': hunt.name}, // Pass only the name
                    );
                  },

                child: const Text('Edit Hunt'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GuildHunt {
  final String name;
  final String startTime;
  final String endTime;

  const GuildHunt({required this.name, required this.startTime, required this.endTime});
}
