from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Cargo(models.Model):
    _name = 'morenitapp.cargo'
    _description = 'Cargo de la Hermandad'
    _rec_name = 'codCargo'

    codCargo = fields.Char(string="Código de Cargo", required=True)
    nombreCargo = fields.Char(string="Nombre de Cargo", required=True)
    tipocargo_id = fields.Many2one('morenitapp.tipocargo', string="Tipo de Cargo", required=True)
    fechaInicioCargo = fields.Date(string="Fecha de Inicio de Cargo", required=True)
    fechaFinCargo = fields.Date(string="Fecha de Fin de Cargo")
    direccion = fields.Many2one('morenitapp.calle', string="Calle", required=True)
    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    codPostal_id = fields.Many2one('morenitapp.codigopostal', string="Código Postal")
    localidad_id = fields.Many2one('morenitapp.localidad', string="Localidad")
    telefono = fields.Char(string="Teléfono de Cargo")
    observaciones = fields.Text(string="Observaciones de Cargo")
    motivo = fields.Text(string="Motivo de Cargo")
    textoSaludo = fields.Text(string="Texto de Saludo de Cargo")