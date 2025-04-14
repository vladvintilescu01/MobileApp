import 'package:flutter/material.dart';

class NewGuidedHuntPage extends StatefulWidget {
  final List<String> initialItems;

  const NewGuidedHuntPage({Key? key, this.initialItems = const []}) : super(key: key);

  @override
  _NewGuidedHuntPageState createState() => _NewGuidedHuntPageState();
}

class _NewGuidedHuntPageState extends State<NewGuidedHuntPage> {
  late List<String> items;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    items = List.from(widget.initialItems); // Start with the provided items
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        items.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Guided Hunt'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Tasks: ${items.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: ListTile(
                    title: Text(items[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
