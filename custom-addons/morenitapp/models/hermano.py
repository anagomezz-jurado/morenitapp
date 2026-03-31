from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Hermano(models.Model):
    _name = 'morenitapp.hermano'
    _description = 'Hermanos de la Hermandad'
    _rec_name = 'nombre_completo'

    numero_hermano = fields.Integer(required=True)
    sexo = fields.Selection([
        ('Hombre', 'Hombre'),
        ('Mujer', 'Mujer')
    ], string="Sexo", default='Hombre')
    
    codigo_hermano = fields.Char(string="Código de Hermano", compute="_compute_codigo_hermano", store=True)
    nombre = fields.Char(required=True)
    apellido1 = fields.Char(required=True)
    apellido2 = fields.Char()
    nombre_completo = fields.Char(string="Nombre Completo", compute="_compute_nombre_completo", store=True)
    dni = fields.Char(required=True)
    fecha_nacimiento = fields.Date()
    telefono = fields.Char()
    email = fields.Char()
    
    # Relación principal
    calle_id = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    
    # Campos relacionados (Asegúrate de que estos nombres existan en morenitapp.calle)
    localidad_id = fields.Many2one(
        'morenitapp.localidad', 
        related='calle_id.localidad_id', 
        string="Localidad", 
        store=True, 
        readonly=True
    )
    codPostal_id = fields.Many2one(
        'morenitapp.codigopostal', 
        related='calle_id.codPostal_id', 
        string="Código Postal", 
        store=True, 
        readonly=True
    )
    provincia_id = fields.Many2one(
        'morenitapp.provincia', 
        related='localidad_id.codProvincia_id', 
        string="Provincia", 
        store=True, 
        readonly=True
    )

    puerta = fields.Char()
    piso = fields.Char()
    fecha_alta = fields.Date(required=True, default=lambda self: fields.Date.today())
    metodo_pago = fields.Selection([
        ('metalico','Metálico'),
        ('banco','Domiciliación bancaria')
    ], default='metalico')
    
    responsable = fields.Boolean(default=True)
    observaciones = fields.Char()
    fecha_baja = fields.Date()
    motivo_baja = fields.Text()
    fecha_reactivacion = fields.Date(string="Fecha de re-activación")
    datos_banco_ids = fields.One2many('morenitapp.banco', 'hermano_id', string="Datos Bancarios")

    @api.depends('numero_hermano', 'sexo')
    def _compute_codigo_hermano(self):
        for record in self:
            if record.numero_hermano:
                sufijo = 'H' if record.sexo == 'Hombre' else 'M'
                record.codigo_hermano = f"{record.numero_hermano}{sufijo}"
            else:
                record.codigo_hermano = False

    @api.depends('nombre', 'apellido1', 'apellido2')
    def _compute_nombre_completo(self):
        for record in self:
            ap2 = f" {record.apellido2}" if record.apellido2 else ""
            record.nombre_completo = f"{record.nombre} {record.apellido1}{ap2}"

    @api.constrains('metodo_pago', 'datos_banco_ids')
    def _check_banco(self):
        for r in self:
            if r.metodo_pago == 'banco' and not r.datos_banco_ids:
                raise ValidationError("Debe ingresar los datos bancarios si el pago es domiciliado")

    def action_dar_baja(self):
        for record in self:
            record.fecha_baja = fields.Date.today()
        return True

    def action_reactivar(self):
        for record in self:
            record.fecha_baja = False
            record.motivo_baja = False
        return True