from odoo import models, fields, api
from odoo.exceptions import ValidationError

# Modelo TipoEvento
# Representa los distintos tipos de eventos de la hermandad

class TipoEvento(models.Model):

    # Nombre técnico del modelo
    _name = 'morenitapp.tipoevento'

    # Descripción visible
    _description = 'Tipo de Evento de la Hermandad'

    # Campo que se mostrará como nombre del registro
    _rec_name = 'nombre_tipo_evento'

    # Código identificador del tipo de evento
    cod_tipo_evento = fields.Char(
        string="Código de Tipo de Evento",
        required=True
    )

    # Nombre descriptivo del evento
    nombre_tipo_evento = fields.Char(
        string="Nombre de Tipo de Evento",
        required=True
    )

    # Color hexadecimal para representar visualmente el evento
    color = fields.Char(
        string="Color Hexadecimal",
        default="#3498db",
        help="Ejemplo: #FF5733"
    )