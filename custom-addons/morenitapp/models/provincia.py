from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Provincia
# Guarda provincias

class Provincia(models.Model):

    _name = 'morenitapp.provincia'
    _description = 'Provincia de la Hermandad'

    # Campo representativo
    _rec_name = 'codProvincia'

    # Código provincia
    codProvincia = fields.Char(
        string="Código de Provincia",
        required=True
    )

    # Nombre provincia
    nombreProvincia = fields.Char(
        string="Nombre de Provincia",
        required=True
    )