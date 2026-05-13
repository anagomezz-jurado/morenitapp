from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo TipoCargo
# Define los tipos de cargos dentro de la hermandad

class TipoCargo(models.Model):

    _name = 'morenitapp.tipocargo'
    _description = 'Tipo de Cargo de la Hermandad'

    # Campo mostrado como nombre principal
    _rec_name = 'codTipoCargo'

    # Código del tipo de cargo
    codTipoCargo = fields.Char(
        string="Código de Tipo de Cargo",
        required=True
    )

    # Nombre descriptivo del cargo
    nombreTipoCargo = fields.Char(
        string="Nombre de Tipo de Cargo",
        required=True
    )

    # Observaciones opcionales
    observaciones = fields.Char(
        string="Observaciones"
    )