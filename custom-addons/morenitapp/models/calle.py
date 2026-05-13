from odoo import models, fields, api
from odoo.exceptions import ValidationError

# ============================================================
# Modelo Calle
# Gestiona calles de localidades
# ============================================================

class Calle(models.Model):
    _name = 'morenitapp.calle'
    _description = 'Calle de la Hermandad'

    # Campo representativo
    _rec_name = 'nombreCalle'

    # Nombre calle
    nombreCalle = fields.Char(
        string="Nombre de la Calle",
        required=True
    )

    # Localidad a la que pertenece la calle
    localidad_id = fields.Many2one(
        'morenitapp.localidad',
        string="Localidad",
        required=True
    )

    # Código postal asociado
    codPostal_id = fields.Many2one(
        'morenitapp.codigopostal',
        string="Código Postal",
        required=True,
        # Filtra automáticamente los códigos postales
        # para mostrar solo los pertenecientes
        # a la localidad seleccionada

        domain="[('localidad_id', '=', localidad_id)]"
    )

    # Relación inversa:
    # Una calle puede tener muchos hermanos
    hermanos_ids = fields.One2many(
        'morenitapp.hermano',
        'calle_id',
        string="Hermanos"
    )

    # ONCHANGE LOCALIDAD
    # Si cambia localidad:
    # - valida que el código postal pertenezca
    #   a esa localidad
    # - si no coincide -> limpia el campo

    @api.onchange('localidad_id')
    def _onchange_localidad(self):

        if self.localidad_id:

            # Si el CP no pertenece a la localidad
            if (
                self.codPostal_id and
                self.codPostal_id.localidad_id != self.localidad_id
            ):

                # Limpia código postal
                self.codPostal_id = False

        else:

            # Si no hay localidad
            self.codPostal_id = False