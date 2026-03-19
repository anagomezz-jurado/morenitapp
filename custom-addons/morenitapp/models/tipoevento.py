from odoo import models, fields, api
from odoo.exceptions import ValidationError

class TipoEvento(models.Model):
    _name = 'morenitapp.tipoevento'
    _description = 'Tipo de Evento de la Hermandad'
    _rec_name = 'nombre_tipo_evento'

    cod_tipo_evento = fields.Char(string="Código de Tipo de Evento", required=True)
    nombre_tipo_evento = fields.Char(string="Nombre de Tipo de Evento", required=True)