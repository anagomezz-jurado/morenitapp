from odoo import models, fields, api

class Libro(models.Model):
    _name = 'morenitapp.libro'
    _description = 'Libros de la Hermandad'
    _rec_name = 'nombre'

    cod_libro = fields.Char(string="Código de Libro", required=True)
    nombre = fields.Char(string="Nombre del Libro", required=True)
    anio = fields.Integer(string="Año del Libro", required=True)
    descripcion = fields.Text(string="Descripción")
    
    # Nombres finales en snake_case
    importe = fields.Float(string="Importe Total")
    fecha_recibo = fields.Date(string="Fecha Recibo")
    texto_recibo_evento = fields.Char(string="Texto del Recibo del Evento")
    texto_anunciante = fields.Char(string="Texto del Anunciante del Libro")
    
    tipoevento_id = fields.Many2one('morenitapp.tipoevento', string="Tipo de Evento")
    
    adjuntos_ids = fields.Many2many(
        'ir.attachment', 
        string="Documentos del Libro",
        help="Sube aquí todos los archivos que necesites"
    )
    
    anunciantes_ids = fields.One2many(
        'morenitapp.libroanunciante', 
        'libro_id', 
        string="Anunciantes del Libro"
    )

    total_anunciantes = fields.Float(
        string="Total Recaudado Anunciantes",
        compute="_compute_total_anunciantes",
        store=True
    )

    @api.depends('anunciantes_ids.importe')
    def _compute_total_anunciantes(self):
        for record in self:
            record.total_anunciantes = sum(record.anunciantes_ids.mapped('importe'))