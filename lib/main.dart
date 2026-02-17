import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_student_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG (แก้ตรงนี้ถ้าเปลี่ยนเครื่อง)
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/student_registration_app/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StudentList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ Student LIST PAGE
//////////////////////////////////////////////////////////////

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List Students = [];
  List filteredStudents = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}show_data.php"));

      if (response.statusCode == 200) {
        setState(() {
          Students = json.decode(response.body);
          filteredStudents = Students;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterStudents(String query) {
    setState(() {
      filteredStudents = Students.where((Student) {
        final name = Student['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),

      body: Column(
        children: [
          //////////////////////////////////////////////////////
          // 🔍 SEARCH BOX
          //////////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Student name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterStudents,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 Student LIST
          //////////////////////////////////////////////////////
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final Student = filteredStudents[index];

                      //////////////////////////////////////////////////////
                      // ✅ IMAGE URL (สำคัญมาก)
                      //////////////////////////////////////////////////////

                      String imageUrl = "${baseUrl}images/${Student['image']}";

                      return Card(
                        child: ListTile(
                          //////////////////////////////////////////////////
                          // 🖼 IMAGE FROM SERVER
                          //////////////////////////////////////////////////
                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////
                          title: Text(Student['name'] ?? 'No Name'),

                          //////////////////////////////////////////////////
                          // 📝 phone
                          //////////////////////////////////////////////////
                          subtitle: Text(Student['phone'] ?? 'No phone'),

                          //////////////////////////////////////////////////
                          // 💰 email
                          //////////////////////////////////////////////////
                          trailing: Text('฿${Student['email'] ?? '0.00'}'),

                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentDetail(Student: Student),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ✅ ADD BUTTON
      ////////////////////////////////////////////////////////
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStudentPage()),
          ).then((value) {
            fetchStudents(); // ✅ รีโหลดหลังเพิ่มสินค้า
          });
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ Student DETAIL PAGE
//////////////////////////////////////////////////////////////

class StudentDetail extends StatelessWidget {
  final dynamic Student;

  const StudentDetail({super.key, required this.Student});

  @override
  Widget build(BuildContext context) {
    ////////////////////////////////////////////////////////////
    // ✅ IMAGE URL
    ////////////////////////////////////////////////////////////

    String imageUrl = "${baseUrl}images/${Student['image']}";

    return Scaffold(
      appBar: AppBar(title: Text(Student['name'] ?? 'Detail')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////
            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////
            Text(
              Student['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 phone
            //////////////////////////////////////////////////////
            Text(Student['phone'] ?? ''),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 💰 email
            //////////////////////////////////////////////////////
            Text(
              'ราคา: ฿${Student['email'] ?? '0.00'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
