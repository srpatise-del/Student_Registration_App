import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

const String baseUrl = "http://127.0.0.1/student_registration_app/php_api/";

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  ////////////////////////////////////////////////////////////
  // ✅ Controllers
  ////////////////////////////////////////////////////////////

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // ✅ Image (ใช้ XFile รองรับ Web)
  ////////////////////////////////////////////////////////////

  XFile? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ Save Product + Upload Image
  ////////////////////////////////////////////////////////////

  Future<void> saveProduct() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปภาพ")));
      return;
    }

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกชื่อนักศึกษา")));
      return;
    }

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกอีเมล")));
      return;
    }

    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกเบอร์โทร")));
      return;
    }

    final url = Uri.parse("${baseUrl}insert_student.php");

    var request = http.MultipartRequest('POST', url);

    ////////////////////////////////////////////////////////////
    // ✅ Fields
    ////////////////////////////////////////////////////////////

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;

    ////////////////////////////////////////////////////////////
    // ✅ Upload Image (แยก Web / Mobile)
    ////////////////////////////////////////////////////////////

    if (kIsWeb) {
      final bytes = await selectedImage!.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: selectedImage!.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImage!.path),
      );
    }

    ////////////////////////////////////////////////////////////
    // ✅ Execute
    ////////////////////////////////////////////////////////////

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      debugPrint("Response: $responseData");

      final data = json.decode(responseData);

      if (data["success"] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("เพิ่มนักศึกษาเรียบร้อย")),
          );

          Navigator.pop(context, true);
        }
      } else {
        String errorMsg = data["error"] ?? "Unknown error";
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $errorMsg")));
        }
      }
    } catch (e) {
      debugPrint("Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มรายชื่อนักศึกษา")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [
              ////////////////////////////////////////////////////////////
              // 🖼 Image Preview (สำคัญมาก)
              ////////////////////////////////////////////////////////////
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all()),
                  child: selectedImage == null
                      ? const Center(child: Text("แตะเพื่อเลือกรูป"))
                      : kIsWeb
                      ? Image.network(
                          selectedImage!.path, // ✅ Web
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(selectedImage!.path), // ✅ Mobile
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 Name
              ////////////////////////////////////////////////////////////
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อศึกษา",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 💰 email
              ////////////////////////////////////////////////////////////
              TextField(
                controller: emailController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "อีเมล",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 phone
              ////////////////////////////////////////////////////////////
              TextField(
                controller: phoneController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "เบอร์โทร",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ////////////////////////////////////////////////////////////
              // ✅ Button
              ////////////////////////////////////////////////////////////
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProduct,
                  child: const Text("บันทึกศึกษา"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
