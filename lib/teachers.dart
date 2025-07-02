import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  late final SupabaseClient supabase;
  List<dynamic> teachers = [];
  late Future<void> teachersFuture;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final subjectController = TextEditingController();
  final experienceController = TextEditingController();

  int? editingTeacherId;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    teachersFuture = fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    try {
      final response = await supabase.from('teachers').select();
      setState(() {
        teachers = response as List<dynamic>;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching teachers: $e')));
    }
  }

  Future<void> addTeacher() async {
    try {
      await supabase.from('teachers').insert({
        'teacher_name': nameController.text,
        'teacher_address': addressController.text,
        'teacher_subject': subjectController.text,
        'teacher_experience': experienceController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher added successfully')),
      );
      teachersFuture = fetchTeachers();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding teacher: $error')));
    }
  }

  Future<void> updateTeacher(int id) async {
    try {
      await supabase
          .from('teachers')
          .update({
            'teacher_name': nameController.text,
            'teacher_address': addressController.text,
            'teacher_subject': subjectController.text,
            'teacher_experience': experienceController.text,
          })
          .eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher updated successfully')),
      );
      teachersFuture = fetchTeachers();
      setState(() {
        editingTeacherId = null;
      });
      clearControllers();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating teacher: $error')));
    }
  }

  Future<void> deleteTeacher(int id) async {
    try {
      await supabase.from('teachers').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher deleted successfully')),
      );
      teachersFuture = fetchTeachers();
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting teacher: $error')));
    }
  }

  void startEditingTeacher(Map<String, dynamic> teacher) {
    setState(() {
      editingTeacherId = teacher['id'];
      nameController.text = teacher['teacher_name'] ?? '';
      addressController.text = teacher['teacher_address'] ?? '';
      subjectController.text = teacher['teacher_subject'] ?? '';
      experienceController.text = teacher['teacher_experience'] ?? '';
    });
  }

  void clearControllers() {
    nameController.clear();
    addressController.clear();
    subjectController.clear();
    experienceController.clear();
    editingTeacherId = null;
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
            controller: subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: experienceController,
            decoration: const InputDecoration(labelText: 'Experience'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (editingTeacherId != null) {
              updateTeacher(editingTeacherId!);
            } else {
              addTeacher();
              clearControllers();
            }
          },
          child: Text(
            editingTeacherId != null ? 'Update Teacher' : 'Add Teacher',
          ),
        ),
        Expanded(
          child: FutureBuilder<void>(
            future: teachersFuture,
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching teachers'));
              } else {
                return ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return ListTile(
                      title: Text(teacher['teacher_name'] ?? ''),
                      subtitle: Text(
                        '${teacher['teacher_address'] ?? ''} - ${teacher['teacher_subject'] ?? ''} - ${teacher['teacher_experience'] ?? ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => startEditingTeacher(teacher),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteTeacher(teacher['id']),
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
