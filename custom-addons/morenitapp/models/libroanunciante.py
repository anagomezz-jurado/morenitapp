from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo LibroAnunciante
# Relaciona anunciantes con libros

class LibroAnunciante(models.Model):

    _name = 'morenitapp.libroanunciante'
    _description = 'Relación de Anunciantes por Libro'

    # Orden descendente
    _order = 'fecha_cobro desc, id desc'

    # Libro asociado
    libro_id = fields.Many2one(
        'morenitapp.libro',
        string="Libro",
        ondelete='cascade',
        required=True
    )

    # Proveedor anunciante
    proveedor_id = fields.Many2one(
        'morenitapp.proveedor',
        string="Anunciante",
        required=True,

        # Solo proveedores anunciantes
        domain=[('anunciante', '=', True)]
    )

    # Importe pagado
    importe = fields.Float(
        string="Importe",
        required=True,
        digits=(16, 2),
        default=0.0
    )

    # Indica si está cobrado
    cobrado = fields.Boolean(
        string="¿Cobrado?",
        default=False
    )

    # Fecha de cobro
    fecha_cobro = fields.Date(
        string="Fecha de Cobro"
    )

    # VALIDACIÓN
    # Evita importes negativos

    @api.constrains('importe')
    def _check_importe_positivo(self):

        for record in self:

            if record.importe < 0:

                raise ValidationError(
                    "El importe del anunciante no puede ser negativo."
                )

    # ONCHANGE
    # Si se marca como cobrado:
    # - pone fecha automática

    @api.onchange('cobrado')
    def _onchange_cobrado(self):

        if self.cobrado:

            if not self.fecha_cobro:

                self.fecha_cobro = fields.Date.today()

        else:

            self.fecha_cobro = False