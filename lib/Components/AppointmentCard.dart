import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'package:ozel_ders/services/FirebaseController.dart';
import 'dart:html' as html;

import 'package:ozel_ders/services/JitsiService.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentCard extends StatefulWidget {
  final String appointmentUID;
  final bool isTeacher;

  AppointmentCard({
    required this.appointmentUID,
    required this.isTeacher,
  });

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool isLoading = true;
  Map<String, dynamic> appData = {};
  Map<String, dynamic> courseData = {};
  Map<String, dynamic> authorData = {};
  Map<String, dynamic> studentData = {};
  DateFormat dateFormatter = DateFormat("dd/MM/yyyy - HH:mm");
  List<Map<String, dynamic>> surveys = [];
  String dateStr = "";
  late Timestamp time;
  bool isAccepted = false;
  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  Future<void> getData() async {
    appData = await FirestoreService().getAppointmentByUID(widget.appointmentUID);
    courseData = await FirestoreService().getCourseByUID(appData["courseID"]);
    authorData = await FirestoreService().getTeacherByUID(appData["author"]);
    studentData = await FirestoreService().getStudentByUID(appData["student"]);
    surveys = await FirestoreService().getAppointmentSurveys(widget.appointmentUID);
    isLoading = false;
    time = appData["date"] as Timestamp;
    isAccepted = appData["isAccepted"];
    DateTime date = time.toDate();
    dateStr = dateFormatter.format(date);
    setState(() {});
  }

  void _showAppointmentDetails(BuildContext context) {
    String enterButtonText = "";
    DateTime date = time.toDate();
    DateTime maxDate = date.add(Duration(hours: 1));
    DateTime minDate = date.add(Duration(minutes: -10));
    bool canEnter = true;
    bool shouldCreate = false;
    bool editNote = false;

    String noteButtonText = "";
    String homeworkButtonText = "";
    String note = appData["note"];
    String homework = appData["homework"];
    List<dynamic> homeworkFiles = appData["homeworkFiles"];

    if (isAccepted) {
      if (DateTime.now().isBefore(minDate)) {
        canEnter = false;
        enterButtonText = "Randevu Saati Henüz Gelmedi";
      } else {
        if (widget.isTeacher) {
          if (DateTime.now().isBefore(maxDate)) {
            if (appData["meetingURL"] != "") {
              enterButtonText = "Randevuya Katıl";
            } else {
              enterButtonText = "Randevu Oluştur";
              shouldCreate = true;
            }
          } else {
            canEnter = false;
            enterButtonText = "Bu Randevuya Artık Girilemez";
          }
        } else {
          if (DateTime.now().isBefore(maxDate)) {
            if (appData["meetingURL"] != "") {
              enterButtonText = "Randevuya Katıl";
            } else {
              canEnter = false;
              enterButtonText = "Bu Randevuya Henüz Girilemez";
            }
          } else {
            canEnter = false;
            enterButtonText = "Bu Randevuya Artık Girilemez";
          }
        }
      }
    }
    else {
      canEnter = false;
      enterButtonText = "Bu Randevu Henüz Onaylanmadı";
    }

    if (homework
        .trim()
        .isNotEmpty || homeworkFiles.isNotEmpty) {
      if (widget.isTeacher) {
        homeworkButtonText = "Ödevi Düzenle";
      }
      else {
        homeworkButtonText = "Ödevi Görüntüle";
      }
    }
    else {
      if (widget.isTeacher) {
        homeworkButtonText = "Ödev Ekle";
      }
      else {
        homeworkButtonText = "Ödev Yok";
      }
    }

    if(note.trim().isEmpty){
      noteButtonText = "Randevuya Not Ekle";
    }
    else{
      noteButtonText = "Randevu Notunu Düzenle";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Randevu Bilgileri',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white54),
                SizedBox(height: 16),
                // Kurs Bilgileri
                ListTile(
                  leading: Icon(Icons.book, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Kurs',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    courseData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Eğitmen',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    authorData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onTap: () {
                    context.go('/profile/${authorData["uid"]}');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Öğrenci',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    studentData['name'],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onTap: () {
                    context.go('/profile/${studentData["uid"]}');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Tarih ve Saat',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    isAccepted ? dateStr : "Eğitimci Henüz Tarih Seçmedi",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Onaylanma Durumu',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    isAccepted ? "Onaylandı" : "Henüz Onaylanmadı",
                    style: TextStyle(fontSize: 18,
                        color: isAccepted ? Colors.green : Colors.red),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.poll, color: Color(0xFF76ABAE)),
                  title: Text(
                    'Anketler',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  subtitle: Text(
                    surveys.isEmpty
                        ? widget.isTeacher
                        ? "Anket Ekle"
                        : "Henüz Anket Yok"
                        : widget.isTeacher
                        ? "Anketi Gör"
                        : surveys.any((survey) => survey["answers"].isEmpty)
                        ? "Anketi Cevaplamak İçin Tıkla"
                        : "Anket Cevaplarını Düzenle",
                    style: TextStyle(
                      fontSize: 18,
                      color: surveys.isEmpty
                          ? Colors.grey
                          : widget.isTeacher
                          ? Colors.blue
                          : surveys.any((survey) => survey["answers"].isEmpty)
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  onTap: surveys.isEmpty
                      ? widget.isTeacher
                      ? () => _showAppointmentSurveyDetails(context)
                      : null
                      : () => _showAppointmentSurveyDetails(context),
                ),

                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    canEnter ? Color(0xFF76ABAE) : Colors.grey[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: canEnter
                      ? () async {
                    String url = "";
                    if (shouldCreate) {
                      // Yükleniyor animasyonu
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: LoadingAnimationWidget.twistingDots(
                                leftDotColor: Color(0xFF222831),
                                rightDotColor: Color(0xFF663366),
                                size: 100),
                          );
                        },
                      );

                      url = (await JitsiService().createMeeting())!;
                      await FirestoreService().updateAppointmentUrl(
                          widget.appointmentUID, url);
                      appData["meetingURL"] = url;
                      Navigator.pop(context); // Yükleniyor animasyonunu kapat
                      Navigator.pop(context); // Modal'ı kapat
                      html.window.open(url, "Redirecting...");
                    } else {
                      url = appData["meetingURL"];
                      Navigator.pop(context); // Modal'ı kapat
                      html.window.open(url, "Redirecting...");
                    }
                  }
                      : null,
                  child: Text(
                    enterButtonText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    homeworkButtonText == "Ödev Yok"
                        ? Color(0xFF76ABAE)
                        : Colors.grey[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showHomeworkDetails(context);
                  },
                  child: Text(
                    homeworkButtonText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if(widget.isTeacher)...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF76ABAE),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _showNoteDetails(context);
                    },
                    child: Text(
                      noteButtonText,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHomeworkDetails(BuildContext context) {
    String homework = appData["homework"] ?? "";
    List<dynamic> homeworkFiles = appData["homeworkFiles"] ?? [];
    List<ExistingFile> existingFiles = [];

    for (var file in homeworkFiles) {
      if (file is String && file.contains('https://firebasestorage.googleapis.com')) {
        String fileName = Uri.decodeComponent(file.split('/').last.split('?').first.split('%2F').last);
        existingFiles.add(ExistingFile(
          name: fileName,
          url: file,
        ));
      } else if (file is Map<String, dynamic>) {
        existingFiles.add(ExistingFile(
          name: file['name'] ?? 'Unknown',
          url: file['url'] ?? '',
        ));
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        if (widget.isTeacher) {
          return _buildTeacherView(context, homework, existingFiles, setState);
        } else {
          return _buildStudentView(context, homework, existingFiles);
        }
      },
    );
  }

  Widget _buildTeacherView(BuildContext context, String homework, List<ExistingFile> existingFiles, StateSetter setModalState) {
    TextEditingController _homeworkController = TextEditingController(text: homework);
    List<PlatformFile> newFiles = [];
    List<String> deletedFiles = [];

    Future<void> _pickFiles() async {
      LoadingIndicator(context).showLoading();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: kIsWeb,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'xlsx', 'png', 'jpg'],
      );

      if (result != null) {
        List<PlatformFile> selectedFiles = result.files.where((file) =>
        file.size <= 20 * 1024 * 1024).toList();
        newFiles.addAll(selectedFiles);

        if (selectedFiles.length < result.files.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("20MB'dan büyük dosyalar atlandı.")),
          );
        }
      }
      setModalState((){});
      Navigator.pop(context);
    }

    Future<void> _uploadFiles() async {
      try {
        String storageFolder = "/appointment_homeworks/${appData["uid"]}/";
        List<String> uploadedFileUrls = [];
        LoadingIndicator(context).showLoading();

        for (var file in newFiles) {
          print("ANAN");
          try {
            String fileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + file.name;
            print(fileName);
            Reference ref = FirebaseStorage.instance.ref().child('$storageFolder$fileName');
            UploadTask uploadTask;

            if (kIsWeb) {
              if (file.bytes != null) {
                uploadTask = ref.putData(file.bytes!);
              } else {
                print('Web platformunda bytes null. Dosya atlanıyor: ${file.name}');
                continue;
              }
            } else {
              if (file.path != null) {
                File fileToUpload = File(file.path!);
                uploadTask = ref.putFile(fileToUpload);
              } else {
                // Mobil veya masaüstü platformlarda path null ise atla veya hata bildir
                print('Path null. Dosya atlanıyor: ${file.name}');
                continue;
              }
            }
            TaskSnapshot snapshot = await uploadTask;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            uploadedFileUrls.add(downloadUrl);
            print('Yüklenen dosya URL: $downloadUrl');
          } catch (e) {
            print('Dosya yüklenirken hata oluştu: $e');
          }
        }

        for (var fileUrl in deletedFiles) {
          try {
            Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
            await ref.delete();
            print('Silinen dosya URL: $fileUrl');
          } catch (e) {
            print('Dosya silinirken hata oluştu: $e');
          }
        }

        // allFiles listesini oluştur
        List<String> allFiles = existingFiles
            .map((file) => file.url)
            .toList()
            .where((url) => !deletedFiles.contains(url))
            .toList();

        allFiles.addAll(uploadedFileUrls);

        print('Tüm Dosyaların URL\'leri:');
        allFiles.forEach((url) => print(url));
        await FirestoreService().addHomeworkToAppointment(widget.appointmentUID, appData["author"], appData["student"], _homeworkController.text, allFiles);
        await getData();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ödev güncellendi ve dosyalar yüklendi.")),
        );
      } catch (e) {
        print('Dosya yüklenirken genel bir hata oluştu: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Dosya yüklenirken hata oluştu: $e")),
        );
      } finally {
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ödev Ekleme / Düzenleme',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _homeworkController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: "Ödevinizi buraya girin...",
                    filled: true,
                    fillColor: Color(0xFF393E46),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF393E46),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.white),
                        onPressed: _pickFiles,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Belge Ekle",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildFileList(context, existingFiles, newFiles, deletedFiles, setState),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF76ABAE),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await _uploadFiles();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Ödevi Güncelle",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentView(BuildContext context, String homework, List<ExistingFile> existingFiles) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF222831),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödev Detayları',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            homework,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 16),
          if (existingFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Eklenen Belgeler",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...existingFiles.map((file) => InkWell(
                  onTap: () async {
                    await launchUrl(Uri.parse(file.url));
                  },
                  child: Text(
                    file.name,
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<ExistingFile> existingFiles, List<PlatformFile> newFiles, List<String> deletedFiles, StateSetter setState) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eklenen Belgeler",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...existingFiles.map((file) => Chip(
                label: Text(file.name),
                backgroundColor: Colors.grey[700],
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    if (file.url.isNotEmpty) {
                      deletedFiles.add(file.url);
                    }
                    existingFiles.remove(file);
                  });
                },
              )),
              ...newFiles.map((file) => Chip(
                label: Text(file.name),
                backgroundColor: Colors.blueGrey,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () {
                  setState(() {
                    newFiles.remove(file);
                  });
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoteDetails(BuildContext context) {
    String note = appData["note"].trim().isNotEmpty ? appData["note"] : "Bu randevuya not eklemediniz.";
    bool editNote = false;

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              TextEditingController _noteController =
              TextEditingController(text: note);
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF222831),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Randevu Notu',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      !editNote ? Text(
                        note,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ) :
                      TextFormField(
                        controller: _noteController,
                        maxLines: 7,
                        decoration: InputDecoration(
                          hintText: "Notunuzu buraya girin...",
                          filled: true,
                          fillColor: Color(0xFF393E46),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.all(16.0),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF76ABAE),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if(editNote){
                            LoadingIndicator(context).showLoading();
                            await FirestoreService().addNoteToAppointment(widget.appointmentUID, appData["author"], appData["student"], _noteController.text);
                            await getData();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                          else {
                            editNote = true;
                          }
                          setState((){});
                        },
                        child: Text(
                          editNote ? "Kaydet" : "Notu Güncelle",
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _showAppointmentSurveyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildSurveyListView(context);
      },
    );
  }

  Widget _buildSurveyListView(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isTeacher ? 'Anketler' : 'Anketler',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                if (surveys.isEmpty)
                  Text(
                    widget.isTeacher ? "Henüz anket eklenmedi." : "Bu randevuya ait anket yok.",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                if (surveys.isNotEmpty)
                  ...surveys.map((survey) {
                    String surveyTitle = survey["surveyName"];
                    bool isAnswered = (survey["answers"] as List).isNotEmpty;

                    return ListTile(
                      title: Text(
                        surveyTitle,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: Text(
                        widget.isTeacher
                            ? (isAnswered ? "Anket cevaplanmış" : "Anket düzenlenebilir")
                            : (isAnswered ? "Cevapları düzenle" : "Anketi cevapla"),
                        style: TextStyle(
                          color: isAnswered ? Colors.green : Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        if (widget.isTeacher) {
                          _buildTeacherSurveyView(context, survey, setModalState);
                        } else {
                          _buildStudentSurveyView(context, survey, setModalState);
                        }
                      },
                    );
                  }).toList(),
                if (widget.isTeacher)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF76ABAE),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _createNewSurvey(context),
                    child: Text("Yeni Anket Oluştur",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createNewSurvey(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        TextEditingController _surveyNameController = TextEditingController();
        List<TextEditingController> _questionControllers = [];
        List<bool> _isMandatory = [];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            void addQuestion() {
              _questionControllers.add(TextEditingController());
              print(_questionControllers.length);
              _isMandatory.add(false);
              setModalState(() {});
            }

            Future<void> saveSurvey() async {
              if (_surveyNameController.text.trim().isEmpty || _questionControllers.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Anket ismi ve sorular boş bırakılamaz.")),
                );
                return;
              }

              List<String> questions = [];
              for (int i = 0; i < _questionControllers.length; i++) {
                String suffix = _isMandatory[i] ? "(-*)" : "(--)";
                questions.add("${_questionControllers[i].text} $suffix");
              }
              LoadingIndicator(context).showLoading();
              await FirestoreService().createAppointmentSurvey(
                widget.appointmentUID,
                authorData["uid"],
                studentData["uid"],
                questions,
                _surveyNameController.text,
              );

              await getData();
              Navigator.pop(context);
              Navigator.pop(context);
            }

            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF222831),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Yeni Anket Oluştur',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _surveyNameController,
                      decoration: InputDecoration(
                        hintText: "Anket İsmi",
                        filled: true,
                        fillColor: Color(0xFF393E46),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: List.generate(_questionControllers.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _questionControllers[index],
                                decoration: InputDecoration(
                                  hintText: "Soru ${index + 1}",
                                  filled: true,
                                  fillColor: Color(0xFF393E46),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Checkbox(
                              value: _isMandatory[index],
                              onChanged: (value) {
                                _isMandatory[index] = value!;
                                setModalState(() {});
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: addQuestion,
                      child: Text("Soru Ekle",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF76ABAE),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: saveSurvey,
                      child: Text("Anketi Kaydet",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _buildTeacherSurveyView(BuildContext context, Map<String, dynamic> survey, StateSetter setModalState) {
    List<TextEditingController> _questionControllers = (survey["questions"] as List)
        .map((q) => TextEditingController(text: q.split(" (-")[0]))
        .toList();
    List<dynamic> _isMandatory = (survey["questions"] as List).map((q) => q.contains("(-*)")).toList();
    List<dynamic> answers = survey["answers"] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter innerSetState) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF222831),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Anket Detayları",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    if (answers.isNotEmpty) ...[
                      // Cevaplanmış anketlerin cevaplarını göster
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_questionControllers.length, (index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Soru ${index + 1}: ${_questionControllers[index].text}",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Cevap: ${answers[index] ?? 'Cevap yok'}",
                                style: TextStyle(color: Colors.green, fontSize: 14),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        }),
                      ),
                    ] else ...[
                      // Cevaplanmamış anketleri düzenleme görünümü
                      Column(
                        children: List.generate(_questionControllers.length, (index) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _questionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: "Soru ${index + 1}",
                                    filled: true,
                                    fillColor: Color(0xFF393E46),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Checkbox(
                                value: _isMandatory[index],
                                onChanged: (bool? value) {
                                  innerSetState(() {
                                    _isMandatory[index] = value!;
                                  });
                                },
                              ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF76ABAE),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          innerSetState(() {
                            _questionControllers.add(TextEditingController());
                            _isMandatory.add(false);
                          });
                        },
                        child: Text(
                          "Soru Ekle",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                      //Bir daha aynı dersi almayı düşünüyor musunuz?
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF76ABAE),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          List<String> questions = [];
                          for (int i = 0; i < _questionControllers.length; i++) {
                            String suffix = _isMandatory[i] ? "(-*)" : "(--)";
                            questions.add("${_questionControllers[i].text} $suffix");
                          }
                          LoadingIndicator(context).showLoading();

                          await FirestoreService().updateAppointmentSurveyQuestions(
                              widget.appointmentUID,
                              survey["UID"],
                              appData["author"],
                              appData["student"],
                              questions);
                          await getData();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Kaydet",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _buildStudentSurveyView(BuildContext context, Map<String, dynamic> survey, StateSetter setModalState) {
    List<TextEditingController> _answerControllers = (survey["questions"] as List)
        .map((_) => TextEditingController())
        .toList();
    List<dynamic> mandatoryQuestions = (survey["questions"] as List)
        .where((q) => q.contains("(-*)"))
        .toList();

    Future<void> saveAnswers() async {
      LoadingIndicator(context).showLoading();

      List<String> answers = _answerControllers.map((controller) => controller.text).toList();

      // Zorunlu sorular kontrolü
      for (int i = 0; i < mandatoryQuestions.length; i++) {
        if (answers[i].trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Zorunlu soruları doldurmanız gerekiyor.")),
          );
          return;
        }
      }

      await FirestoreService().updateAppointmentSurveyAnswers(
        widget.appointmentUID,
        survey["UID"],
        authorData["uid"],
        studentData["uid"],
        answers,
      );
      await getData();
      Navigator.pop(context);
      Navigator.pop(context);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Anketi Doldur",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                Column(
                  children: List.generate(_answerControllers.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey["questions"][index].split(" (-")[0],
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _answerControllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Cevabınızı yazın",
                            filled: true,
                            fillColor: Color(0xFF393E46),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF76ABAE),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: saveAnswers,
                  child: Text("Cevapları Kaydet",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), // Yuvarlak köşe
            topRight: Radius.circular(25), // Yuvarlak köşe
            bottomLeft: Radius.circular(25), // Sivri köşe
            bottomRight: Radius.circular(25),
          ),
          side: BorderSide(
            width: 2,
            color: Color(int.parse("#31363F".substring(1, 7), radix: 16) + 0xFF000000),
          ),
        ),
        color: Color(int.parse("#222831".substring(1, 7), radix: 16) + 0xFF000000),
        child: isLoading ? Center(child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50),): Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: PageView(
                  children: courseData['photos'].map<Widget>((photoUrl) {
                    return Image.network(photoUrl, fit: BoxFit.cover);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextButton(
              child: Text(
                courseData['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width >= 800 ? 20 : 15,
                  color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
                ),
              ),
              onPressed: () {
                context.go('/courses/' + courseData["uid"]); // CategoriesPage'e yönlendirme
              },
            ),
            Text(
              authorData["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width >= 800 ? 15 : 12,
                color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
              ),
            ),
            if(MediaQuery.of(context).size.width >= 800) SizedBox(height: 8,),
            if(MediaQuery.of(context).size.width >= 800) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.calendar_month, color: Color(0xFFEEEEEE),),
                SizedBox(width: 10,),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(int.parse("#EEEEEE".substring(1, 7), radix: 16) + 0xFF000000),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}

// Mevcut dosyaları temsil etmek için özel bir sınıf
class ExistingFile {
  final String name;
  final String url;

  ExistingFile({required this.name, required this.url});
}