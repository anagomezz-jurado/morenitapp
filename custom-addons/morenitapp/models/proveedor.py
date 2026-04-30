from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Proveedor(models.Model):
    _name = 'morenitapp.proveedor'
    _description = 'Proveedores de la Hermandad'

    cod_proveedor = fields.Char(string="Código de Proveedor", required=True)
    nombre = fields.Char(required=True)
    contacto = fields.Char(string="Persona de Contacto")
    telefono = fields.Char(string="Teléfono")
    email = fields.Char(string="Correo Electrónico")
    grupo_id = fields.Many2one('morenitapp.grupoproveedor', string="Grupo de Proveedor")
   #Direccion
    calle_id = fields.Many2one('morenitapp.calle', string="Calle")
    localidad_id = fields.Many2one('morenitapp.localidad', related='calle_id.localidad_id', string="Localidad", store=True, readonly=True)
    codPostal_id = fields.Many2one('morenitapp.codigopostal', related='calle_id.codPostal_id', string="C.P.", store=True, readonly=True)
    provincia_id = fields.Many2one('morenitapp.provincia', related='localidad_id.codProvincia_id', string="Provincia", store=True, readonly=True)

    puerta = fields.Char(string="Puerta")
    piso = fields.Char(string="Piso")
    numero = fields.Char(string="Número")
    bloque = fields.Char(string="Bloque")
    escalera = fields.Char(string="Escalera")
    portal = fields.Char(string="Portal")

    observaciones = fields.Text(string="Observaciones")
    anunciante = fields.Boolean(string="¿Es Anunciante?")

    def name_get(self):
        result = []
        for record in self:
            name = f"{record.cod_proveedor or ''} - {record.nombre or ''}"
            result.append((record.id, name))
        return result 