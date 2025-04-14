import 'package:flutter/material.dart';

class EditGuidedHuntPage extends StatefulWidget {
  final String huntName;

  const EditGuidedHuntPage({Key? key, required this.huntName}) : super(key: key);

  @override
  _EditGuidedHuntPageState createState() => _EditGuidedHuntPageState();
}

class _EditGuidedHuntPageState extends State<EditGuidedHuntPage> {
  late TextEditingController _nameController;
  final List<String> tasks = ['Find the hidden key', 'Solve the puzzle'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.huntName);
  }

  void _addTask() {
    setState(() {
      tasks.add('New Task ${tasks.length + 1}');
    });
  }

  void _saveHuntName() {
    setState(() {
      // Here you could also send the updated name back to a database or state management
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hunt name saved!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: const InputDecoration(
            hintText: 'Edit hunt name',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveHuntName,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('${index + 1}'),
            title: Text(tasks[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
