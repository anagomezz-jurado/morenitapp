from odoo import models, fields, api
import logging

_logger = logging.getLogger(__name__)

class Notificacion(models.Model):
    _name = 'morenitapp.notificacion'
    _description = 'Envío de Notificaciones'
    _inherit = ['mail.thread']

    asunto = fields.Char(required=True, tracking=True)
    mensaje = fields.Html(required=True, tracking=True)
    fecha_registro = fields.Datetime(
        string="Fecha de Registro",
        default=fields.Datetime.now,
        readonly=True,
    )
    tipo_id = fields.Many2one(
        'morenitapp.notificacion.tipo',
        string="Tipo de Notificación"
    )
    usuario_ids = fields.Many2many(
        'morenitapp.usuario',
        string="Destinatarios"
    )

    @api.onchange('tipo_id')
    def _onchange_tipo_id(self):
        usuarios_validos = self.env['morenitapp.usuario'].search([
            ('recibirNotiEmail', '=', True)
        ])
        if usuarios_validos:
            self.usuario_ids = [(6, 0, usuarios_validos.ids)]

    def action_enviar_notificacion(self):
        for rec in self:
            if not rec.usuario_ids:
                _logger.warning("No hay usuarios seleccionados en la notificación %s", rec.id)
                continue
            for user in rec.usuario_ids:
                if user.email and user.recibirNotiEmail:
                    mail_values = {
                        'subject': rec.asunto,
                        'body_html': rec.mensaje,
                        'email_to': user.email,
                        'email_from': 'archivosmorenita@gmail.com',
                    }
                    mail = self.env['mail.mail'].create(mail_values)
                    mail.send()
                else:
                    _logger.info("Saltando Email para %s (sin email o check desactivado)", user.nombre)