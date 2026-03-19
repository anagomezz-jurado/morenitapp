from odoo import models, fields, api
from odoo.exceptions import ValidationError


class Cofradia(models.Model):
    _name = 'morenitapp.cofradia'
    _description = 'Cofradía'
    _rec_name = 'nombreCofradia'

    cifCofradia = fields.Char(string="CIF de Cofradía", required=True)
    nombreCofradia = fields.Char(string="Nombre de Cofradía", required=True)

    direccionCofradia = fields.Many2one(
        'morenitapp.calle',
        string="Calle"
    )

    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")


    telefonoCofradia = fields.Char(string="Teléfono")
    emailCofradia = fields.Char(string="Email")

    antiguedadCofradia = fields.Integer(
    string="Año de Fundación"
)

    paginaWeb = fields.Char(string="Página Web")

    observaciones = fields.Text(
        string="Observaciones"
    )