from odoo import models, fields, api

# Modelo Tipo de Notificación
# Guarda categorías de notificaciones

class NotificacionTipo(models.Model):

    # Nombre técnico del modelo
    _name = 'morenitapp.notificacion.tipo'

    # Descripción del modelo
    _description = 'Tipo de Notificación'

    # Nombre del tipo de notificación
    name = fields.Char(
        string="Nombre del Tipo",
        required=True
    )