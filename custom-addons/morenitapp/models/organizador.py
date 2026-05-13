from odoo import models, fields, api

# ============================================================
# Modelo Organizador
# Representa organizadores de eventos de la hermandad
# ============================================================

class Organizador(models.Model):
    _name = 'morenitapp.organizador'
    _description = 'Organizador de la Hermandad'

    # Campo que se mostrará como nombre del registro
    _rec_name = 'nombre'


    # CIF del organizador
    cif = fields.Char(
        string="CIF",
        required=True
    )

    # Nombre del organizador
    nombre = fields.Char(
        string="Nombre",
        required=True
    )

    # Teléfono de contacto
    telefono = fields.Char(
        string="Teléfono"
    )

    # Correo electrónico
    email = fields.Char(
        string="Email"
    )


    # Calle principal
    calle_id = fields.Many2one(
        'morenitapp.calle',
        string="Calle",
        required=True
    )

    # Localidad obtenida automáticamente desde la calle
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

    # ARCHIVOS BINARIOS

    # Logo del organizador
    logo = fields.Binary(
        string="Logo",
        attachment=True
    )

    # Firma digital del presidente
    firma_presidente = fields.Binary(
        string="Firma Presidente",
        attachment=True
    )

    # Firma digital del secretario
    firma_secretario = fields.Binary(
        string="Firma Secretario",
        attachment=True
    )

    # Firma digital del tesorero
    firma_tesorero = fields.Binary(
        string="Firma Tesorero",
        attachment=True
    )