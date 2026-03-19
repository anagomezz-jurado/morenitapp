from odoo import models, fields, api
from odoo.exceptions import ValidationError
from datetime import date

class Hermano(models.Model):
    _name = 'morenitapp.hermano'
    _description = 'Hermanos de la Hermandad'
    _rec_name = 'nombre_completo'  # ahora se usa el nombre completo en vistas

    numero_hermano = fields.Integer(required=True)
    sexo = fields.Selection([('masculino','Masculino'),('femenino','Femenino')], required=True)
    codigo_hermano = fields.Char(string="Código de Hermano", compute="_compute_codigo_hermano", store=True)

    nombre = fields.Char(required=True)
    apellido1 = fields.Char(required=True)
    apellido2 = fields.Char()
    
    nombre_completo = fields.Char(string="Nombre Completo", compute="_compute_nombre_completo", store=True)

    dni = fields.Char(required=True)
    fecha_nacimiento = fields.Date()
    telefono = fields.Char()
    email = fields.Char()
    calle_id = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    puerta = fields.Char()
    piso = fields.Char()
    fecha_alta = fields.Date(required=True)
    metodo_pago = fields.Selection([('metalico','Metálico'),('banco','Domiciliación bancaria')])
    responsable = fields.Boolean(default=True)
    observaciones = fields.Char()
    fecha_baja = fields.Date()
    motivo_baja = fields.Text()
    fecha_reactivacion = fields.Date(string="Fecha de re-activación")
    datos_banco_ids = fields.One2many('morenitapp.banco', 'hermano_id', string="Datos Bancarios")

    @api.depends('numero_hermano','sexo')
    def _compute_codigo_hermano(self):
        for record in self:
            if record.numero_hermano and record.sexo:
                sufijo = 'M' if record.sexo == 'masculino' else 'F'
                record.codigo_hermano = f"{record.numero_hermano}{sufijo}"
            else:
                record.codigo_hermano = False

    @api.depends('nombre','apellido1','apellido2')
    def _compute_nombre_completo(self):
        for record in self:
            ap2 = f" {record.apellido2}" if record.apellido2 else ""
            record.nombre_completo = f"{record.nombre} {record.apellido1}{ap2}"

    @api.constrains('metodo_pago')
    def _check_banco(self):
        for r in self:
            if r.metodo_pago == 'banco' and not r.datos_banco_ids:
                raise ValidationError("Debe ingresar los datos bancarios si el pago es domiciliado")

    def action_dar_baja(self):
        for record in self:
            record.fecha_baja = date.today()

    def action_reactivar(self):
        for record in self:
            record.fecha_reactivacion = date.today()
            record.fecha_baja = False
            record.motivo_baja = False