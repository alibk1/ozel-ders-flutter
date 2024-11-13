import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cool_alert_two/cool_alert_two.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:ozel_ders/FirebaseController.dart';

// Kullanıcının öğrenci mi öğretmen mi olduğunu belirtmek için enum
enum UserType { student, teacher }

// Bildirim tipine göre başlık almak için fonksiyon
Future<String> getTitle(String type) async {
  switch (type) {
    case 'Invite':
      return "Yeni Davet";
    case 'Meeting':
      return "Yeni Toplantı";
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
  showDialog(
    context: context,
    useRootNavigator: true, // Dialog'un en üstte görünmesini sağlar
    builder: (_) => AlertDialog(
      title: const Text('Görüşme'),
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
    String teamUID = notification['teamUID'];
    if (widget.userType == UserType.teacher) {
      _firestoreService.markRequestAsReadForTeacher(widget.userUID, teamUID);
    } else {
      _firestoreService.markRequestAsReadForStudent(widget.userUID, teamUID);
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
