from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo Evento
# Gestiona eventos de la hermandad

class Evento(models.Model):
    _name = 'morenitapp.evento'
    _description = 'Eventos de la Hermandad'

    # IMPORTANTE:
    # El calendario usa este campo como nombre del evento
    _rec_name = 'nombre'

    # Código evento
    cod_evento = fields.Char(
        string="Código de Evento",
        required=True
    )

    # Nombre evento
    nombre = fields.Char(
        string="Nombre",
        required=True
    )

    # Descripción
    descripcion = fields.Text(
        string="Descripción"
    )

    # Fecha inicio
    fecha_inicio = fields.Datetime(
        string="Fecha de Inicio",
        required=True
    )

    # Fecha fin
    fecha_fin = fields.Datetime(
        string="Fecha de Fin",
        required=True
    )

    # Lugar celebración
    lugar = fields.Char(
        string="Lugar"
    )

    # Año evento
    anio = fields.Integer(
        string="Año"
    )

    # Organizador evento
    organizador_id = fields.Many2one(
        'morenitapp.organizador',
        string="Organizador"
    )

    # Tipo evento
    tipoevento_id = fields.Many2one(
        'morenitapp.tipoevento',
        string="Tipo de Evento"
    )

    # COLOR AUTOMÁTICO
    # Toma automáticamente el color
    # definido en el tipo de evento
    color = fields.Char(
        related='tipoevento_id.color',
        string="Color del Evento",

        # Guarda valor en base datos
        store=True,

        # Solo lectura
        readonly=True
    )

    # CALCULAR AÑO DESDE FECHA INICIO
    @api.depends('fecha_inicio')
    def _compute_anio(self):

        for record in self:

            if record.fecha_inicio:

                record.anio = record.fecha_inicio.year

    # VALIDAR FECHAS
    # Fecha fin no puede ser menor
    # que fecha inicio

    @api.constrains('fecha_inicio', 'fecha_fin')
    def _check_fechas(self):

        for record in self:

            if (
                record.fecha_fin and
                record.fecha_inicio and
                record.fecha_fin < record.fecha_inicio
            ):

                raise ValidationError(
                    "La fecha de fin no puede ser anterior a la de inicio."
                )