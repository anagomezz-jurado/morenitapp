from odoo import models, fields, api
from odoo.exceptions import ValidationError

class LibroAnunciante(models.Model):
    _name = 'morenitapp.libroanunciante'
    _description = 'Relación de Anunciantes por Libro'
    _order = 'fecha_cobro desc, id desc'

    libro_id = fields.Many2one(
        'morenitapp.libro', 
        string="Libro", 
        ondelete='cascade', 
        required=True
    )

    proveedor_id = fields.Many2one(
        'morenitapp.proveedor', 
        string="Anunciante", 
        required=True,
        # Asegúrate de que el modelo proveedor tenga el campo 'anunciante'
        domain=[('anunciante', '=', True)] 
    )

    importe = fields.Float(
        string="Importe", 
        required=True, 
        digits=(16, 2),
        default=0.0
    )

    cobrado = fields.Boolean(
        string="¿Cobrado?", 
        default=False
    )

    fecha_cobro = fields.Date(
        string="Fecha de Cobro"
    )

    # --- Validaciones ---
    @api.constrains('importe')
    def _check_importe_positivo(self):
        for record in self: 
            if record.importe < 0:
                raise ValidationError("El importe del anunciante no puede ser negativo.")

    @api.onchange('cobrado')
    def _onchange_cobrado(self):
        """Asigna la fecha de hoy automáticamente al marcar como cobrado"""
        if self.cobrado:
            if not self.fecha_cobro:
                self.fecha_cobro = fields.Date.today()
        else:
            self.fecha_cobro = False