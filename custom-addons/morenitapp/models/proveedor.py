from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Proveedor
# Gestiona proveedores de la hermandad

class Proveedor(models.Model):

    _name = 'morenitapp.proveedor'
    _description = 'Proveedores de la Hermandad'

    # Código interno del proveedor
    cod_proveedor = fields.Char(
        string="Código de Proveedor",
        required=True
    )

    # Nombre del proveedor
    nombre = fields.Char(required=True)

    # Persona de contacto
    contacto = fields.Char(
        string="Persona de Contacto"
    )

    # Teléfono
    telefono = fields.Char(
        string="Teléfono"
    )

    # Correo electrónico
    email = fields.Char(
        string="Correo Electrónico"
    )

    # Grupo al que pertenece el proveedor
    grupo_id = fields.Many2one(
        'morenitapp.grupoproveedor',
        string="Grupo de Proveedor"
    )


    # Calle
    calle_id = fields.Many2one(
        'morenitapp.calle',
        string="Calle"
    )

    # Localidad relacionada automáticamente desde la calle
    localidad_id = fields.Many2one(
        'morenitapp.localidad',
        related='calle_id.localidad_id',
        string="Localidad",
        store=True,
        readonly=True
    )

    # Código postal relacionado automáticamente
    codPostal_id = fields.Many2one(
        'morenitapp.codigopostal',
        related='calle_id.codPostal_id',
        string="C.P.",
        store=True,
        readonly=True
    )

    # Provincia relacionada automáticamente
    provincia_id = fields.Many2one(
        'morenitapp.provincia',
        related='localidad_id.codProvincia_id',
        string="Provincia",
        store=True,
        readonly=True
    )

    # Datos adicionales de dirección
    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    numero = fields.Char(string="Número")
    bloque = fields.Char(string="Bloque")
    escalera = fields.Char(string="Escalera")
    portal = fields.Char(string="Portal")

    # Observaciones generales
    observaciones = fields.Text(
        string="Observaciones"
    )

    # Define si el proveedor es anunciante
    anunciante = fields.Boolean(
        string="¿Es Anunciante?"
    )

    # MÉTODO name_get
    # Personaliza cómo se muestran los registros en listas desplegables de Odoo


    def name_get(self):

        result = []

        for record in self:

            name = f"{record.cod_proveedor or ''} - {record.nombre or ''}"

            result.append((record.id, name))

        return result