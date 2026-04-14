from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Calle(models.Model):
    _name = 'morenitapp.calle'
    _description = 'Calle de la Hermandad'
    _rec_name = 'nombreCalle'

    nombreCalle = fields.Char(required=True)
    localidad_id = fields.Many2one('morenitapp.localidad', string="Localidad", required=True)
    codPostal_id = fields.Many2one('morenitapp.codigopostal', string="Código Postal", required=True)

    hermanos_ids = fields.One2many('morenitapp.hermano', 'calle_id', string="Hermanos")

    responsable_id = fields.Many2one('morenitapp.hermano', string="Cobrador Responsable")

    @api.onchange('responsable_id')
    def _onchange_responsable(self):
        for calle in self:
            if calle.responsable_id:
                calle.responsable_id.responsable = True