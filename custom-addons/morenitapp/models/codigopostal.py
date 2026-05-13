from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo CodigoPostal
# Gestiona códigos postales asociados a localidades

class CodigoPostal(models.Model):
    _name = 'morenitapp.codigopostal'

    # Descripción visible
    _description = 'Código Postal'

    # Código postal
    name = fields.Char(
        string="Código Postal",
        required=True
    )

    # Localidad asociada al código postal
    localidad_id = fields.Many2one(
        'morenitapp.localidad',
        string="Localidad"
    )