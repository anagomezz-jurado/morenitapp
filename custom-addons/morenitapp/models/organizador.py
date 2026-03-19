from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Organizador(models.Model):
    _name = 'morenitapp.organizador'
    _description = 'Organizador de la Hermandad'
    _rec_name = 'nombre'

    cif = fields.Char(string="CIF del Organizador", required=True)
    nombre = fields.Char(string="Nombre del Organizador", required=True)

    telefono = fields.Char(string="Teléfono")
    email = fields.Char(string="Correo Electrónico")

    direccion = fields.Many2one(
        'morenitapp.calle',
        string="Calle",
        required=True
    )

    piso = fields.Char(string="Piso")
    puerta = fields.Char(string="Puerta")

    logo = fields.Binary(string="Logo del Organizador")
    firma_presidente = fields.Binary(string="Firma del Presidente")
    firma_secretario = fields.Binary(string="Firma del Secretario")
    firma_tesorero = fields.Binary(string="Firma del Tesorero")