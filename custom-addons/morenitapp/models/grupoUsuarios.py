from odoo import models, fields

class Grupo(models.Model):
    _name = 'morenitapp.grupo'
    _description = 'Grupo de permisos'
    _rec_name = 'nombre'

    nombre = fields.Char(required=True)

    permiso_line_ids = fields.One2many(
        'morenitapp.grupo.permiso',
        'grupo_id',
        string='Permisos'
    )