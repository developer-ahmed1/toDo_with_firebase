import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';
import 'package:flutter/scheduler.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskController = TextEditingController();
  final String userId = "user-id-placeholder"; // Replace with actual user ID from authentication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'To-Do List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter a task',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.add, color: Colors.deepPurpleAccent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .where('userId', isEqualTo: userId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks yet!',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs.map((doc) {
                    return Task.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: task.isCompleted
                                ? const LinearGradient(
                              colors: [Colors.greenAccent, Colors.lightGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: task.isCompleted ? null : Colors.deepPurple[50],
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              if (task.isCompleted)
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted
                                    ? Colors.white
                                    : Colors.deepPurpleAccent,
                                fontWeight: task.isCompleted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            leading: task.isCompleted
                                ? const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 30,
                            )
                                : Checkbox(
                              value: task.isCompleted,
                              activeColor: Colors.deepPurpleAccent,
                              onChanged: (_) => _toggleTaskCompletion(task),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteTask(task),
                            ),
                          ),
                        ),
                      );
                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() async {
    if (_taskController.text.isNotEmpty) {
      final newTask = Task(
        id: '', // Firestore auto-generates the ID
        title: _taskController.text,
        isCompleted: false,
      );

      await _firestore.collection('tasks').add({
        'title': newTask.title,
        'isCompleted': newTask.isCompleted,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _taskController.clear();
    }
  }

  void _toggleTaskCompletion(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  void _deleteTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).delete();
  }
}
