from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Autoridad
# Gestiona autoridades relacionadas con la hermandad

class Autoridad(models.Model):
    _name = 'morenitapp.autoridad'
    _description = 'Autoridad de la Hermandad'

    # Campo representativo
    _rec_name = 'codAutoridad'


    # Código único autoridad
    codAutoridad = fields.Char(
        string="Código de Autoridad",
        required=True
    )

    # Nombre autoridad
    nombreAutoridad = fields.Char(
        string="Nombre de Autoridad",
        required=True
    )

    # Tipo autoridad
    tipoautoridad_id = fields.Many2one(
        'morenitapp.tipoautoridad',
        string="Tipo de Autoridad",
        required=True
    )

    # Nombre utilizado en saludas/cartas
    nombreSaluda = fields.Char(
        string="Nombre de Saluda de Autoridad",
        required=True
    )

    # Cargo institucional
    cargo = fields.Char(
        string="Cargo de Autoridad",
        required=True
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

    telefono = fields.Char(
        string="Teléfono de Autoridad"
    )

    correoElectronico = fields.Char(
        string="Correo Electrónico de Autoridad"
    )

    # Observaciones
    observaciones = fields.Text(
        string="Observaciones de Autoridad"
    )

    # VALIDACIÓN CÓDIGO ÚNICO
    @api.constrains('codAutoridad')
    def _check_codAutoridad_unique(self):

        for record in self:

            # Cuenta registros con mismo código
            if self.search_count([
                ('codAutoridad', '=', record.codAutoridad)
            ]) > 1:

                raise ValidationError(
                    "El código de autoridad debe ser único."
                )

    # VALIDACIÓN EMAIL
    @api.constrains('correoElectronico')
    def _check_email_format(self):

        import re

        # Expresión regular email
        email_regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'

        for record in self:

            # Si existe email y no cumple formato
            if (
                record.correoElectronico and
                not re.match(email_regex, record.correoElectronico)
            ):

                raise ValidationError(
                    "El correo electrónico no tiene un formato válido."
                )

    # SOBRESCRIBIR CREATE
    # Evita crear autoridades duplicadas

    @api.model
    def create(self, vals):

        if 'codAutoridad' in vals:

            existing = self.search([
                ('codAutoridad', '=', vals['codAutoridad'])
            ])

            if existing:

                raise ValidationError(
                    f"Ya existe una autoridad con código "
                    f"{vals['codAutoridad']}"
                )

        return super(Autoridad, self).create(vals)

    # SOBRESCRIBIR WRITE
    # Evita duplicados al editar
    def write(self, vals):

        if 'codAutoridad' in vals:

            for record in self:

                existing = self.search([
                    ('codAutoridad', '=', vals['codAutoridad']),
                    ('id', '!=', record.id)
                ])

                if existing:

                    raise ValidationError(
                        f"Ya existe una autoridad con código "
                        f"{vals['codAutoridad']}"
                    )

        return super(Autoridad, self).write(vals)