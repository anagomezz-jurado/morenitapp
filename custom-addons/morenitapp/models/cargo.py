from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Cargo
# Representa cargos dentro de la hermandad

class Cargo(models.Model):
    _name = 'morenitapp.cargo'
    _description = 'Cargo de la Hermandad'

    # Campo representativo
    _rec_name = 'nombreCargo'

    # Código interno del cargo
    codCargo = fields.Char(
        string="Código de Cargo",
        required=True
    )

    # Nombre del cargo
    nombreCargo = fields.Char(
        string="Nombre de Cargo",
        required=True
    )

    # Tipo de cargo
    # Relación Many2one
    tipocargo_id = fields.Many2one(
        'morenitapp.tipocargo',
        string="Tipo de Cargo",
        required=True
    )

    # Fecha inicio del cargo
    fechaInicioCargo = fields.Date(
        string="Fecha de Inicio de Cargo",
        required=True
    )

    # Fecha fin del cargo
    fechaFinCargo = fields.Date(
        string="Fecha de Fin de Cargo"
    )

    # Calle asociada
    calle_id = fields.Many2one(
        'morenitapp.calle',
        string="Calle"
    )

    # Campos automáticos relacionados
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
        string="C.P.",
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

    # Datos adicionales dirección
    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    numero = fields.Char(string="Número")
    bloque = fields.Char(string="Bloque")
    escalera = fields.Char(string="Escalera")
    portal = fields.Char(string="Portal")

    # Teléfono asociado al cargo
    telefono = fields.Char(
        string="Teléfono de Cargo"
    )

    # Observaciones
    observaciones = fields.Text(
        string="Observaciones de Cargo"
    )

    # Motivo relacionado al cargo
    motivo = fields.Text(
        string="Motivo de Cargo"
    )

    # Texto saludo institucional
    textoSaludo = fields.Text(
        string="Texto de Saludo de Cargo"
    )