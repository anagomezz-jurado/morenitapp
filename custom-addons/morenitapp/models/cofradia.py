from odoo import models, fields, api

class Cofradia(models.Model):
    _name = 'morenitapp.cofradia'
    _description = 'Cofradía'
    _rec_name = 'nombreCofradia'

    cifCofradia = fields.Char(string="CIF de Cofradía", required=True)
    nombreCofradia = fields.Char(string="Nombre de Cofradía", required=True)
    antiguedadCofradia = fields.Integer(string="Año de Fundación")
    nombreResponsable = fields.Char(string="Nombre del Responsable")


   #Direccion
    calle_id = fields.Many2one('morenitapp.calle', string="Calle")
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
    
    # Contacto
    telefonoCofradia = fields.Char(string="Teléfono")
    emailCofradia = fields.Char(string="Email")
    paginaWeb = fields.Char(string="Página Web")
    
    observaciones = fields.Text(string="Observaciones")