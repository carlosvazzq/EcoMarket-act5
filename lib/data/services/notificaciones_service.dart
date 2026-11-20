import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionesService {
  NotificacionesService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    _inicializado = true;
  }

  Future<void> mostrarNotificacionCompra(double totalPagado) async {
    await inicializar();

    const androidDetails = AndroidNotificationDetails(
      'canal_ecomarket_pedidos',
      'Confirmación de Pedidos',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 0,
      title: 'Compra confirmada',
      body: 'Total pagado: \$${totalPagado.toStringAsFixed(2)}',
      notificationDetails: details,
    );
  }
}
