from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Autoridad(models.Model):
    _name = 'morenitapp.autoridad'
    _description = 'Autoridad de la Hermandad'
    _rec_name = 'codAutoridad'

    codAutoridad = fields.Char(string="Código de Autoridad", required=True)
    nombreAutoridad = fields.Char(string="Nombre de Autoridad", required=True)
    tipoautoridad_id = fields.Many2one(
        'morenitapp.tipoautoridad',
        string="Tipo de Autoridad",
        required=True
    )
    nombreSaluda = fields.Char(string="Nombre de Saluda de Autoridad", required=True)
    cargo = fields.Char(string="Cargo de Autoridad", required=True)
    direccion = fields.Char(string="Dirección de Autoridad")
    codPostal_id = fields.Many2one('morenitapp.codigopostal', string="Código Postal")
    localidad_id = fields.Many2one('morenitapp.localidad', string="Localidad")
    telefono = fields.Char(string="Teléfono de Autoridad")
    correoElectronico = fields.Char(string="Correo Electrónico de Autoridad")
    observaciones = fields.Text(string="Observaciones de Autoridad")

    # ================= VALIDACIONES =================
    @api.constrains('codAutoridad')
    def _check_codAutoridad_unique(self):
        for record in self:
            if self.search_count([('codAutoridad', '=', record.codAutoridad)]) > 1:
                raise ValidationError("El código de autoridad debe ser único.")

    @api.constrains('correoElectronico')
    def _check_email_format(self):
        import re
        email_regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'
        for record in self:
            if record.correoElectronico and not re.match(email_regex, record.correoElectronico):
                raise ValidationError("El correo electrónico no tiene un formato válido.")

    # ================= SOBRESCRIBIR CREATE =================
    @api.model
    def create(self, vals):
        # Validación extra antes de crear
        if 'codAutoridad' in vals:
            existing = self.search([('codAutoridad', '=', vals['codAutoridad'])])
            if existing:
                raise ValidationError(f"Ya existe una autoridad con código {vals['codAutoridad']}")
        return super(Autoridad, self).create(vals)

    # ================= SOBRESCRIBIR WRITE =================
    def write(self, vals):
        # Validar cambios de código
        if 'codAutoridad' in vals:
            for record in self:
                existing = self.search([('codAutoridad', '=', vals['codAutoridad']), ('id', '!=', record.id)])
                if existing:
                    raise ValidationError(f"Ya existe una autoridad con código {vals['codAutoridad']}")
        return super(Autoridad, self).write(vals)