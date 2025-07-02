class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => \_HomeScreenState();
}

class \_HomeScreenState extends State<HomeScreen> {
final TextEditingController \_studentNameController = TextEditingController();
List<dynamic> \_students = [];
void fetchStudents() async {
final response = await Supabase.instance.client
.from('students')
.select('id, student_name');
setState(() {
\_students = response;
});
}

@override
void initState() {
super.initState();
fetchStudents(); // Fetch students when the screen is initialized
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Student App', style: TextStyle(color: Colors.black)),
centerTitle: true,
backgroundColor: Colors.cyanAccent[400],
),
floatingActionButton: FloatingActionButton(
onPressed: () {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: Text('Add Student'),
content: TextField(
controller: \_studentNameController,
decoration: InputDecoration(hintText: 'Enter student name'),
),
actions: [
FilledButton(
onPressed: () async {
// Logic to add student
final textinput = _studentNameController.text;
await Supabase.instance.client.from('students').insert({
'student_name': textinput,
});
fetchStudents();
Navigator.of(context).pop();
},
child: Text('Add'),
),
TextButton(
onPressed: () {
Navigator.of(context).pop();
},
child: Text('Cancel'),
),
],
);
},
);
},
child: Icon(Icons.add),
),
body: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.all(16.0),
child: Text(
'List of Students',
style: TextStyle(fontSize: 20, color: Colors.blueAccent[400]),
),
),
Expanded(
child: ListView.builder(
itemCount: \_students.length,
itemBuilder: (context, index) {
final student = \_students[index];
return ListTile(title: Text(student['student_name'] ?? ''));
},
),
),
],
),
);
}
}
