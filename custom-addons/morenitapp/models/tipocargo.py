from odoo import models, fields, api
from odoo.exceptions import ValidationError

class TipoCargo(models.Model):
    _name = 'morenitapp.tipocargo'
    _description = 'Tipo de Cargo de la Hermandad'
    _rec_name = 'codTipoCargo'

    codTipoCargo = fields.Char(string="Código de Tipo de Cargo", required=True)
    nombreTipoCargo = fields.Char(string="Nombre de Tipo de Cargo", required=True)
    observaciones = fields.Char(string="Observaciones")