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
    direccion = fields.Char(string="Dirección")
    observaciones = fields.Text(string="Observaciones")
    anunciante = fields.Boolean(string="¿Es Anunciante?")

    def name_get(self):
        result = []
        for record in self:
            name = f"{record.cod_proveedor or ''} - {record.nombre or ''}"
            result.append((record.id, name))
        return result