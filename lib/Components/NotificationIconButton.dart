import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert_two/cool_alert_two.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:ozel_ders/services/FirebaseController.dart';

// Kullanıcının öğrenci mi öğretmen mi olduğunu belirtmek için enum
enum UserType { student, teacher }

// Bildirim tipine göre başlık almak için fonksiyon
Future<String> getTitle(String type) async {
  switch (type) {
    case 'Invite':
      return "Yeni Davet";
    case 'Meeting':
      return "Yeni Randevu";
    case 'MeetingAccept':
      return "Randevu Kabul Edildi";
    case 'Comment':
      return "Yeni Yorum";
    default:
      return "Bildirim";
  }
}

// Bildirim türüne göre modal içeriğini işlemek için fonksiyonlar
Future<void> handleInvite(BuildContext context, Map<String, dynamic> notification, String userUID) async {
  // Daveti onaylamak için soru tipi dialog gösteriliyor
  AwesomeDialog(
    context: context,
    width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
    dialogType: DialogType.question,
    animType: AnimType.bottomSlide,
    title: 'Davet',
    desc: notification["message"],
    btnOkText: "Tamam",
    btnCancelText: "Yoksay",
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      // Yükleniyor dialog'u gösteriliyor
      AwesomeDialog(
        context: context,
        width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
        dialogType: DialogType.noHeader,
        animType: AnimType.bottomSlide,
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(
                'Daveti kabul ediliyor...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();

      // Async işlemi gerçekleştiriliyor
      bool handled = await FirestoreService().updateReference(userUID, notification["teamUID"]);
      // Yükleniyor dialog'unu kapatıyoruz
      Navigator.of(context, rootNavigator: true).pop();

      // İşlem sonucuna göre success veya error dialog'u gösteriliyor
      if (handled) {
        AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          btnOkText: "Tamam",
          title: 'Başarılı!',
          desc: "Başarıyla Kabul Edildi. Artık ekibin bir parçasısınız.",
          btnOkOnPress: () {},
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          btnOkText: "Tamam",
          title: 'Bir Sorun Oluştu',
          desc: "Davetiye Kabul Edilirken Bir Sorun Oluştu!",
          btnOkOnPress: () {},
        ).show();
      }
    },
  ).show();
}

