import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class SecretariaController(http.Controller):

    def _json_response(self, data, status=200):
        """Helper para devolver JSON con cabeceras CORS completas"""
        headers = [
            ('Content-Type', 'application/json'),
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ]
        return request.make_response(json.dumps(data), headers=headers, status=status)

    @http.route('/api/test', auth='public', type='http', methods=['GET', 'POST', 'OPTIONS'], cors='*')
    def test_connection(self, **kwargs):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({})
        return self._json_response({"success": True, "message": "Conectado a Secretaría correctamente"})

    # ==========================================
    # --- API AUTORIDADES (CRUD) ---
    # ==========================================

    @http.route(['/api/autoridades', '/api/autoridades/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_autoridades(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': return self._json_response({})
        
        model = request.env['morenitapp.autoridad'].sudo()
        method = request.httprequest.method

        try:
            if method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = [{"id": r.id, "nombreAutoridad": r.nombreAutoridad or ""} for r in records]
                return self._json_response(data)

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            return self._json_response({"success": False, "error": str(e)}, status=500)

    # ==========================================
    # --- API CARGOS (CRUD) ---
    # ==========================================

    @http.route(['/api/cargos', '/api/cargos/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_cargos(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': return self._json_response({})
        
        model = request.env['morenitapp.cargo'].sudo()
        method = request.httprequest.method

        try:
            if method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = [{"id": r.id, "nombreCargo": r.nombreCargo or ""} for r in records]
                return self._json_response(data)

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            return self._json_response({"success": False, "error": str(e)}, status=500)

    # ==========================================
    # --- API COFRADÍAS (CRUD) ---
    # ==========================================

    @http.route(['/api/cofradias', '/api/cofradias/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False, cors='*')
    def api_cofradias(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': return self._json_response({})
        
        model = request.env['morenitapp.cofradia'].sudo()
        method = request.httprequest.method

        try:
            if method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = []
                for r in records:
                    data.append({
                        "id": r.id,
                        "nombre": r.nombreCofradia or "",
                        "localidad_id": [r.localidad_id.id, r.localidad_id.nombreLocalidad] if hasattr(r, 'localidad_id') and r.localidad_id else None
                    })
                return self._json_response(data)

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            return self._json_response({"success": False, "error": str(e)}, status=500)