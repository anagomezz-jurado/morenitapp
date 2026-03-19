from odoo import models, fields

class Usuario(models.Model):
    _name = 'morenitapp.usuario'
    _description = 'Usuario de la Hermandad'

    # Relación con el rol (Asegúrate de que existan registros en morenitapp.rol)
    rol_id = fields.Many2one('morenitapp.rol', string="Rol", required=True)
    nombre = fields.Char(required=True)
    apellido1 = fields.Char(required=True)
    apellido2 = fields.Char()
    email = fields.Char(required=True)
    contrasena = fields.Char(required=True)
    telefono = fields.Char(string="Teléfono")
    
    recibirNotiEmail = fields.Boolean(string="Recibir notificaciones por email", default=True)
    recibirNotiTelefono = fields.Boolean(string="Recibir notificaciones por SMS", default=False)