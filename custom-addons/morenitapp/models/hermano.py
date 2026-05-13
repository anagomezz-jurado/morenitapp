from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Hermano
# Gestiona los hermanos pertenecientes a la hermandad

class Hermano(models.Model):
    _name = 'morenitapp.hermano'
    _description = 'Hermanos de la Hermandad'

    # Campo representativo del registro
    _rec_name = 'nombre_completo'

    # Número interno del hermano
    numero_hermano = fields.Integer(
        string="Nº Hermano",
        required=True
    )

    # Sexo del hermano
    sexo = fields.Selection([
        ('Hombre', 'Hombre'),
        ('Mujer', 'Mujer')
    ],
        string="Sexo",
        default='Hombre'
    )

    # Código generado automáticamente
    codigo_hermano = fields.Char(
        string="Código",
        compute="_compute_codigo_hermano",
        store=True
    )

    # Nombre
    nombre = fields.Char(
        string="Nombre",
        required=True
    )

    # Primer apellido
    apellido1 = fields.Char(
        string="Primer Apellido",
        required=True
    )

    # Segundo apellido
    apellido2 = fields.Char(
        string="Segundo Apellido"
    )

    # Nombre completo calculado automáticamente
    nombre_completo = fields.Char(
        string="Nombre Completo",
        compute="_compute_nombre_completo",
        store=True
    )

    # Documento DNI
    dni = fields.Char(
        string="DNI",
        required=True
    )

    # Fecha nacimiento
    fecha_nacimiento = fields.Date(
        string="Fecha Nacimiento"
    )

    # Teléfono
    telefono = fields.Char(
        string="Teléfono"
    )

    # Correo electrónico
    email = fields.Char(
        string="Email"
    )


    estado = fields.Selection([
        ('activo', 'Activo'),
        ('baja', 'Baja')
    ],
        string="Estado",
        default='activo',
        store=True
    )

    # Indica si está bautizado
    bautizado = fields.Boolean(
        string="Es Bautizado",
        default=False
    )

    # Calle
    calle_id = fields.Many2one(
        'morenitapp.calle',
        string="Calle",
        required=True
    )

    # Localidad automática
    localidad_id = fields.Many2one(
        'morenitapp.localidad',
        related='calle_id.localidad_id',
        string="Localidad",
        store=True,
        readonly=True
    )

    # Código postal automático
    codPostal_id = fields.Many2one(
        'morenitapp.codigopostal',
        related='calle_id.codPostal_id',
        string="C.P.",
        store=True,
        readonly=True
    )

    # Provincia automática
    provincia_id = fields.Many2one(
        'morenitapp.provincia',
        related='localidad_id.codProvincia_id',
        string="Provincia",
        store=True,
        readonly=True
    )

    # Datos adicionales dirección
    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    numero = fields.Char(string="Número")
    bloque = fields.Char(string="Bloque")
    escalera = fields.Char(string="Escalera")
    portal = fields.Char(string="Portal")

    # Fecha alta automática
    fecha_alta = fields.Date(
        string="Fecha Alta",
        required=True,
        default=lambda self: fields.Date.today()
    )

    # Método de pago
    metodo_pago = fields.Selection([
        ('metalico', 'Metálico'),
        ('banco', 'Banco')
    ],
        string="Método Pago",
        default='metalico'
    )

    # Observaciones generales
    observaciones = fields.Char(
        string="Observaciones"
    )

    # Fecha baja
    fecha_baja = fields.Date(
        string="Fecha Baja"
    )

    # Motivo baja
    motivo_baja = fields.Text(
        string="Motivo Baja"
    )

    # Fecha reactivación
    fecha_reactivacion = fields.Date(
        string="Fecha Reactivación"
    )

    # DATOS BANCARIOS

    # Relación One2many con cuentas bancarias
    datos_banco_ids = fields.One2many(
        'morenitapp.banco',
        'hermano_id',
        string="Cuentas Bancarias"
    )

    # IBAN completo calculado
    iban = fields.Char(
        string="IBAN",
        compute="_compute_iban_total",
        store=True
    )

    # GENERAR CÓDIGO DE HERMANO
    @api.depends('numero_hermano', 'sexo')
    def _compute_codigo_hermano(self):

        for record in self:

            if record.numero_hermano:

                # Sufijo según sexo
                sufijo = 'H' if record.sexo == 'Hombre' else 'M'

                # Genera código
                record.codigo_hermano = f"{record.numero_hermano}{sufijo}"

            else:

                record.codigo_hermano = False

    # GENERAR NOMBRE COMPLETO
    @api.depends('nombre', 'apellido1', 'apellido2')
    def _compute_nombre_completo(self):

        for record in self:

            # Añade segundo apellido solo si existe
            ap2 = f" {record.apellido2}" if record.apellido2 else ""

            # Construye nombre completo
            record.nombre_completo = (
                f"{record.nombre} "
                f"{record.apellido1}{ap2}"
            )

    # VALIDACIÓN DATOS BANCARIOS
    # Si método pago = banco
    # debe existir al menos una cuenta bancaria

    @api.constrains('metodo_pago', 'datos_banco_ids')
    def _check_banco(self):

        for r in self:

            if r.metodo_pago == 'banco' and not r.datos_banco_ids:

                raise ValidationError(
                    "Debe ingresar datos bancarios para pago por banco."
                )

    # ACCIÓN DAR BAJA
    def action_dar_baja(self):

        for record in self:

            record.write({

                'estado': 'baja',

                'fecha_baja': fields.Date.today()
            })

    # ACCIÓN REACTIVAR
    def action_reactivar(self):

        for record in self:

            record.write({

                'estado': 'activo',

                'fecha_baja': False,

                'motivo_baja': False,

                'fecha_reactivacion': fields.Date.today()
            })

    # CALCULAR IBAN COMPLETO
    @api.depends(
        'datos_banco_ids.iban',
        'datos_banco_ids.banco',
        'datos_banco_ids.sucursal',
        'datos_banco_ids.cuenta'
    )

    def _compute_iban_total(self):

        for record in self:

            if record.datos_banco_ids:

                # Toma primera cuenta bancaria
                b = record.datos_banco_ids[0]

                # Construcción IBAN completo
                record.iban = (
                    f"{b.iban or ''}"
                    f"{b.banco or ''}"
                    f"{b.sucursal or ''}"
                    f"{b.cuenta or ''}"
                )

            else:

                record.iban = ""