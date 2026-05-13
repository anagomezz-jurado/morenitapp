from odoo import models, fields

# Modelo Usuario
# Representa los usuarios de la aplicación MorenitApp

class Usuario(models.Model):

    # Nombre técnico del modelo en Odoo
    _name = 'morenitapp.usuario'
    _inherit = ['mail.thread']

    # Descripción visible del modelo
    _description = 'Usuario MorenitApp'

    # Nombre del usuario (obligatorio)
    nombre = fields.Char(required=True)

    # Primer apellido
    apellido1 = fields.Char()

    # Segundo apellido
    apellido2 = fields.Char()

    # Correo electrónico obligatorio
    email = fields.Char(required=True)

    # Contraseña del usuario
    contrasena = fields.Char(required=True)

    # Número de teléfono
    telefono = fields.Char()


    # Relación Many2one con el modelo Rol un usuario tiene un rol
    rol_id = fields.Many2one(
        'morenitapp.rol',
        string='Rol'
    )

    # Relación con Hermano si el hermano se elimina -> el campo queda vacío
    hermano_id = fields.Many2one(
        'morenitapp.hermano',
        string='Hermano',
        ondelete='set null'
    )


    # Define si el usuario quiere recibir emails
    # Valor por defecto: True
    recibirNotiEmail = fields.Boolean(default=True)