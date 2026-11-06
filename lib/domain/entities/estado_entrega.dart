class EstadoEntrega {
  final int minutosRestantes;
  final double latitud;
  final double longitud;
  final String mensaje;

  const EstadoEntrega({
    required this.minutosRestantes,
    required this.latitud,
    required this.longitud,
    required this.mensaje,
  }) : assert(minutosRestantes >= 0);

  bool get entregado => minutosRestantes == 0;
}
