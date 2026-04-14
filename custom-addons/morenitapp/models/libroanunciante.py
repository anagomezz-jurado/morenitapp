from odoo import models, fields, api
from odoo.exceptions import ValidationError

class LibroAnunciante(models.Model):
    _name = 'morenitapp.libroanunciante'
    _description = 'Relación de Anunciantes por Libro'
    _order = 'fecha_cobro desc, id desc'

    # Relación con el modelo principal (Libro)
    # El nombre 'libro_id' debe coincidir exactamente con el inverse_name del One2many en libro.py
    libro_id = fields.Many2one(
        'morenitapp.libro', 
        string="Libro", 
        ondelete='cascade', 
        required=True
    )

    # Relación con el Proveedor
    proveedor_id = fields.Many2one(
        'morenitapp.proveedor', 
        string="Anunciante", 
        required=True,
        # Opcional: Filtrar para que solo salgan proveedores marcados como anunciantes
        domain=[('es_anunciante', '=', True)] 
    )

    # Datos económicos
    importe = fields.Float(
        string="Importe del Anuncio", 
        required=True, 
        digits=(16, 2),
        default=0.0
    )

    # Estado del pago
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
        for record in record:
            if record.importe < 0:
                raise ValidationError("El importe del anunciante no puede ser negativo.")

    @api.onchange('cobrado')
    def _onchange_cobrado(self):
        """Asigna la fecha de hoy automáticamente al marcar como cobrado"""
        if self.cobrado and not self.fecha_cobro:
            self.fecha_cobro = fields.Date.today()
        elif not self.cobrado:
            self.fecha_cobro = False