Future<void> handleMeeting(BuildContext context, Map<String, dynamic> notification) async {
  DateFormat dateFormatter = DateFormat("dd/MM/yyyy - HH:mm");
  var app = await FirestoreService().getAppointmentByUID(notification["appointmentUID"]);
  List<dynamic> timestamps = app["selectedDates"];

  // Tarihlerin doğru şekilde alındığından emin olun
  if (timestamps.length < 1) {
    AwesomeDialog(
      context: context,
      width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Hata',
      desc: "Seçilen tarih sayısı yeterli değil!",
      btnOkOnPress: () {},
    ).show();
    return;
  }

  // Tarihleri formatlama
  String dateStr1 = timestamps[0].toDate().toString();
  String dateStr2 = timestamps[1].toDate().toString();
  String dateStr3 = timestamps[2].toDate().toString();

  String selectedDate = ''; // Başlangıçta hiçbir tarih seçili değil

  AwesomeDialog(
    context: context,
    width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
    dialogType: DialogType.noHeader,
    animType: AnimType.bottomSlide,
    title: 'Yeni Randevu Talebi',
    desc: notification["message"],
    // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
    body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              notification["message"],
              style: TextStyle(fontSize: 16),
            ),            SizedBox(height: 10),
            Text(
              "Aşağıdaki Tarihlerden Birini Seçebilirsiniz",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // İlk Tarih Seçeneği
            ListTile(
              tileColor: Color(0xFF222831),
              leading: Icon(Icons.calendar_today, color: Color(0xFF76ABAE)),
              title: Text(
                'Tarih ve Saat',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              subtitle: Text(
                dateFormatter.format(DateTime.parse(dateStr1)),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              trailing: Radio<String>(
                value: dateStr1,
                groupValue: selectedDate,
                onChanged: (String? value) {
                  setModalState(() {
                    selectedDate = value ?? '';
                  });
                },
              ),
            ),
            // İkinci Tarih Seçeneği
            ListTile(
              tileColor: Color(0xFF222831),
              leading: Icon(Icons.calendar_today, color: Color(0xFF76ABAE)),
              title: Text(
                'Tarih ve Saat',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              subtitle: Text(
                dateFormatter.format(DateTime.parse(dateStr2)),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              trailing: Radio<String>(
                value: dateStr2,
                groupValue: selectedDate,
                onChanged: (String? value) {
                  setModalState(() {
                    selectedDate = value ?? '';
                  });
                },
              ),
            ),
            // Üçüncü Tarih Seçeneği
            ListTile(
              tileColor: Color(0xFF222831),
              leading: Icon(Icons.calendar_today, color: Color(0xFF76ABAE)),
              title: Text(
                'Tarih ve Saat',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              subtitle: Text(
                dateFormatter.format(DateTime.parse(dateStr3)),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              trailing: Radio<String>(
                value: dateStr3,
                groupValue: selectedDate,
                onChanged: (String? value) {
                  setModalState(() {
                    selectedDate = value ?? '';
                  });
                },
              ),
            ),
          ],
        );
      },
    ),
    // Dialog'un altındaki butonlar
    btnOkText: "Seç",
    btnCancelText: "İptal",
    btnOkOnPress: () async {
      if (selectedDate.isNotEmpty) {
        // Yükleniyor dialog'unu göster
        AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
          dialogType: DialogType.noHeader,
          animType: AnimType.bottomSlide,
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(
                  'Randevu kaydediliyor...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
        ).show();

        // Async işlemi gerçekleştir
        bool success = await FirestoreService().acceptAppointmentRequest(
            notification["teacherUID"],
            notification["studentUID"],
            notification["appointmentUID"],
            DateTime.parse(selectedDate));

        // Yükleniyor dialog'unu kapat
        Navigator.of(context, rootNavigator: true).pop();

        // İşlem sonucuna göre dialog göster
        if (success) {
          AwesomeDialog(
            context: context,
            width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Başarılı!',
            desc: "Randevu başarıyla kaydedildi.",
            btnOkText: "Tamam",
            btnOkOnPress: () async {
              Map<String, dynamic> teacher = await FirestoreService().getTeacherByUID(notification["teacherUID"]);
              print(teacher);
              print(teacher["name"]);
              await FirestoreService().sendAppointmentAcceptedToStudent(
                  notification["appointmentUID"],
                  notification["teacherUID"],
                  notification["studentUID"],
                  teacher["name"],
                  dateFormatter.format(DateTime.parse(selectedDate)));
            },
          ).show();
        } else {
          AwesomeDialog(
            context: context,
            width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Bir Sorun Oluştu',
            desc: "Randevu kaydedilirken bir sorun oluştu!",
            btnOkText: "Tamam",
            btnOkOnPress: () {},
          ).show();
        }
      } else {
        // Hiçbir tarih seçilmemişse uyarı göster
        AwesomeDialog(
          context: context,
          width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Uyarı',
          desc: "Lütfen bir tarih seçin.",
          btnOkText: "Tamam",
          btnOkOnPress: () {},
        ).show();
      }
    },
    btnCancelOnPress: () {},
  ).show();
}

Future<void> handleMeetingAccept(BuildContext context, Map<String, dynamic> notification) async {
  AwesomeDialog(
    context: context,
      width: MediaQuery.of(context).size.width < 800 ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width / 1.2,
      dialogType: DialogType.info,
    animType: AnimType.bottomSlide,
    title: 'Randevu Kabul Edildi',
    desc: notification["message"],
    // Body kısmında StatefulBuilder kullanarak dinamik içerik oluşturuyoruz
    body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              notification["message"],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    ),
    btnOkText: "Tamam",
    btnOkOnPress: (){}
  ).show();
}

Future<void> handleComment(BuildContext context, Map<String, dynamic> notification) async {
  showDialog(
    context: context,
    useRootNavigator: true, // Dialog'un en üstte görünmesini sağlar
    builder: (_) => AlertDialog(
      title: const Text('Yorum'),
      content: Text(notification["message"]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    ),
  );
}

class NotificationIconButtonWithBadge extends StatefulWidget {
  final UserType userType;
  final String userUID;

  NotificationIconButtonWithBadge({
    required this.userType,
    required this.userUID,
  });

  @override
  _NotificationIconButtonWithBadgeState createState() =>
      _NotificationIconButtonWithBadgeState();
}

class _NotificationIconButtonWithBadgeState extends State<NotificationIconButtonWithBadge> {
  List<Map<String, dynamic>> _notifications = [];
  final FirestoreService _firestoreService = FirestoreService();

  final GlobalKey _iconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didUpdateWidget(covariant NotificationIconButtonWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userUID != widget.userUID || oldWidget.userType != widget.userType) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    List<Map<String, dynamic>> notifications = [];
    try {
      if (widget.userType == UserType.teacher) {
        notifications = await _firestoreService.getNotificationsForTeacher(widget.userUID);
      } else {
        notifications = await _firestoreService.getNotificationsForStudent(widget.userUID);
      }
      print('Loaded ${notifications.length} notifications.');
    } catch (e) {
      print('Error loading notifications: $e');
    }

    setState(() {
      _notifications = notifications;
    });
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['hasRead'] = true;
      print('Marked notification as read: ${notification['id']}');
    });

    // Firestore'da güncelleme yap
    String notType = notification['notType'];
    if(notType == "Invite") {
      String teamUID = notification['teamUID'] ?? notification["id"];
      if (widget.userType == UserType.teacher) {
        _firestoreService.markRequestAsReadForTeacher(widget.userUID, teamUID);
      } else {
        _firestoreService.markRequestAsReadForStudent(widget.userUID, teamUID);
      }
    }
    else if(notType == "Meeting"){
      _firestoreService.markAppointmentAsReadForTeacher(widget.userUID, notification["id"]);
    }
    else if(notType == "MeetingAccept"){
      _firestoreService.markAppointmentAcceptedAsReadForStudent(widget.userUID, notification["id"]);
    }
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    String type = notification['notType'];
    switch (type) {
      case 'Invite':
        handleInvite(context, notification, widget.userUID);
        break;
      case 'Meeting':
        handleMeeting(context, notification);
        break;
      case 'MeetingAccept':
        handleMeetingAccept(context, notification);
        break;
      case 'Comment':
        handleComment(context, notification);
        break;
      default:
        break;
    }
  }

  void _showNotificationsMenu() async {
    final RenderBox? renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Menü pozisyonunu belirle
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      0,
    );

    // Menüyi göster
    await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          enabled: false, // Seçilebilir olmasın
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.transparent, // Arka plan rengini belirleyin
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Okunmamış Bildirimler
                if (_notifications.any((n) => n['hasRead'] == false))
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Okunmamış Bildirimler',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                if (_notifications.any((n) => n['hasRead'] == false))
                  Expanded(
                    child: ListView.builder(
                      itemCount: _notifications.where((n) => n['hasRead'] == false).length,
                      itemBuilder: (context, index) {
                        var notification = _notifications.where((n) => n['hasRead'] == false).toList()[index];
                        return ListTile(
                          title: FutureBuilder<String>(
                            future: getTitle(notification['notType'] ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(color: Colors.black),
                                );
                              }
                            },
                          ),
                          trailing: SizedBox(
                            width: 80, // Genişliği ihtiyacınıza göre ayarlayın
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.mark_email_read, color: Colors.green),
                                  onPressed: () {
                                    _markAsRead(notification);
                                    // Menüyü kapatmak için
                                    Navigator.pop(context);
                                  },
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            _markAsRead(notification);
                            Navigator.pop(context); // Menüyü kapat
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _onNotificationTap(notification); // Dialog'u aç
                            });
                          },
                        );
                      },
                    ),
                  ),

                // Okunmuş Bildirimler
                if (_notifications.any((n) => n['hasRead'] == true))
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Okunmuş Bildirimler',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                if (_notifications.any((n) => n['hasRead'] == true))
                  Expanded(
                    child: ListView.builder(
                      itemCount: _notifications.where((n) => n['hasRead'] == true).length,
                      itemBuilder: (context, index) {
                        var notification = _notifications.where((n) => n['hasRead'] == true).toList()[index];
                        return ListTile(
                          title: FutureBuilder<String>(
                            future: getTitle(notification['notType'] ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(color: Colors.black),
                                );
                              }
                            },
                          ),
                          trailing: SizedBox(
                            width: 50, // Genişliği ihtiyacınıza göre ayarlayın
                            child: IconButton(
                              icon: const Icon(Icons.mark_email_unread, color: Colors.grey),
                              onPressed: () {
                                // Okunmuş bildirimi tekrar okunmamış yapabilirsiniz
                                // Örneğin:
                                // _markAsUnread(notification);
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // Menüyü kapat
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _onNotificationTap(notification); // Dialog'u aç
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Okunmamış bildirim sayısını hesapla
    int unreadCount = _notifications.where((notification) => notification['hasRead'] == false).length;

    return IconButton(
      key: _iconKey,
      icon: badges.Badge(
        showBadge: unreadCount > 0,
        badgeContent: Text(
          '$unreadCount',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
        ),
        child: const Icon(Icons.notifications, color: Colors.white),
      ),
      onPressed: () {
        _showNotificationsMenu();
      },
    );
  }
}
