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

  int? editingStudentId;

  final Color primaryBlue = const Color(0xFF2196F3); // Light Blue 500
  final Color lightBlue = const Color(0xFFE3F2FD); // Light Blue 50

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    studentsFuture = fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await supabase.from('students').select();
      setState(() {
        students = response as List<dynamic>;
      });
    } catch (error) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      studentsFuture = fetchStudents();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding student: $error')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
      studentsFuture = fetchStudents();
      setState(() {
        editingStudentId = null;
      });
      clearControllers();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating student: $error')));
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await supabase.from('students').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted successfully')),
      );
      studentsFuture = fetchStudents();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting student: $error')));
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
    editingStudentId = null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 4,
            color: lightBlue,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: primaryBlue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home, color: primaryBlue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: sectionController,
                    decoration: InputDecoration(
                      labelText: 'Section',
                      prefixIcon: Icon(Icons.class_, color: primaryBlue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: shiftController,
                    decoration: InputDecoration(
                      labelText: 'Shift',
                      prefixIcon: Icon(Icons.schedule, color: primaryBlue),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        editingStudentId != null ? Icons.save : Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(
                        editingStudentId != null
                            ? 'Update Student'
                            : 'Add Student',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (editingStudentId != null) {
                          updateStudent(editingStudentId!);
                        } else {
                          addStudent();
                          clearControllers();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            color: lightBlue,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: FutureBuilder<void>(
                future: studentsFuture,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching students'));
                  } else {
                    if (students.isEmpty) {
                      return const Center(child: Text('No students found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryBlue.withOpacity(0.15),
                            child: Text(
                              student['student_name'] != null &&
                                      student['student_name'].isNotEmpty
                                  ? student['student_name'][0].toUpperCase()
                                  : '?',
                              style: TextStyle(color: primaryBlue),
                            ),
                          ),
                          title: Text(
                            student['student_name'] ?? '',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${student['student_address'] ?? ''} • ${student['student_section'] ?? ''} • ${student['student_shift'] ?? ''}',
                            style: TextStyle(color: Colors.blue.shade400),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.amber,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => startEditingStudent(student),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete',
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
          ),
        ],
      ),
    );
  }
}
