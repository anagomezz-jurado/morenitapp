from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Hermano(models.Model):
    _name = 'morenitapp.hermano'
    _description = 'Hermanos de la Hermandad'
    _rec_name = 'nombre_completo'

    numero_hermano = fields.Integer(string="Nº Hermano", required=True)
    sexo = fields.Selection([
        ('Hombre', 'Hombre'),
        ('Mujer', 'Mujer')
    ], string="Sexo", default='Hombre')
    
    codigo_hermano = fields.Char(string="Código", compute="_compute_codigo_hermano", store=True)
    nombre = fields.Char(string="Nombre", required=True)
    apellido1 = fields.Char(string="Primer Apellido", required=True)
    apellido2 = fields.Char(string="Segundo Apellido")
    nombre_completo = fields.Char(string="Nombre Completo", compute="_compute_nombre_completo", store=True)
    dni = fields.Char(string="DNI", required=True)
    fecha_nacimiento = fields.Date(string="Fecha Nacimiento")
    telefono = fields.Char(string="Teléfono")
    email = fields.Char(string="Email")
    
    estado = fields.Selection([
        ('activo', 'Activo'),
        ('baja', 'Baja')
    ], string="Estado", default='activo', store=True)

    calle_id = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    
    responsable = fields.Boolean(string="Es Cobrador/Responsable", default=False)
    calles_responsable_ids = fields.One2many(
        'morenitapp.calle', 
        'responsable_id', 
        string="Calles Asignadas"
    )

    # Campos relacionados (automáticos)
    localidad_id = fields.Many2one('morenitapp.localidad', related='calle_id.localidad_id', string="Localidad", store=True, readonly=True)
    codPostal_id = fields.Many2one('morenitapp.codigopostal', related='calle_id.codPostal_id', string="C.P.", store=True, readonly=True)
    provincia_id = fields.Many2one('morenitapp.provincia', related='localidad_id.codProvincia_id', string="Provincia", store=True, readonly=True)

    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    fecha_alta = fields.Date(string="Fecha Alta", required=True, default=lambda self: fields.Date.today())
    metodo_pago = fields.Selection([
        ('metalico','Metálico'),
        ('banco','Banco')
    ], string="Método Pago", default='metalico')
    
    observaciones = fields.Char(string="Observaciones")
    fecha_baja = fields.Date(string="Fecha Baja")
    motivo_baja = fields.Text(string="Motivo Baja")
    fecha_reactivacion = fields.Date(string="Fecha Reactivación")
    
    datos_banco_ids = fields.One2many('morenitapp.banco', 'hermano_id', string="Cuentas Bancarias")
    iban = fields.Char(string="IBAN", compute="_compute_iban_total", store=True)

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
                raise ValidationError("Debe ingresar datos bancarios para pago por banco.")

    def action_dar_baja(self):
        for record in self:
            record.write({
                'estado': 'baja',
                'fecha_baja': fields.Date.today()
            })

    def action_reactivar(self):
        for record in self:
            record.write({
                'estado': 'activo',
                'fecha_baja': False,
                'motivo_baja': False,
                'fecha_reactivacion': fields.Date.today()
            })

    @api.depends('datos_banco_ids.iban', 'datos_banco_ids.banco', 'datos_banco_ids.sucursal', 'datos_banco_ids.cuenta')
    def _compute_iban_total(self):
        for record in self:
            if record.datos_banco_ids:
                b = record.datos_banco_ids[0]
                record.iban = f"{b.iban or ''}{b.banco or ''}{b.sucursal or ''}{b.cuenta or ''}"
            else:
                record.iban = ""