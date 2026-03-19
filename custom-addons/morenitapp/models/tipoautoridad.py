from odoo import models, fields, api
from odoo.exceptions import ValidationError

class TipoAutoridad(models.Model):
    _name = 'morenitapp.tipoautoridad'
    _description = 'Tipo de Autoridad de la Hermandad'
    _rec_name = 'codTipoAutoridad'
    codTipoAutoridad = fields.Char(string="Código de Tipo de Autoridad", required=True)
    nombreTipoAutoridad = fields.Char(string="Nombre de Tipo de Autoridad", required=True)
