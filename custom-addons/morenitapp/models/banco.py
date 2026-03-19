from odoo import models, fields, api
from odoo.exceptions import ValidationError

class DatosBancarios(models.Model):
    _name = 'morenitapp.banco'
    _description = 'Datos Bancarios'

    hermano_id = fields.Many2one('morenitapp.hermano', string="Hermano")
    iban = fields.Char(string="IBAN", size=4)
    banco = fields.Char(string="Banco", size=4)
    sucursal = fields.Char(string="Sucursal", size=4)
    cuenta = fields.Char(string="Número de cuenta", size=10)

    @api.constrains('banco','sucursal','cuenta')
    def _check_campos(self):
        for record in self:
            if record.banco and len(record.banco) != 4:
                raise ValidationError("El código del banco debe tener 4 caracteres")
            if record.sucursal and len(record.sucursal) != 4:
                raise ValidationError("El código de la sucursal debe tener 4 caracteres")
            if record.cuenta and len(record.cuenta) != 10:
                raise ValidationError("El número de cuenta debe tener 10 caracteres")