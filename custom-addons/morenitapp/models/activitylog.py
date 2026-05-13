from odoo import models, fields
class ActivityLog(models.Model):
    _name = 'morenitapp.activity.log'
    _description = 'Registro de actividad de la app'
    _order = 'create_date desc'
    user_id = fields.Char(string='ID Usuario', required=True)
    user_name = fields.Char(string='Nombre Usuario', required=True)
    action = fields.Selection([
        ('create', 'Crear'),
        ('update', 'Actualizar'),
        ('delete', 'Eliminar'),
    ], string='Acción', required=True)
    entity_name = fields.Char(string='Entidad', required=True)
    description = fields.Text(string='Descripción')