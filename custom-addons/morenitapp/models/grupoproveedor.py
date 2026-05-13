from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo GrupoProveedor
# Agrupa proveedores por categorías

class GrupoProveedor(models.Model):

    _name = 'morenitapp.grupoproveedor'

    _description = 'Grupos de Proveedores de la Hermandad'

    # Campo mostrado como nombre
    _rec_name = 'nombre'

    # Código del grupo
    cod_grupo = fields.Char(
        string="Código de Grupo",
        required=True
    )

    # Nombre del grupo
    nombre = fields.Char(
        required=True
    )