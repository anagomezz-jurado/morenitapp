from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Calle(models.Model):
    _name = 'morenitapp.calle'
    _description = 'Calle de la Hermandad'
    _rec_name = 'nombreCalle'

    nombreCalle = fields.Char(string="Nombre de la Calle", required=True)
    
    # Relaciones principales
    localidad_id = fields.Many2one('morenitapp.localidad', string="Localidad", required=True)
    
    # Filtramos el Código Postal para que dependa de la localidad seleccionada
    codPostal_id = fields.Many2one(
        'morenitapp.codigopostal', 
        string="Código Postal", 
        required=True,
        domain="[('localidad_id', '=', localidad_id)]" # Filtro dinámico en UI
    )

    hermanos_ids = fields.One2many('morenitapp.hermano', 'calle_id', string="Hermanos")
    responsable_id = fields.Many2one('morenitapp.hermano', string="Cobrador Responsable")

    # Limpiamos el CP si se cambia la localidad
    @api.onchange('localidad_id')
    def _onchange_localidad(self):
        if self.localidad_id:
            # Si el CP actual no pertenece a la nueva localidad, lo borramos
            if self.codPostal_id and self.codPostal_id.localidad_id != self.localidad_id:
                self.codPostal_id = False
        else:
            self.codPostal_id = False

    @api.onchange('responsable_id')
    def _onchange_responsable(self):
        for calle in self:
            if calle.responsable_id:
                # Marcamos al hermano como responsable/cobrador
                calle.responsable_id.responsable = True