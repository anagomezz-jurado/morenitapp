from odoo import models, fields, api
from odoo.exceptions import ValidationError

class GrupoProveedor(models.Model):
    _name = 'morenitapp.grupoproveedor'
    _description = 'Grupos de Proveedores de la Hermandad'
    _rec_name = 'nombre'

    cod_grupo = fields.Char(string="Código de Grupo", required=True)
    nombre = fields.Char(required=True)