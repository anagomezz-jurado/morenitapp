from odoo import models, fields, api
from odoo.exceptions import ValidationError


class CodigoPostal(models.Model):
    _name = 'morenitapp.codigopostal'
    _description = 'Código Postal'

    name = fields.Char(string="Código Postal", required=True)

    localidad_id = fields.Many2one(
        'morenitapp.localidad',
        string="Localidad"
    )