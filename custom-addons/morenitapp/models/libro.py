from odoo import models, fields, api

class Libro(models.Model):
    _name = 'morenitapp.libro'
    _description = 'Libros de la Hermandad'
    _rec_name = 'nombre'

    cod_libro = fields.Char(string="Código de Libro", required=True)
    nombre = fields.Char(string="Nombre del Libro", required=True)
    anio = fields.Integer(string="Año del Libro", required=True)
    descripcion = fields.Text()
    importe = fields.Float(string="Importe Total")
    fechaRecibo = fields.Datetime(string="Fecha Recibo")
    textoReciboEvento = fields.Char(string="Texto del Recibo del Evento")
    textoAnunciante = fields.Char(string="Texto del Anunciante del Libro")
    tipoevento_id = fields.Many2one('morenitapp.tipoevento', string="Tipo de Evento")
    archivoLibro = fields.Binary(string="Archivo del Libro")
    
    # RELACIÓN CORREGIDA: Apunta a 'libro_id' que ahora sí definimos abajo
    anunciantes_ids = fields.One2many('morenitapp.libroanunciante', 'libro_id', string="Anunciantes del Libro")

    total_anunciantes = fields.Float(
        string="Total Recaudado Anunciantes",
        compute="_compute_total_anunciantes",
        store=True
    )

    @api.depends('anunciantes_ids.importe')
    def _compute_total_anunciantes(self):
        for record in self:
            record.total_anunciantes = sum(record.anunciantes_ids.mapped('importe'))

class LibroAnunciante(models.Model):
    _name = 'morenitapp.libroanunciante'
    _description = 'Relación entre Libro y Anunciante'

    # Este es el campo que Odoo no encontraba y causaba el Internal Server Error
    libro_id = fields.Many2one('morenitapp.libro', string="Libro", ondelete='cascade')
    
    # Relación con el proveedor (que debe tener el check de anunciante)
    proveedor_id = fields.Many2one('morenitapp.proveedor', string="Anunciante", required=True)
    importe = fields.Float(string="Importe", required=True)
    cobrado = fields.Boolean(string="Cobrado", default=False)
    fecha_cobro = fields.Date(string="Fecha de Cobro")