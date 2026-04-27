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
    
    # CORRECCIÓN: Apuntar a tu modelo personalizado 'morenitapp.rol'
    rol_id = fields.Many2one(
        'morenitapp.rol', 
        string='Rol'
    )
    
    recibirNotiEmail = fields.Boolean(default=True)
    recibirNotiTelefono = fields.Boolean(default=False)