from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Cargo(models.Model):
    _name = 'morenitapp.cargo'
    _description = 'Cargo de la Hermandad'
    _rec_name = 'nombreCargo'

    codCargo = fields.Char(string="Código de Cargo", required=True)
    nombreCargo = fields.Char(string="Nombre de Cargo", required=True)
    tipocargo_id = fields.Many2one('morenitapp.tipocargo', string="Tipo de Cargo", required=True)
    
    fechaInicioCargo = fields.Date(string="Fecha de Inicio de Cargo", required=True)
    fechaFinCargo = fields.Date(string="Fecha de Fin de Cargo")
    
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
    
    telefono = fields.Char(string="Teléfono de Cargo")
    
    # Información adicional
    observaciones = fields.Text(string="Observaciones de Cargo")
    motivo = fields.Text(string="Motivo de Cargo")
    textoSaludo = fields.Text(string="Texto de Saludo de Cargo")