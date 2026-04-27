from odoo import models, fields

class GrupoPermiso(models.Model):
    _name = 'morenitapp.grupo.permiso'
    _description = 'Permisos por grupo y modelo'
    _rec_name = 'modelo_id'

    grupo_id = fields.Many2one(
        'morenitapp.grupo',
        required=True,
        ondelete='cascade'
    )

    modelo_id = fields.Many2one(
        'ir.model',
        string='Modelo',
        required=True,
        ondelete='cascade'
    )

    modelo = fields.Char(
        related='modelo_id.model',
        store=True,
        string="Modelo técnico"
    )

    puede_leer = fields.Boolean(default=False)
    puede_crear = fields.Boolean(default=False)
    puede_editar = fields.Boolean(default=False)
    puede_borrar = fields.Boolean(default=False)