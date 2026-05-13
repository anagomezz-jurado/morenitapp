from odoo import models, fields

# Modelo Rol
# Define roles de usuarios

class Rol(models.Model):

    _name = 'morenitapp.rol'
    _description = 'Rol de Usuario'

    # Nombre del rol
    name = fields.Char(
        string="Nombre",
        required=True
    )

    # Código numérico del rol
    codRol = fields.Integer(
        string="Código del Rol",
        required=True
    )

    # Evita que existan dos roles con el mismo código
    _sql_constraints = [
        (
            'codRol_unique',
            'unique(codRol)',
            'El código de rol ya existe'
        )
    ]