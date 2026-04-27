from odoo import models, fields, api
from odoo.exceptions import ValidationError

class Evento(models.Model):
    _name = 'morenitapp.evento'
    _description = 'Eventos de la Hermandad'
    _rec_name = 'nombre'  # IMPORTANTE para que el calendario funcione

    cod_evento = fields.Char(string="Código de Evento", required=True)
    nombre = fields.Char(string="Nombre", required=True)
    descripcion = fields.Text(string="Descripción")

    fecha_inicio = fields.Datetime(string="Fecha de Inicio", required=True)
    fecha_fin = fields.Datetime(string="Fecha de Fin", required=True)

    lugar = fields.Char(string="Lugar")
    anio = fields.Integer(string="Año")

    organizador_id = fields.Many2one('morenitapp.organizador', string="Organizador")
    tipoevento_id = fields.Many2one('morenitapp.tipoevento', string="Tipo de Evento")

    @api.depends('fecha_inicio')
    def _compute_anio(self):
        for record in self:
            if record.fecha_inicio:
                record.anio = record.fecha_inicio.year

    @api.constrains('fecha_inicio', 'fecha_fin')
    def _check_fechas(self):
        for record in self:
            if record.fecha_fin and record.fecha_inicio and record.fecha_fin < record.fecha_inicio:
                raise ValidationError("La fecha de fin no puede ser anterior a la de inicio.")