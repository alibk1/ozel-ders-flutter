import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:zefyrka/zefyrka.dart';

class BlogWritePage extends StatefulWidget {
  final String uid;
  final bool isUpdate;
  final String? blogUID;

  BlogWritePage({
    required this.uid,
    this.isUpdate = false,

    this.blogUID,
  });

  @override
  _BlogWritePageState createState() => _BlogWritePageState();
}

class _BlogWritePageState extends State<BlogWritePage> {
  late ZefyrController _zefyrController;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;
  bool inited = false;
  String oldText = "";
  String oldTitle = "";

  // Seçilen resimleri geçici olarak saklamak için bir harita
  Map<String, XFile> _localImages = {};

  @override
  void initState() {
    super.initState();

    if (widget.isUpdate) {
       getTitleAndText();
    } else {
      _zefyrController = ZefyrController();
      inited = true;
      setState(() {

      });
    }
  }

  Future<void> getTitleAndText() async{
    var blog = await FirestoreService().getBlog(widget.blogUID!);
    final document = NotusDocument.fromJson(jsonDecode(blog["content"]));
    _zefyrController = ZefyrController(document);
    _titleController.text = blog["title"];
    inited = true;
    setState(() {

    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      String imageUrl;

      if (UniversalPlatform.isWeb) {
        // Web için base64 kodlu resim kullanıyoruz
        final imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        imageUrl = 'data:image/png;base64,$base64Image';
      } else {
        // Mobilde, resim yolunu kullanıyoruz
        imageUrl = image.path;
      }

      // Resmi editöre ekleme
      final index = _zefyrController.selection.baseOffset;
      final length = _zefyrController.selection.extentOffset - index;
      _zefyrController.replaceText(index, length, BlockEmbed.image(imageUrl));

      // Resmi geçici haritaya ekleme
      _localImages[imageUrl] = image;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _customEmbedBuilder(BuildContext context, EmbedNode node) {
    final String? imageUrl = node.value.data['source'];
    if (node.value.type == 'image' && imageUrl != null) {
      if (_localImages.containsKey(imageUrl)) {
        // Resim geçici olarak saklanıyor
        final imageFile = _localImages[imageUrl];
        if (UniversalPlatform.isWeb) {
          // Web için base64 görüntüyü gösterme
          final base64Image = imageUrl.split(',')[1];
          final imageBytes = base64Decode(base64Image);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.memory(imageBytes),
          );
        } else {
          // Mobil için resim dosyasını gösterme
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.file(File(imageUrl)),
          );
        }
      } else {
        // Resim URL'si zaten uzaktan bir URL
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.network(imageUrl),
        );
      }
    }
    throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by the custom embed builder.');
  }

  void _saveBlogPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Dokümanı JSON olarak alıyoruz
      var docJson = _zefyrController.document.toJson();

      // Yerel resimleri yükleyip URL'leri güncelliyoruz
      await _uploadImagesAndReplaceUrls(docJson);

      // Güncellenmiş dokümanı JSON stringine çeviriyoruz
      String contentJson = jsonEncode(docJson);

      // isUpdate değerine göre Firestore işlemi
      if (widget.isUpdate) {
        // Blog güncelleme
        await FirestoreService().updateBlogDetails(
          widget.blogUID!,
          _titleController.text,
          contentJson,
        );
      } else {
        // Yeni blog oluşturma
        await FirestoreService().createBlog(
          widget.uid,
          _titleController.text,
          contentJson,
        );
      }

      // Başarılı mesajı ve geri dönüş
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog başarıyla kaydedildi.')),
      );
      Navigator.of(context).pop();

    } catch (e) {
      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImagesAndReplaceUrls(dynamic content) async {
    if (content is List) {
      for (var item in content) {
        await _uploadImagesAndReplaceUrls(item);
      }
    } else if (content is Map) {
      if (content.containsKey('insert') && content['insert'] is Map) {
        var insertContent = content['insert'];
        if (insertContent.containsKey('image')) {
          String imageUrl = insertContent['image'];
          if (_localImages.containsKey(imageUrl)) {
            // Resmi Firebase Storage'a yüklüyoruz
            String remoteUrl = await _uploadImage(_localImages[imageUrl]!);
            // URL'yi güncelliyoruz
            insertContent['image'] = remoteUrl;
          }
        }
      }
      // Haritadaki değerleri yinelemeli olarak işliyoruz
      for (var value in content.values) {
        await _uploadImagesAndReplaceUrls(value);
      }
    }
  }

  Future<String> _uploadImage(XFile imageFile) async {
    String imageUrl;
    if (UniversalPlatform.isWeb) {
      // Web için resim baytlarını yüklüyoruz
      final imageBytes = await imageFile.readAsBytes();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('blog_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await snapshot.ref.getDownloadURL();
    } else {
      // Mobil için dosyayı yüklüyoruz
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('blog_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
      final uploadTask = storageRef.putFile(File(imageFile.path));
      final snapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await snapshot.ref.getDownloadURL();
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        title: Text(
          widget.isUpdate ? 'Blog Yazısını Düzenle' : 'Yeni Blog Yazısı',
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
              constraints: BoxConstraints(maxWidth: screenWidth - 20),
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
                        borderSide: BorderSide(
                            color: Colors.white70, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: Color(0xFF76ABAE), width: 2.0),
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
                    child:inited
                        ? ZefyrTheme(
                        data : ZefyrThemeData(
                          bold: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          italic: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          underline: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                          ),
                          strikethrough: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white,
                          ),
                          link: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                          paragraph: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            spacing: VerticalSpacing(),
                          ),
                          heading1: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            spacing: VerticalSpacing(),
                          ),
                          heading2: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            spacing: VerticalSpacing(),
                          ),
                          heading3: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                            spacing: VerticalSpacing(),
                          ),
                          lists: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            spacing: VerticalSpacing(),
                          ),
                          quote: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                            spacing: VerticalSpacing(),
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: Colors.grey, width: 4.0)),
                            ),
                          ),
                          code: TextBlockTheme(
                            style: TextStyle(
                              color: Colors.green,
                              fontFamily: 'Courier',
                              fontSize: 14,
                            ),
                            spacing: VerticalSpacing(),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                        child: Column(
                        children: [
                          ZefyrToolbar.basic(controller: _zefyrController),
                          Container(
                            height: 600,
                            padding: EdgeInsets.all(12.0),
                            child: ZefyrEditor(
                              controller: _zefyrController,
                              focusNode: FocusNode(),
                              scrollable: true,
                              padding: EdgeInsets.zero,
                              embedBuilder: _customEmbedBuilder,
                            ),
                          ),
                        ],
                      ),
                    )
                        : SizedBox.shrink(),
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
