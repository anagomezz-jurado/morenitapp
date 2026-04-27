from odoo import models, fields, api

class Organizador(models.Model):
    _name = 'morenitapp.organizador'
    _description = 'Organizador de la Hermandad'
    _rec_name = 'nombre'

    cif = fields.Char(string="CIF", required=True)
    nombre = fields.Char(string="Nombre", required=True)
    telefono = fields.Char(string="Teléfono")
    email = fields.Char(string="Email")

    # Usamos direccion_id por convención de Odoo
    direccion_id = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    piso = fields.Char(string="Piso")
    puerta = fields.Char(string="Puerta")

    logo = fields.Binary(string="Logo", attachment=True)
    firma_presidente = fields.Binary(string="Firma Presidente", attachment=True)
    firma_secretario = fields.Binary(string="Firma Secretario", attachment=True)
    firma_tesorero = fields.Binary(string="Firma Tesorero", attachment=True)