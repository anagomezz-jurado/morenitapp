from odoo import models, fields, api

class Cofradia(models.Model):
    _name = 'morenitapp.cofradia'
    _description = 'Cofradía'
    _rec_name = 'nombreCofradia'

    cifCofradia = fields.Char(string="CIF de Cofradía", required=True)
    nombreCofradia = fields.Char(string="Nombre de Cofradía", required=True)
    antiguedadCofradia = fields.Integer(string="Año de Fundación")
    
    # Localización
    direccionCofradia = fields.Many2one('morenitapp.calle', string="Calle")
    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    localidad_id = fields.Many2one('morenitapp.localidad', string="Localidad")
    
    # Contacto
    telefonoCofradia = fields.Char(string="Teléfono")
    emailCofradia = fields.Char(string="Email")
    paginaWeb = fields.Char(string="Página Web")
    
    observaciones = fields.Text(string="Observaciones")