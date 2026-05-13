from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Localidad
# Guarda localidades/poblaciones

class Localidad(models.Model):

    _name = 'morenitapp.localidad'
    _description = 'Localidad de la Hermandad'

    # Campo representativo del registro
    _rec_name = 'nombreLocalidad'

    # Nombre de la localidad
    nombreLocalidad = fields.Char(
        required=True
    )

    # Relación con provincia
    codProvincia_id = fields.Many2one(
        'morenitapp.provincia',
        string="Provincia",
        required=True
    )