from odoo import models, fields

class Rol(models.Model):
    _name = 'morenitapp.rol'
    _description = 'Rol de Usuario'

    name = fields.Char(string="Nombre", required=True)
    codRol = fields.Integer(string="Código del Rol", required=True)

    _sql_constraints = [
        ('codRol_unique', 'unique(codRol)', 'El código de rol ya existe')
    ]