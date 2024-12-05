import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class BlogWritePage extends StatefulWidget {
  @override
  _BlogWritePageState createState() => _BlogWritePageState();
}

class _BlogWritePageState extends State<BlogWritePage> {
  final QuillController _quillController = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Web için gerekli
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final index = _quillController.selection.baseOffset;

      // Base64 kullanarak resmi Quill dokümanına ekle
      final imageUrl = 'data:image/png;base64,${base64Encode(fileBytes)}';
      _quillController.document.insert(index, BlockEmbed.image(imageUrl));
    }
  }

  void _saveBlogPost() {
    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText().trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başlık ve içerik boş olamaz!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simüle edilen kaydetme işlemi
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog yazınız kaydedildi!')),
      );

      _titleController.clear();
      _quillController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ekran genişliğini alarak responsive tasarım için kullanacağız
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        title: Text(
          'Yeni Blog Yazısı',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF76ABAE),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Başlık Alanı
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF393E46),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.white70, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Color(0xFF76ABAE), width: 2.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // Zengin Metin Düzenleyici
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF393E46),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.white70),
                    ),
                    child: Column(
                      children: [
                        // Toolbar'ı Theme ile sararak ikon ve metin renklerini beyaz yapıyoruz
                        Theme(
                          data: Theme.of(context).copyWith(
                            iconTheme: IconThemeData(color: Colors.white),
                            textTheme: TextTheme(
                              bodyMedium: TextStyle(color: Colors.white),
                            ),
                          ),
                          child: QuillToolbar.simple(
                            controller: _quillController,
                            configurations: QuillSimpleToolbarConfigurations(
                              color: Color(0xFF393E46), // Toolbar arka plan rengi
                              showBoldButton: true,
                              showItalicButton: true,
                              showUnderLineButton: true,
                              showStrikeThrough: true,
                              showListBullets: true,
                              showListNumbers: true,
                              showLink: true,
                              showUndo: true,
                              showRedo: true,
                              // İhtiyacınıza göre diğer butonları da ekleyebilir veya kaldırabilirsiniz
                            ),
                          ),
                        ),
                        Container(
                          height: 400,
                          padding: EdgeInsets.all(12.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            configurations: QuillEditorConfigurations(
                              scrollable: true,
                              autoFocus: false,
                              expands: false,
                              padding: EdgeInsets.zero,
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // Resim Ekleme Butonu
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text(
                      'Resim Ekle',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF76ABAE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // Gönder Butonu
                  ElevatedButton(
                    onPressed: _saveBlogPost,
                    child: Text(
                      'Gönder',
                      style: TextStyle(
                        fontSize: screenWidth < 800 ? 16.0 : 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF76ABAE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF222831),
    );
  }
}
