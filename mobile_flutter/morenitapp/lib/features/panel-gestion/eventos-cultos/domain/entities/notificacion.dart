class DestinatarioInfo {
  final int id;
  final String nombre;
  final String email;

  DestinatarioInfo({required this.id, required this.nombre, required this.email});

  factory DestinatarioInfo.fromJson(Map<String, dynamic> json) {
    return DestinatarioInfo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Notificacion {
  final int? id;
  final String asunto;
  final String mensaje;
  final int? tipoId;
  final String? tipoNombre;
  final String? fechaRegistro;
  final List<int> usuarioIds;
  final List<DestinatarioInfo> destinatarios;

  Notificacion({
    this.id,
    required this.asunto,
    required this.mensaje,
    this.tipoId,
    this.tipoNombre,
    this.fechaRegistro,
    this.usuarioIds = const [],
    this.destinatarios = const [],
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      asunto: json['asunto'] ?? '',
      mensaje: json['mensaje'] ?? '',
      tipoId: json['tipoid'],
      tipoNombre: json['tiponombre'] ?? 'Sin tipo',
      fechaRegistro: json['fecharegistro'],
      usuarioIds: json['usuarioids'] != null
          ? List<int>.from(json['usuarioids'])
          : [],
      destinatarios: json['destinatarios'] != null
          ? (json['destinatarios'] as List)
              .map((d) => DestinatarioInfo.fromJson(d))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'asunto': asunto,
    'mensaje': mensaje,
    'tipoid': tipoId,
    'usuarioids': usuarioIds,
    'enviarahora': true,
  };
}