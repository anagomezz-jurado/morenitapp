import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class LibroController(http.Controller):

    def _json_response(self, data, status=200):
        """Headers necesarios para evitar errores de CORS en Flutter Web"""
        return request.make_response(
            json.dumps(data),
            headers=[
                ('Content-Type', 'application/json'),
                ('Access-Control-Allow-Origin', '*'),
                ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
                ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
            ],
            status=status
        )

    @http.route(['/api/libros', '/api/libros/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_libros(self, id=None, **kw):
        # Manejo de pre-flight CORS
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({})

        model = request.env['morenitapp.libro'].sudo()
        method = request.httprequest.method
        
        try:
            # --- GET: Listar o Consultar ---
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = model.search(domain)
                data = []
                for r in records:
                    data.append({
                        "id": r.id,
                        "cod_libro": r.cod_libro or "",
                        "nombre": r.nombre or "",
                        "anio": r.anio or 0,
                        "descripcion": r.descripcion or "",
                        "importe": r.importe or 0.0,
                        "fechaRecibo": r.fechaRecibo.strftime('%Y-%m-%d %H:%M:%S') if r.fechaRecibo else None,
                        "textoReciboEvento": r.textoReciboEvento or "",
                        "textoAnunciante": r.textoAnunciante or "",
                        "total_anunciantes": r.total_anunciantes or 0.0,
                        "tipoevento_id": [r.tipoevento_id.id, r.tipoevento_id.nombre_tipo_evento] if r.tipoevento_id else None,
                        "archivoLibro": r.archivoLibro.decode('utf-8') if r.archivoLibro else None,
                        "anunciantes": [{
                            "id": a.id,
                            "proveedor_nombre": a.proveedor_id.nombre if a.proveedor_id else "",
                            "importe": a.importe or 0.0,
                            "cobrado": a.cobrado or False,
                            "fecha_cobro": str(a.fecha_cobro) if a.fecha_cobro else None
                        } for a in r.anunciantes_ids]
                    })
                return self._json_response(data)

            # Extraer el Body para métodos de escritura
            body = {}
            if request.httprequest.data:
                body = json.loads(request.httprequest.data)

            # --- POST: Crear ---
            if method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"id": nuevo.id, "success": True}, status=201)

            # --- PUT: Editar ---
            if method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "Registro no encontrado"}, status=404)

            # --- DELETE: Eliminar ---
            if method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "Registro no encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"API Libros Error: {str(e)}")
            return self._json_response({"error": str(e), "success": False}, status=500)

    @http.route(['/api/libro-anunciantes', '/api/libro-anunciantes/<int:id>'], 
                type='http', auth='public', methods=['POST', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_libro_anunciantes(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': return self._json_response({})
        
        model = request.env['morenitapp.libroanunciante'].sudo()
        try:
            if request.httprequest.method == 'POST':
                body = json.loads(request.httprequest.data)
                nuevo = model.create(body)
                return self._json_response({"id": nuevo.id, "success": True})

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)
        except Exception as e:
            return self._json_response({"error": str(e)}, status=500)