from odoo import models, fields, api

# Modelo Cofradia
# Guarda información de cofradías

class Cofradia(models.Model):
    _name = 'morenitapp.cofradia'
    _description = 'Cofradía'

    # Campo representativo
    _rec_name = 'nombreCofradia'


    # CIF cofradía
    cifCofradia = fields.Char(
        string="CIF de Cofradía",
        required=True
    )

    # Nombre cofradía
    nombreCofradia = fields.Char(
        string="Nombre de Cofradía",
        required=True
    )

    # Año fundación
    antiguedadCofradia = fields.Integer(
        string="Año de Fundación"
    )

    # Responsable
    nombreResponsable = fields.Char(
        string="Nombre del Responsable"
    )

    calle_id = fields.Many2one(
        'morenitapp.calle',
        string="Calle"
    )

    # Campos relacionados automáticos
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

    telefonoCofradia = fields.Char(
        string="Teléfono"
    )

    emailCofradia = fields.Char(
        string="Email"
    )

    paginaWeb = fields.Char(
        string="Página Web"
    )

    # Observaciones
    observaciones = fields.Text(
        string="Observaciones"
    )