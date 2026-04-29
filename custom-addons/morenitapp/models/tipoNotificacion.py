from odoo import models, fields, api

class NotificacionTipo(models.Model):
    _name = 'morenitapp.notificacion.tipo'
    _description = 'Tipo de Notificación'

    name = fields.Char(string="Nombre del Tipo", required=True)