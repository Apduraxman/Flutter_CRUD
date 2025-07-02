import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final SupabaseClient supabase;
  List<dynamic> students = [];
  late Future<void> studentsFuture;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final sectionController = TextEditingController();
  final shiftController = TextEditingController();

  int? editingStudentId; // Track which student is being edited

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    studentsFuture = fetchStudents(); // Fetch students once
  }

  Future<void> fetchStudents() async {
    try {
      final response = await supabase.from('students').select();
      setState(() {
        students = response as List<dynamic>;
      });
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching students: $error')),
      );
    }
  }

  Future<void> addStudent() async {
    try {
      await supabase.from('students').insert({
        'student_name': nameController.text,
        'student_address': addressController.text,
        'student_section': sectionController.text,
        'student_shift': shiftController.text,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      studentsFuture = fetchStudents(); // Refresh the future
      setState(() {}); // Trigger rebuild to update UI
    } catch (error) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding student: $error')));
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await supabase.from('students').delete().eq('id', id);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
      studentsFuture = fetchStudents(); // Refresh the future
      setState(() {}); // Trigger rebuild to update UI
    } catch (error) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting student: $error')));
    }
  }

  Future<void> updateStudent(int id) async {
    try {
      await supabase
          .from('students')
          .update({
            'student_name': nameController.text,
            'student_address': addressController.text,
            'student_section': sectionController.text,
            'student_shift': shiftController.text,
          })
          .eq('id', id);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
      studentsFuture = fetchStudents();
      setState(() {
        editingStudentId = null; // Reset editing state
      });
      clearControllers();
    } catch (error) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating student: $error')));
    }
  }

  void startEditingStudent(Map<String, dynamic> student) {
    setState(() {
      editingStudentId = student['id'];
      nameController.text = student['student_name'] ?? '';
      addressController.text = student['student_address'] ?? '';
      sectionController.text = student['student_section'] ?? '';
      shiftController.text = student['student_shift'] ?? '';
    });
  }

  void clearControllers() {
    nameController.clear();
    addressController.clear();
    sectionController.clear();
    shiftController.clear();
    editingStudentId = null; // Reset editing state
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: sectionController,
            decoration: const InputDecoration(labelText: 'Section'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: shiftController,
            decoration: const InputDecoration(labelText: 'Shift'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (editingStudentId != null) {
              updateStudent(editingStudentId!);
            } else {
              addStudent();
              clearControllers();
            }
          },
          child: Text(
            editingStudentId != null ? 'Update Student' : 'Add Student',
          ),
        ),
        Expanded(
          child: FutureBuilder<void>(
            future: studentsFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching students'));
              } else {
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      title: Text(student['student_name']),
                      subtitle: Text(
                        '${student['student_address']} - ${student['student_section']} - ${student['student_shift']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => startEditingStudent(student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteStudent(student['id']),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
