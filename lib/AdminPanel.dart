import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html; // HTML dosyasından erişim

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: DefaultTabController(
        length: 6, // 6 koleksiyon: Users, Appointments, Blog, Teachers, Teams
        child: Column(
          children: [
            const TabBar(
              isScrollable: true, // Sekmeler fazla olduğu için kaydırılabilir hale getirir
              tabs: [
                Tab(text: 'Kullanıcılar'),
                Tab(text: 'Randevular'),
                Tab(text: 'Blog'),
                Tab(text: 'Öğretmenler'),
                Tab(text: 'Takımlar'),
                Tab(text: 'Kategoriler'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUsersTab(context),
                  _buildAppointmentsTab(context),
                  _buildBlogTab(context),
                  _buildTeachersTab(context),
                  _buildTeamsTab(context),
                  _buildCategoriesTab(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kullanıcılar Tab
  Widget _buildUsersTab(BuildContext context) {
    return _buildListView(context, 'students', ['name', 'email']);
  }

  // Randevular Tab
  Widget _buildAppointmentsTab(BuildContext context) {
    return _buildListView(context, 'appointments', ['author', 'courseID']);
  }

  // Blog Tab
  Widget _buildBlogTab(BuildContext context) {
    return _buildListView(context, 'blogs', ['title', 'creatorUID']);
  }

  // Öğretmenler Tab
  Widget _buildTeachersTab(BuildContext context) {
    return _buildListView(context, 'teachers', ['name', 'email']);
  }

  // Takımlar Tab
  Widget _buildTeamsTab(BuildContext context) {
    return _buildListView(context, 'teams', ['name', 'email']);
  }
  Widget _buildCategoriesTab(BuildContext context) {
    return categoriesWidget(context,["name","imageUrl"]);
  }

  // Genel Liste Görüntüleyici Widget
  Widget _buildListView(BuildContext context, String collection, List<String> fields) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        var items = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];
            return ListTile(
              title: Text(item[fields[0]] ?? 'Bilinmiyor'), // Örneğin 'name'
              subtitle: Text(item[fields[1]] ?? 'Bilinmiyor'), // Örneğin 'subject'
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Düzenleme Butonu
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog(context, collection, item.id, fields, item.data() as Map<String, dynamic>);
                    },
                  ),
                  // Silme Butonu
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, collection, item.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  // Düzenleme Dialogu

}
void _showEditDialog(BuildContext context, String collection, String docId, List<String> fields, Map<String, dynamic> data) {
  final controllers = fields.map((field) => TextEditingController(text: data[field].toString())).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${collection[0].toUpperCase()}${collection.substring(1)} Düzenle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(fields.length, (index) {
          String type = fields[index].split("-")[0];
          return TextField(
            controller: controllers[index],
            decoration: InputDecoration(labelText: fields[index]),
          );

        }),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final updatedData = {
              for (var i = 0; i < fields.length; i++) fields[i]: controllers[i].text
            };
            FirebaseFirestore.instance.collection(collection).doc(docId).update(updatedData);
            Navigator.of(context).pop();
          },
          child: const Text('Kaydet'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
      ],
    ),
  );
}
void _showDeleteConfirmation(BuildContext context, String collection, String docId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Silme Onayı'),
      content: const Text('Bu öğeyi silmek istediğinizden emin misiniz?'),
      actions: [
        TextButton(
          onPressed: () {
            // Firebase'den belgeyi sil
            FirebaseFirestore.instance.collection(collection).doc(docId).delete();
            Navigator.of(context).pop();
          },
          child: const Text('Sil', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
      ],
    ),
  );
}

Future<void> editSubCategoryName(BuildContext context,categoryID) async {
  final firestore = FirebaseFirestore.instance;

  // Kullanıcıdan kategori seçimi
  String? categoryId = await showDialog<String>(
    context: context,
    builder: (context) {
      TextEditingController categoryController = TextEditingController();
      return AlertDialog(
        title: const Text("Kategori ID'sini girin"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: "Kategori ID"),
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Tamam"),
            onPressed: () {
              Navigator.of(context).pop(categoryController.text);
            },
          ),
        ],
      );
    },
  );

  if (categoryId == null || categoryId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori seçimi gerekli')),
    );
    return;
  }

  // Kullanıcıdan alt kategori ismini düzenlemesi için bilgi alın
  String? subCategoryName = await showDialog<String>(
    context: context,
    builder: (context) {
      TextEditingController nameController = TextEditingController();
      return AlertDialog(
        title: const Text("Yeni Alt Kategori Adı"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Yeni Alt Kategori İsmi"),
        ),
        actions: [
          TextButton(
            child: const Text("İptal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Tamam"),
            onPressed: () {
              Navigator.of(context).pop(nameController.text);
            },
          ),
        ],
      );
    },
  );

  if (subCategoryName == null || subCategoryName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alt kategori adı gerekli')),
    );
    return;
  }

  try {
    // Alt koleksiyonları okuma ve düzenleme
    final subCategoriesRef = firestore
        .collection('categories1')
        .doc(categoryId)
        .collection('subCategories');

    final subCategoriesSnapshot = await subCategoriesRef.get();

    for (var doc in subCategoriesSnapshot.docs) {
      // Alt kategori belgelerindeki 'name' alanını düzenleyin
      await subCategoriesRef.doc(doc.id).update({
        'name': subCategoryName,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alt kategoriler başarıyla güncellendi')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bir hata oluştu: $e')),
    );
  }
}

