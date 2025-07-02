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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching teachers: $error')),
      );
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.book),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        editingTeacherId != null ? Icons.save : Icons.add,
                      ),
                      label: Text(
                        editingTeacherId != null
                            ? 'Update Teacher'
                            : 'Add Teacher',
                      ),
                      onPressed: () {
                        if (editingTeacherId != null) {
                          updateTeacher(editingTeacherId!);
                        } else {
                          addTeacher();
                          clearControllers();
                        }
                      },
                      style: ElevatedButton.styleFrom(
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
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: FutureBuilder<void>(
                future: teachersFuture,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching teachers'));
                  } else {
                    if (teachers.isEmpty) {
                      return const Center(child: Text('No teachers found.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: teachers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final teacher = teachers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              teacher['teacher_name'] != null &&
                                      teacher['teacher_name'].isNotEmpty
                                  ? teacher['teacher_name'][0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.indigo),
                            ),
                          ),
                          title: Text(teacher['teacher_name'] ?? ''),
                          subtitle: Text(
                            '${teacher['teacher_address'] ?? ''} • ${teacher['teacher_subject'] ?? ''} • ${teacher['teacher_experience'] ?? ''}',
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
                                onPressed: () => startEditingTeacher(teacher),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete',
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
          ),
        ],
      ),
    );
  }
}
