from odoo import models, fields, api

# Modelo Libro
# Gestiona libros/eventos/publicaciones

class Libro(models.Model):

    _name = 'morenitapp.libro'
    _description = 'Libros de la Hermandad'

    # Campo mostrado como nombre
    _rec_name = 'nombre'


    cod_libro = fields.Char(
        string="Código de Libro",
        required=True
    )

    nombre = fields.Char(
        string="Nombre del Libro",
        required=True
    )

    anio = fields.Integer(
        string="Año del Libro",
        required=True
    )

    descripcion = fields.Text(
        string="Descripción"
    )

    # DATOS ECONÓMICOS
    importe = fields.Float(
        string="Importe Total"
    )

    fecha_recibo = fields.Date(
        string="Fecha Recibo"
    )

    texto_recibo_evento = fields.Char(
        string="Texto del Recibo del Evento"
    )

    texto_anunciante = fields.Char(
        string="Texto del Anunciante del Libro"
    )

    # RELACIONES
    tipoevento_id = fields.Many2one(
        'morenitapp.tipoevento',
        string="Tipo de Evento"
    )

    # Archivos adjuntos
    adjuntos_ids = fields.Many2many(
        'ir.attachment',
        string="Documentos del Libro",
        help="Sube aquí todos los archivos que necesites"
    )

    # Lista de anunciantes
    anunciantes_ids = fields.One2many(
        'morenitapp.libroanunciante',
        'libro_id',
        string="Anunciantes del Libro"
    )

    # CAMPOS CALCULADOS
    total_anunciantes = fields.Float(
        string="Total Recaudado Anunciantes",
        compute="_compute_total_anunciantes",
        store=True
    )

    # SUMA TOTAL DE IMPORTES
    @api.depends('anunciantes_ids.importe')
    def _compute_total_anunciantes(self):

        for record in self:

            record.total_anunciantes = sum(
                record.anunciantes_ids.mapped('importe')
            )