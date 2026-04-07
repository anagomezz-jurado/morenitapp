import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class EventoCultoController(http.Controller):

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
    
    # --- GESTIÓN DE ORGANIZADORES ---
    @http.route(['/api/organizadores', '/api/organizadores/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_organizadores(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({})

        model = request.env['morenitapp.organizador'].sudo()
        try:
            if request.httprequest.method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = model.search(domain)
                data = [{
                    "id": r.id,
                    "cif": r.cif or "",
                    "nombre": r.nombre or "",
                    "telefono": r.telefono or "",
                    "email": r.email or "",
                    "logo": r.logo.decode('utf-8') if r.logo else None
                } for r in records]
                return self._json_response(data)

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if request.httprequest.method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"id": nuevo.id, "success": True})

            if request.httprequest.method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"Error en Organizadores: {str(e)}")
            return self._json_response({"error": str(e)}, status=500)

    # --- GESTIÓN DE EVENTOS ---
    @http.route(['/api/eventos', '/api/eventos/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_eventos(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': 
            return self._json_response({})
            
        model = request.env['morenitapp.evento'].sudo()
        try:
            if request.httprequest.method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = [{
                    "id": r.id,
                    "cod_evento": r.cod_evento or "",
                    "nombre": r.nombre or "",
                    "descripcion": r.descripcion or "",
                    "fecha_inicio": r.fecha_inicio.strftime('%Y-%m-%d %H:%M:%S') if r.fecha_inicio else None,
                    "fecha_fin": r.fecha_fin.strftime('%Y-%m-%d %H:%M:%S') if r.fecha_fin else None,
                    "lugar": r.lugar or "",
                    "anio": r.anio or 0,
                    "organizador_id": [r.organizador_id.id, r.organizador_id.nombre] if r.organizador_id else None,
                    "tipoevento_id": [r.tipoevento_id.id, r.tipoevento_id.nombre_tipo_evento] if r.tipoevento_id else None
                } for r in records]
                return self._json_response(data)

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if request.httprequest.method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if request.httprequest.method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"Error en Eventos: {str(e)}")
            return self._json_response({"error": str(e)}, status=500)