Future<void> manageSubCategories(BuildContext context, String categoryId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Alt koleksiyonları al
    final subCategoriesRef = firestore
        .collection('categories1')
        .doc(categoryId)
        .collection('subCategories');

    final subCategoriesSnapshot = await subCategoriesRef.get();

    // Alt kategorileri listelemek ve düzenlemek için liste diyaloğu
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController newNameController = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          List<Map<String, dynamic>> subCategories = subCategoriesSnapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name']})
              .toList();

          return AlertDialog(
            title: const Text('Alt Kategorileri Yönet'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mevcut alt kategorileri göster
                  for (var subCategory in subCategories)
                    ListTile(
                      title: TextFormField(
                        initialValue: subCategory['name'],
                        decoration: const InputDecoration(labelText: 'Alt Kategori Adı'),
                        onChanged: (value) {
                          setState(() {
                            subCategory['name'] = value;
                          });
                        },
                      ),
                      trailing: IconButton(onPressed: (){

                        subCategoriesRef.doc(subCategory["id"]).delete();
                        subCategories.remove(subCategory);
                      }, icon: const Icon(Icons.delete)),
                    ),
                  // Yeni alt kategori eklemek için alan
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextField(
                      controller: newNameController,
                      decoration: InputDecoration(
                        labelText: 'Yeni Alt Kategori Ekle',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (newNameController.text.isNotEmpty) {
                              setState(() {
                                subCategoriesRef.add({
                                  'name': newNameController.text,
                                });
                                newNameController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Kaydet'),
                onPressed: () async {
                  // Tüm alt kategorileri güncelle veya ekle
                  if(subCategories.isEmpty){
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tamamlandı.')),
                    );
                  }
                  else{
                    for (var subCategory in subCategories) {
                      if (subCategory['id'] == null) {
                        // Yeni alt kategori ekle
                        await subCategoriesRef.add({
                          'name': subCategory['name'],
                        });
                      } else {
                        // Mevcut alt kategoriyi güncelle
                        await subCategoriesRef
                            .doc(subCategory['id'])
                            .update({'name': subCategory['name']});
                      }
                      Navigator.of(context).pop();

                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alt kategoriler başarıyla güncellendi.')),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bir hata oluştu: $e')),
    );
  }
}

Widget categoriesWidget(context,List<String> fields) {
  return Column(
    children: [
      Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('categories1').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var items = snapshot.data?.docs ?? [];

            final categories = snapshot.data!.docs.map((doc) {
              return doc.data()['name'] as String;
            }).toList();

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Düzenleme Butonu
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, "categories1", items[index].id, fields, items[index].data());
                        },
                      ),
                      // Silme Butonu
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, "categories1", items[index].id);
                        },
                      ),

                      ElevatedButton(
                        onPressed: () {
                          manageSubCategories(context,items[index].id);
                        },
                        child: const Text('Alt Kategorileri Düzenle'),
                        )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      ElevatedButton(
      onPressed: () async {
        await _showAddCategoryDialog(context);

      },
          child: const Text('Add Category')
      )
    ],
  );
}


Future<void> _showAddCategoryDialog(BuildContext context) async {
  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController subCategoryController = TextEditingController();
  final List<String> subCategories = [];
  Uint8List? selectedImageBytes;

  // Kategori adı sor
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Kategori Oluştur'),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(labelText: 'Kategori Adı'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      );
    },
  );

  if (categoryNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori adı boş bırakılamaz')),
    );
    return;
  }

  // Resim seçimi
  final input = html.FileUploadInputElement()..accept = 'image/*';
  final completer = Completer<void>();

  input.onChange.listen((e) async {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);

      reader.onLoadEnd.listen((e) async {
        selectedImageBytes = reader.result as Uint8List?;
        completer.complete();
      });
    }
  });

  input.click();

  await completer.future;

  if (selectedImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bir resim seçmeniz gerekiyor')),
    );
    return;
  }

  // Kullanıcıdan alt kategoriler al
  bool addMore = true;
  while (addMore) {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alt Kategori Ekle'),
          content: TextField(
            controller: subCategoryController,
            decoration: const InputDecoration(labelText: 'Alt Kategori Adı'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );

    if (subCategoryController.text.isNotEmpty) {
      subCategories.add(subCategoryController.text); // Listeye ekle
      subCategoryController.clear();
    }

    // Devam etmek isteyip istemediğini sor
    addMore = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Başka bir alt kategori eklemek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet'),
            ),
          ],
        );
      },
    ) ?? false; // Eğer null dönerse varsayılan değer olarak false
  }

  // Firebase işlemleri
  try {
    // Resmi Firebase Storage'a yükle
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('category_photos/${DateTime.now().toString()}.png');
    await storageRef.putData(selectedImageBytes as Uint8List);
    final imageUrl = await storageRef.getDownloadURL();

    // Kategoriyi ekle
    final categoryDocRef = await FirebaseFirestore.instance.collection('categories1').add({
      'name': categoryNameController.text,
      'imageUrl': imageUrl,
    });

    // Alt kategorileri ekle
    for (String subCategory in subCategories) {
      await categoryDocRef.collection('subCategories').add({
        'name': subCategory,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori ve alt kategoriler başarıyla eklendi')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata oluştu: $e')),
    );
  }
}