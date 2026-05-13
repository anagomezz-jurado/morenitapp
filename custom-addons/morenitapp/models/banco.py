from odoo import models, fields, api
from odoo.exceptions import ValidationError

# ============================================================
# Modelo DatosBancarios
# Guarda cuentas bancarias de hermanos
# ============================================================

class DatosBancarios(models.Model):
    _name = 'morenitapp.banco'

    # Descripción visible
    _description = 'Datos Bancarios'
    
    # Hermano propietario de la cuenta
    hermano_id = fields.Many2one(
        'morenitapp.hermano',
        string="Hermano"
    )


    # Prefijo IBAN
    iban = fields.Char(
        string="IBAN",
        size=4
    )

    # Código banco
    banco = fields.Char(
        string="Banco",
        size=4
    )

    # Código sucursal
    sucursal = fields.Char(
        string="Sucursal",
        size=4
    )

    # Número de cuenta
    cuenta = fields.Char(
        string="Número de cuenta",
        size=10
    )

    # VALIDACIONES
    # Comprueba longitud de campos bancarios

    @api.constrains('banco', 'sucursal', 'cuenta')
    def _check_campos(self):

        for record in self:

            # Validación IBAN
            if record.banco and len(record.iban) != 4:

                raise ValidationError(
                    "El iban del banco debe tener 4 caracteres"
                )

            # Validación banco
            if record.banco and len(record.banco) != 4:

                raise ValidationError(
                    "El código del banco debe tener 4 caracteres"
                )

            # Validación sucursal
            if record.sucursal and len(record.sucursal) != 4:

                raise ValidationError(
                    "El código de la sucursal debe tener 4 caracteres"
                )

            # Validación cuenta bancaria
            if record.cuenta and len(record.cuenta) != 10:

                raise ValidationError(
                    "El número de cuenta debe tener 10 caracteres"
                )