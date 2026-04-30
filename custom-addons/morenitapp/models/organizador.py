from odoo import models, fields, api

class Organizador(models.Model):
    _name = 'morenitapp.organizador'
    _description = 'Organizador de la Hermandad'
    _rec_name = 'nombre'

    cif = fields.Char(string="CIF", required=True)
    nombre = fields.Char(string="Nombre", required=True)
    telefono = fields.Char(string="Teléfono")
    email = fields.Char(string="Email")

   #Direccion
    calle_id = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    # Campos relacionados (automáticos)
    localidad_id = fields.Many2one('morenitapp.localidad', related='calle_id.localidad_id', string="Localidad", store=True, readonly=True)
    codPostal_id = fields.Many2one('morenitapp.codigopostal', related='calle_id.codPostal_id', string="C.P.", store=True, readonly=True)
    provincia_id = fields.Many2one('morenitapp.provincia', related='localidad_id.codProvincia_id', string="Provincia", store=True, readonly=True)

    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    numero = fields.Char(string="Número")
    bloque = fields.Char(string="Bloque")
    escalera = fields.Char(string="Escalera")
    portal = fields.Char(string="Portal")

    logo = fields.Binary(string="Logo", attachment=True)
    firma_presidente = fields.Binary(string="Firma Presidente", attachment=True)
    firma_secretario = fields.Binary(string="Firma Secretario", attachment=True)
    firma_tesorero = fields.Binary(string="Firma Tesorero", attachment=True)