import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ozel_ders/Components/LoadingIndicator.dart';
import 'dart:html' as html;
import 'package:ozel_ders/services/JitsiService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

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
  bool isPersonalCheck = false;
  bool hasStudentPersonalCheck = false;

  // Tasarım şeması renkleri
  final Color _primaryColor = Color(0xFFA7D8DB);
  final Color _backgroundColor = Color(0xFFEEEEEE);
  final Color _darkColor = Color(0xFF3C72C2);
  final Color _textColor = Color(0xFF222831);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    appData = await FirestoreService().getAppointmentByUID(widget.appointmentUID);
    courseData = await FirestoreService().getCourseByUID(appData["courseID"]);
    authorData = await FirestoreService().getTeacherByUID(appData["author"]);
    studentData = await FirestoreService().getStudentByUID(appData["student"]);
    surveys = await FirestoreService().getAppointmentSurveys(widget.appointmentUID);
    isPersonalCheck = courseData["category"] == "ORo10XNqzYkLcQUl420k";
    hasStudentPersonalCheck = studentData["hasPersonalCheck"];
    isLoading = false;
    time = appData["date"] as Timestamp;
    isAccepted = appData["isAccepted"];
    DateTime date = time.toDate();
    dateStr = dateFormatter.format(date);
    setState(() {});
  }

  // ===================== MODAL & DİĞER YARDIMCI METODLAR =====================

  Widget _buildListTile(IconData icon, String title, String subtitle,
      {Color? subtitleColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: _primaryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, color: _textColor.withOpacity(0.8)),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 18, color: subtitleColor ?? _textColor),
      ),
      onTap: onTap,
    );
  }

  Widget _buildListTileWithTap(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return _buildListTile(icon, title, subtitle, onTap: onTap);
  }

  // ===================== MODAL GÖSTERİMLERİ =====================

  void _showAppointmentDetails(BuildContext context) {
    String enterButtonText = "";
    DateTime date = time.toDate();
    DateTime maxDate = date.add(Duration(hours: 1));
    DateTime minDate = date.subtract(Duration(minutes: 10));
    bool canEnter = true;
    bool shouldCreate = false;

    String noteButtonText = "";
    String homeworkButtonText = "";
    String note = appData["note"] ?? "";
    String homework = appData["homework"] ?? "";
    List<dynamic> homeworkFiles = appData["homeworkFiles"] ?? [];

    if (isAccepted) {
      if (DateTime.now().isBefore(minDate)) {
        canEnter = false;
        enterButtonText = "Randevu Saati Henüz Gelmedi";
      } else {
        if (widget.isTeacher) {
          if (DateTime.now().isBefore(maxDate)) {
            if ((appData["meetingURL"] ?? "").toString().isNotEmpty) {
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
            if ((appData["meetingURL"] ?? "").toString().isNotEmpty) {
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
    } else {
      canEnter = false;
      enterButtonText = "Bu Randevu Henüz Onaylanmadı";
    }

    if (homework.trim().isNotEmpty || homeworkFiles.isNotEmpty) {
      homeworkButtonText = widget.isTeacher ? "Ödevi Düzenle" : "Ödevi Görüntüle";
    } else {
      homeworkButtonText = widget.isTeacher ? "Ödev Ekle" : "Ödev Yok";
    }

    noteButtonText = note.trim().isEmpty ? "Randevuya Not Ekle" : "Randevu Notunu Düzenle";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          borderRadius: 20,
          blur: 30,
          border: 0,
          linearGradient: LinearGradient(
            colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Seçiliyse gradient ekle
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              ,
          borderGradient: LinearGradient(
            colors: [Colors.white24, Colors.white12],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Randevu Bilgileri',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Divider(color: _textColor.withOpacity(0.5)),
                SizedBox(height: 16),
                _buildListTile(Icons.book, 'Kurs', courseData['name'] ?? ''),
                _buildListTileWithTap(Icons.person, 'Eğitmen', authorData['name'] ?? '', () {
                  context.go('/profile/${authorData["UID"]}');
                }),
                _buildListTileWithTap(Icons.person_outline, 'Öğrenci', studentData['name'] ?? '', () {
                  context.go('/profile/${studentData["UID"]}');
                }),
                _buildListTile(Icons.calendar_today, 'Tarih ve Saat', isAccepted ? dateStr : "Eğitmen Henüz Tarih Seçmedi"),
                _buildListTile(Icons.check_circle, 'Onaylanma Durumu', isAccepted ? "Onaylandı" : "Henüz Onaylanmadı",
                    subtitleColor: isAccepted ? Colors.green : Colors.red),
                _buildListTile(
                  Icons.poll,
                  'Anketler',
                  surveys.isEmpty
                      ? (widget.isTeacher ? "Anket Ekle" : "Henüz Anket Yok")
                      : (widget.isTeacher
                      ? "Anketi Gör"
                      : surveys.any((survey) => (survey["answers"] as List).isEmpty)
                      ? "Anketi Cevaplamak İçin Tıkla"
                      : "Anket Cevaplarını Düzenle"),
                  onTap: surveys.isEmpty
                      ? (widget.isTeacher ? () => _showAppointmentSurveyDetails(context) : null)
                      : () => _showAppointmentSurveyDetails(context),
                ),
                if (isPersonalCheck)
                  _buildListTile(
                    Icons.check_circle,
                    "Bireysel Değerlendirme",
                    widget.isTeacher
                        ? "Danışanı 'Bireysel Değerlendirme Aldı' Olarak İşaretle"
                        : (hasStudentPersonalCheck ? "Bireysel Değerlendirmeniz Onaylandı" : "Bireysel Değerlendirmeniz Henüz Onaylanmadı"),
                    onTap: () async {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.noHeader,
                        animType: AnimType.bottomSlide,
                        btnCancelText: "Hayır",
                        btnOkText: "Evet",
                        title: 'Bireysel Değerlendirmeyi Onaylıyor Musunuz?',
                        desc:
                        "Lütfen bireysel değerlendirme tamamlanmadıysa onaylamayınız. Hatalı veya kasıtlı yanlış kullanımlar cezai sonuçlar doğurabilir.",
                        btnOkOnPress: () async {
                          LoadingIndicator(context).showLoading();
                          await FirestoreService().studentHadPersonalCheck(studentData["UID"]);
                          Navigator.pop(context);
                        },
                        btnCancelOnPress: () {},
                      ).show();
                    },
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canEnter ? _primaryColor : Colors.grey[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: canEnter
                      ? () async {
                    String url = "";
                    if (shouldCreate) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: LoadingAnimationWidget.twistingDots(
                              leftDotColor: _backgroundColor,
                              rightDotColor: _darkColor,
                              size: 100,
                            ),
                          );
                        },
                      );
                      url = (await JitsiService().createMeeting())!;
                      await FirestoreService().updateAppointmentUrl(widget.appointmentUID, url);
                      appData["meetingURL"] = url;
                      Navigator.pop(context); // yüklenme animasyonunu kapat
                      Navigator.pop(context); // modalı kapat
                      html.window.open(url, "Redirecting...");
                    } else {
                      url = appData["meetingURL"];
                      Navigator.pop(context);
                      html.window.open(url, "Redirecting...");
                    }
                  }
                      : null,
                  child: Text(
                    enterButtonText,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: homeworkButtonText == "Ödev Yok" ? _primaryColor : Colors.grey[600],
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _showHomeworkDetails(context);
                  },
                  child: Text(
                    homeworkButtonText,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.isTeacher) ...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _showNoteDetails(context);
                    },
                    child: Text(
                      noteButtonText,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
        existingFiles.add(ExistingFile(name: fileName, url: file));
      } else if (file is Map<String, dynamic>) {
        existingFiles.add(ExistingFile(name: file['name'] ?? 'Unknown', url: file['url'] ?? ''));
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arkaplan transparan
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradyan renkleri
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Köşeleri yuvarlak yapıyoruz
          ),
          child: widget.isTeacher
              ? _buildTeacherView(context, homework, existingFiles)
              : _buildStudentView(context, homework, existingFiles),
        );
      },
    );
  }

  Widget _buildTeacherView(BuildContext context, String homework, List<ExistingFile> existingFiles) {
    TextEditingController _homeworkController = TextEditingController(text: homework);
    List<PlatformFile> newFiles = [];
    List<String> deletedFiles = [];

    Future<void> _pickFiles(StateSetter setModalState) async {
      LoadingIndicator(context).showLoading();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: kIsWeb,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'xlsx', 'png', 'jpg'],
      );
      if (result != null) {
        List<PlatformFile> selectedFiles =
        result.files.where((file) => file.size <= 20 * 1024 * 1024).toList();
        newFiles.addAll(selectedFiles);
        if (selectedFiles.length < result.files.length) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("20MB'dan büyük dosyalar atlandı.")));
        }
      }
      setModalState(() {});
      Navigator.pop(context);
    }

    Future<void> _uploadFiles() async {
      try {
        String storageFolder = "/appointment_homeworks/${appData["UID"]}/";
        List<String> uploadedFileUrls = [];
        LoadingIndicator(context).showLoading();

        for (var file in newFiles) {
          try {
            String fileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + file.name;
            Reference ref = FirebaseStorage.instance.ref().child('$storageFolder$fileName');
            UploadTask uploadTask;
            if (kIsWeb) {
              if (file.bytes != null) {
                uploadTask = ref.putData(file.bytes!);
              } else {
                continue;
              }
            } else {
              if (file.path != null) {
                File fileToUpload = File(file.path!);
                uploadTask = ref.putFile(fileToUpload);
              } else {
                continue;
              }
            }
            TaskSnapshot snapshot = await uploadTask;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            uploadedFileUrls.add(downloadUrl);
          } catch (e) {
            print('Dosya yüklenirken hata: $e');
          }
        }

        for (var fileUrl in deletedFiles) {
          try {
            Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
            await ref.delete();
          } catch (e) {
            print('Dosya silinirken hata: $e');
          }
        }

        List<String> allFiles = existingFiles
            .map((file) => file.url)
            .toList()
            .where((url) => !deletedFiles.contains(url))
            .toList();
        allFiles.addAll(uploadedFileUrls);

        await FirestoreService().addHomeworkToAppointment(
            widget.appointmentUID, appData["author"], appData["student"], _homeworkController.text, allFiles);
        await getData();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ödev güncellendi ve dosyalar yüklendi.")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dosya yüklenirken hata: $e")));
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          borderRadius: 20,
          blur: 30,
          border: 0,
          linearGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white24, Colors.white12],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ödev Ekleme / Düzenleme',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _homeworkController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: "Ödevinizi buraya girin...",
                    filled: true,
                    fillColor: _backgroundColor.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.poppins(color: _textColor),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _backgroundColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: _darkColor),
                        onPressed: () => _pickFiles(setModalState),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Belge Ekle",
                        style: GoogleFonts.poppins(color: _darkColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                _buildFileList(context, existingFiles, newFiles, deletedFiles, setModalState),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await _uploadFiles();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Ödevi Güncelle",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
    return GlassmorphicContainer(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      borderRadius: 20,
      blur: 30,
      border: 0,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white24, Colors.white12],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödev Detayları',
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
          ),
          SizedBox(height: 16),
          Text(
            homework,
            style: GoogleFonts.poppins(color: _textColor, fontSize: 16),
          ),
          SizedBox(height: 16),
          if (existingFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Eklenen Belgeler",
                  style: GoogleFonts.poppins(color: _darkColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...existingFiles.map((file) => InkWell(
                  onTap: () async {
                    await launchUrl(Uri.parse(file.url));
                  },
                  child: Text(
                    file.name,
                    style: GoogleFonts.poppins(color: _primaryColor, decoration: TextDecoration.underline),
                  ),
                )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, List<ExistingFile> existingFiles, List<PlatformFile> newFiles,
      List<String> deletedFiles, StateSetter setModalState) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eklenen Belgeler",
            style: GoogleFonts.poppins(color: _darkColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...existingFiles.map((file) => Chip(
                label: Text(file.name, style: GoogleFonts.poppins(color: _textColor)),
                backgroundColor: _backgroundColor,
                deleteIcon: Icon(Icons.close, color: _darkColor),
                onDeleted: () {
                  setModalState(() {
                    if (file.url.isNotEmpty) {
                      deletedFiles.add(file.url);
                    }
                    existingFiles.remove(file);
                  });
                },
              )),
              ...newFiles.map((file) => Chip(
                label: Text(file.name, style: GoogleFonts.poppins(color: _textColor)),
                backgroundColor: _backgroundColor,
                deleteIcon: Icon(Icons.close, color: _darkColor),
                onDeleted: () {
                  setModalState(() {
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
    String note = (appData["note"] ?? "").trim().isNotEmpty ? appData["note"] : "Bu randevuya not eklemediniz.";
    bool editNote = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            TextEditingController _noteController = TextEditingController(text: note);
            return GlassmorphicContainer(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              borderRadius: 20,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Yeni gradyan renkleri
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Randevu Notu',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    !editNote
                        ? Text(
                      note,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
                      textAlign: TextAlign.center,
                    )
                        : TextFormField(
                      controller: _noteController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: "Notunuzu buraya girin...",
                        filled: true,
                        fillColor: _backgroundColor.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.poppins(color: _textColor),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (editNote) {
                          LoadingIndicator(context).showLoading();
                          await FirestoreService().addNoteToAppointment(
                              widget.appointmentUID, appData["author"], appData["student"], _noteController.text);
                          await getData();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          editNote = true;
                        }
                        setState(() {});
                      },
                      child: Text(
                        editNote ? "Kaydet" : "Notu Güncelle",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAppointmentSurveyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Arkaplan transparan
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Gradyan renkleri
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Köşeleri yuvarlak yapıyoruz
          ),
          child: _buildSurveyListView(context), // Burada modal içeriği
        );
      },
    );
  }

  Widget _buildSurveyListView(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          borderRadius: 20,
          blur: 30,
          border: 0,
          linearGradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white24, Colors.white12],
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isTeacher ? 'Anketler' : 'Anketler',
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 16),
                if (surveys.isEmpty)
                  Text(
                    widget.isTeacher ? "Henüz anket eklenmedi." : "Bu randevuya ait anket yok.",
                    style: GoogleFonts.poppins(fontSize: 18, color: _textColor.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                if (surveys.isNotEmpty)
                  ...surveys.map((survey) {
                    String surveyTitle = survey["surveyName"] ?? "";
                    bool isAnswered = (survey["answers"] as List).isNotEmpty;
                    return ListTile(
                      title: Text(
                        surveyTitle,
                        style: GoogleFonts.poppins(color: _textColor, fontSize: 18),
                      ),
                      subtitle: Text(
                        widget.isTeacher
                            ? (isAnswered ? "Anket cevaplanmış" : "Anket düzenlenebilir")
                            : (isAnswered ? "Cevapları düzenle" : "Anketi cevapla"),
                        style: GoogleFonts.poppins(
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
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _createNewSurvey(context),
                    child: Text(
                      "Yeni Anket Oluştur",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                authorData["UID"],
                studentData["UID"],
                questions,
                _surveyNameController.text,
              );

              await getData();
              Navigator.pop(context);
              Navigator.pop(context);
            }

            return GlassmorphicContainer(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              borderRadius: 20,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Yeni gradyan renkleri
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Yeni Anket Oluştur',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _surveyNameController,
                      decoration: InputDecoration(
                        hintText: "Anket İsmi",
                        filled: true,
                        fillColor: _backgroundColor.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.poppins(color: _textColor),
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
                                  fillColor: _backgroundColor.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                style: GoogleFonts.poppins(color: _textColor),
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
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: addQuestion,
                      child: Text(
                        "Soru Ekle",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: saveSurvey,
                      child: Text(
                        "Anketi Kaydet",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
            return GlassmorphicContainer(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              borderRadius: 20,
              blur: 30,
              border: 0,
              linearGradient: LinearGradient(
                colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Yeni gradyan renkleri
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white24, Colors.white12],
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Anket Detayları",
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
                    ),
                    SizedBox(height: 16),
                    if (answers.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_questionControllers.length, (index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Soru ${index + 1}: ${_questionControllers[index].text}",
                                style: GoogleFonts.poppins(color: _textColor, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Cevap: ${answers[index] ?? 'Cevap yok'}",
                                style: GoogleFonts.poppins(color: Colors.green, fontSize: 14),
                              ),
                              SizedBox(height: 16),
                            ],
                          );
                        }),
                      ),
                    ] else ...[
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
                                    fillColor: _backgroundColor.withOpacity(0.8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: GoogleFonts.poppins(color: _textColor),
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
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          innerSetState(() {
                            _questionControllers.add(TextEditingController());
                            _isMandatory.add(false);
                          });
                        },
                        child: Text(
                          "Soru Ekle",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            questions,
                          );
                          await getData();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Kaydet",
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
    List<dynamic> mandatoryQuestions =
    (survey["questions"] as List).where((q) => q.contains("(-*)")).toList();

    Future<void> saveAnswers() async {
      LoadingIndicator(context).showLoading();
      List<String> answers = _answerControllers.map((controller) => controller.text).toList();

      for (int i = 0; i < mandatoryQuestions.length; i++) {
        if (answers[i].trim().isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Zorunlu soruları doldurmanız gerekiyor.")));
          return;
        }
      }

      await FirestoreService().updateAppointmentSurveyAnswers(
        widget.appointmentUID,
        survey["UID"],
        authorData["UID"],
        studentData["UID"],
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
        return GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          borderRadius: 20,
          blur: 30,
          border: 0,
          linearGradient: LinearGradient(
            colors: [Color(0xFF3C72C2), Color(0xFFA7D8DB)], // Yeni gradyan renkleri
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white24, Colors.white12],
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Anketi Doldur",
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 16),
                Column(
                  children: List.generate(_answerControllers.length, (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey["questions"][index].split(" (-")[0],
                          style: GoogleFonts.poppins(color: _textColor, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _answerControllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "Cevabınızı yazın",
                            filled: true,
                            fillColor: _backgroundColor.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: GoogleFonts.poppins(color: _textColor),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: saveAnswers,
                  child: Text(
                    "Cevapları Kaydet",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== APPOINTMENT CARD =====================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(context),
      child: isLoading
          ? Center(
        child: LoadingAnimationWidget.inkDrop(color: _primaryColor, size: 50),
      )
          : GlassmorphicContainer(
        width: double.infinity,
        height: 300,
        borderRadius: 25,
        blur: 20,
        border: 2,
        // Kart arka planında modern ve hafif renk geçişi kullanılıyor.
        linearGradient: LinearGradient(
          colors: [_primaryColor.withOpacity(0.2), _backgroundColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white24, Colors.white12],
        ),
        child: Column(
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
                  children: (courseData['photos'] as List<dynamic>?)?.map<Widget>((photoUrl) {
                    return Image.network(photoUrl, fit: BoxFit.cover);
                  }).toList() ??
                      [],
                ),
              ),
            ),
            SizedBox(height: 4),
            TextButton(
              child: Text(
                courseData['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width >= 800 ? 20 : 15,
                  color: _darkColor,
                ),
              ),
              onPressed: () {
                context.go('/courses/' + (courseData["UID"] ?? ''));
              },
            ),
            Text(
              authorData["name"] ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width >= 800 ? 15 : 12,
                color: _darkColor,
              ),
            ),
            if (MediaQuery.of(context).size.width >= 800) SizedBox(height: 8),
            if (MediaQuery.of(context).size.width >= 800)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.calendar_month, color: _darkColor),
                  SizedBox(width: 10),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _darkColor,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class ExistingFile {
  final String name;
  final String url;

  ExistingFile({required this.name, required this.url});
}
