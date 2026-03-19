from odoo import models, fields, api
from odoo.exceptions import ValidationError

class LibroAnunciante(models.Model):
    _name = 'morenitapp.libroanunciante'
    _description = 'Relaciona Libro y Anunciante'

    libro_id = fields.Many2one(
        'morenitapp.libro',
        string="Libro",
        required=True,
        ondelete='cascade'
    )

    proveedor_id = fields.Many2one(
        'morenitapp.proveedor',
        string="Anunciante",
        required=True,
        domain="[('anunciante','=',True)]"
    )

    importe = fields.Float(string="Importe", required=True)
    cobrado = fields.Boolean(string="¿Cobrado?", default=False)
    fecha_cobro = fields.Date(string="Fecha de Cobro")

    @api.constrains('cobrado', 'fecha_cobro')
    def _check_cobro(self):
        for record in self:
            if record.cobrado and not record.fecha_cobro:
                raise ValidationError("Debes indicar la fecha de cobro si está cobrado.")