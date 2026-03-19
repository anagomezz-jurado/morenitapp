from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Rol(models.Model):
    _name = 'morenitapp.rol'
    _description = 'Rol de la Hermandad'

    codRol = fields.Integer(string="Código de Rol", required=True)
    name = fields.Char(string="Nombre del Rol", required=True) # <--- Cambiado de nombreRol a name