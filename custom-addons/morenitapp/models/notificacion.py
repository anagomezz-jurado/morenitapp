from odoo import models, fields, api
import logging

# Configuración del logger
# Permite registrar mensajes en el log de Odoo

_logger = logging.getLogger(__name__)

# Modelo Notificacion
# Gestiona el envío de emails/notificaciones

class Notificacion(models.Model):

    _name = 'morenitapp.notificacion'
    _description = 'Envío de Notificaciones'

    # Hereda el chatter de Odoo
    _inherit = ['mail.thread']

    # Asunto de la notificación
    asunto = fields.Char(
        required=True,
        tracking=True
    )

    # Contenido HTML del mensaje
    mensaje = fields.Html(
        required=True,
        tracking=True
    )

    # Fecha de creación automática
    fecha_registro = fields.Datetime(
        string="Fecha de Registro",
        default=fields.Datetime.now,
        readonly=True,
    )

    # Tipo de notificación
    tipo_id = fields.Many2one(
        'morenitapp.notificacion.tipo',
        string="Tipo de Notificación"
    )

    # Usuarios destinatarios
    usuario_ids = fields.Many2many(
        'morenitapp.usuario',
        string="Destinatarios"
    )

    # ONCHANGE
    # Cuando cambia el tipo de notificación:
    # - Busca usuarios que acepten emails
    # - Los agrega automáticamente

    @api.onchange('tipo_id')
    def _onchange_tipo_id(self):

        usuarios_validos = self.env['morenitapp.usuario'].search([
            ('recibirNotiEmail', '=', True)
        ])

        if usuarios_validos:
            self.usuario_ids = [(6, 0, usuarios_validos.ids)]

    # MÉTODO ENVÍO DE EMAILS
    # Envía correos mediante la API Resend

    def action_enviar_notificacion(self):

        # Librería HTTP
        import requests as http_requests

        # API KEY de Resend
        # IMPORTANTE:
        # Nunca dejar claves hardcodeadas en producción
        RESEND_API_KEY = 're_Vxr5Vm5y_EzGvW6vJw11wyf9aZ7dwzj9n'

        # Email remitente
        FROM_EMAIL = 'Morenitapp <noreply@morenitapp.com>'

        # Recorre todas las notificaciones seleccionadas
        for rec in self:

            # Si no hay destinatarios
            if not rec.usuario_ids:

                _logger.warning(
                    "Notificación %s sin destinatarios",
                    rec.id
                )

                continue

            # Lista para almacenar errores
            errores = []

            # ENVÍO A CADA USUARIO
            for user in rec.usuario_ids:

                # Si no tiene email -> saltar
                if not user.email:

                    _logger.info(
                        "Usuario %s sin email, saltando",
                        user.nombre
                    )

                    continue

                # Si no quiere emails -> saltar
                if not user.recibirNotiEmail:

                    _logger.info(
                        "Usuario %s no quiere emails, saltando",
                        user.nombre
                    )

                    continue

                try:

                    # PETICIÓN POST A RESEND
                    response = http_requests.post(

                        'https://api.resend.com/emails',

                        headers={
                            'Authorization': f'Bearer {RESEND_API_KEY}',
                            'Content-Type': 'application/json',
                        },

                        json={
                            'from': FROM_EMAIL,
                            'to': [user.email],
                            'subject': rec.asunto,

                            # Si no hay mensaje usa asunto
                            'html': rec.mensaje or f'<p>{rec.asunto}</p>',
                        },

                        timeout=10
                    )

                    # RESPUESTA OK
                    if response.status_code == 200:

                        _logger.info(
                            "Email enviado a %s <%s>",
                            user.nombre,
                            user.email
                        )

                    # ERROR EN API
                    else:

                        error_msg = (
                            f"{user.email}: "
                            f"{response.status_code} - "
                            f"{response.text}"
                        )

                        errores.append(error_msg)

                        _logger.error(
                            "Resend error: %s",
                            error_msg
                        )

                # EXCEPCIONES
                except Exception as e:

                    errores.append(
                        f"{user.email}: {str(e)}"
                    )

                    _logger.error(
                        "Excepción enviando a %s: %s",
                        user.email,
                        str(e)
                    )

            # SI HAY ERRORES -> lanzar excepción
            if errores:

                raise Exception(
                    f"Errores en envío: {'; '.join(errores)}"
                )

        return True