import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/task.dart';

class TodoListScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    FirebaseFirestore.instance
        .collection('todos')
        .add({'title': _controller.text});
    _controller.text = '';
  }

  void _deleteTask(task) async {
    await FirebaseFirestore.instance
        .collection('todos')
        .doc(task.taskId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo List'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Enter task name'),
                ),
              ),
              FlatButton(
                child: Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                onPressed: () {
                  _addTask();
                },
              )
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('todos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LinearProgressIndicator();
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      final task = Task.fromSnapshot(snapshot.data.docs[index]);
                      return Dismissible(
                        key: Key(task.taskId),
                        onDismissed: (direction) {
                          _deleteTask(task);
                        },
                        background: Container(
                          color: Colors.red,
                          child: Icon(
                            Icons.delete_outlined,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          title: Text(task.title),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
