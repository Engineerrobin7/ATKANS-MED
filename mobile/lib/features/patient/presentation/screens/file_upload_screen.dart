
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final _titleController = TextEditingController();
  String _selectedCategory = 'Lab Report';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Document', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Document Title',
                hintText: 'e.g. Blood Test Oct 2023',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Category', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            _buildCategoryDropdown(),
            
            const SizedBox(height: 40),
            
            // Upload Area
            InkWell(
              onTap: () {
                // Trigger file picker
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecting file...')));
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.limeGreen.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.limeGreen),
                    const SizedBox(height: 16),
                    Text('Select PDF or Image', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    Text('Maximum size: 10MB', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : () {
                  setState(() => _isUploading = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document Uploaded Successfully!')));
                      context.pop();
                    }
                  });
                },
                child: _isUploading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Confirm Upload', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = ['Lab Report', 'Prescription', 'Insurance', 'Vaccination', 'Others'];
    return Column(
      children: categories.map((cat) => RadioListTile<String>(
        title: Text(cat, style: const TextStyle(fontSize: 14)),
        value: cat,
        groupValue: _selectedCategory,
        activeColor: AppTheme.limeGreen,
        onChanged: (value) => setState(() => _selectedCategory = value!),
      )).toList(),
    );
  }
}
