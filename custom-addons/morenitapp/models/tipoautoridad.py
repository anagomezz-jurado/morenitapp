from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo TipoAutoridad
# Define tipos de autoridades de la hermandad

class TipoAutoridad(models.Model):

    _name = 'morenitapp.tipoautoridad'
    _description = 'Tipo de Autoridad de la Hermandad'

    # Campo mostrado como nombre
    _rec_name = 'codTipoAutoridad'

    # Código del tipo de autoridad
    codTipoAutoridad = fields.Char(
        string="Código de Tipo de Autoridad",
        required=True
    )

    # Nombre descriptivo
    nombreTipoAutoridad = fields.Char(
        string="Nombre de Tipo de Autoridad",
        required=True
    )