from odoo import models, fields

class Usuario(models.Model):
    _name = 'morenitapp.usuario'
    _description = 'Usuario MorenitApp'

    nombre = fields.Char(required=True)
    apellido1 = fields.Char()
    apellido2 = fields.Char()
    email = fields.Char(required=True)
    contrasena = fields.Char(required=True)  # texto plano por ahora
    telefono = fields.Char()
    rol_id = fields.Many2one('res.groups', string='Rol')
    recibirNotiEmail = fields.Boolean(default=True)
    recibirNotiTelefono = fields.Boolean(default=False)