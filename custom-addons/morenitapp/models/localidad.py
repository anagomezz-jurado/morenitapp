from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Localidad(models.Model):
    _name = 'morenitapp.localidad'
    _description = 'Localidad de la Hermandad'
    _rec_name = 'nombreLocalidad'

    nombreLocalidad = fields.Char(required=True)
    codProvincia_id = fields.Many2one(
        'morenitapp.provincia', 
        string="Provincia",
        required=True
    )
    nombreCapital = fields.Char()