from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Provincia(models.Model):
    _name = 'morenitapp.provincia'
    _description = 'Provincia de la Hermandad'
    _rec_name = 'codProvincia'

    codProvincia = fields.Char(string="Código de Provincia", required=True)
    nombreProvincia = fields.Char(string="Nombre de Provincia", required=True)