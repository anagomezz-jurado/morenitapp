import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class EventoCultoController(http.Controller):

    def _json_response(self, data, status=200):
        return request.make_response(
            json.dumps(data), 
            headers=[
                ('Content-Type', 'application/json'),
                ('Access-Control-Allow-Origin', '*'),
                ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
                ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
            ], 
            status=status
        )

    @http.route(['/api/organizadores', '/api/organizadores/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
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
                    "direccion_id": r.direccion_id.id if r.direccion_id else None,
                    "piso": r.piso or "",
                    "puerta": r.puerta or "",
                    # Decodificación de binarios a string base64
                    "logo": r.logo.decode('utf-8') if r.logo else None,
                    "firma_presidente": r.firma_presidente.decode('utf-8') if r.firma_presidente else None,
                    "firma_secretario": r.firma_secretario.decode('utf-8') if r.firma_secretario else None,
                    "firma_tesorero": r.firma_tesorero.decode('utf-8') if r.firma_tesorero else None,
                } for r in records]
                return self._json_response(data if not id else data[0])

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if request.httprequest.method == 'POST':
                # Odoo acepta automáticamente strings base64 en campos Binary
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
            return self._json_response({"error": str(e)}, status=500)

    # --- GESTIÓN DE EVENTOS ---
    @http.route(['/api/eventos', '/api/eventos/<int:id>'], 
            type='http', auth='public', 
            methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
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
                    # ✅ Formato [id, "nombre"] para Flutter
                    "organizador_id": [r.organizador_id.id, r.organizador_id.nombre] if r.organizador_id else None,
                    "tipoevento_id": [r.tipoevento_id.id, r.tipoevento_id.nombre_tipo_evento] if r.tipoevento_id else None,
                    "tipo_nombre": r.tipoevento_id.nombre_tipo_evento if r.tipoevento_id else "General",
                    "color": r.tipoevento_id.color if r.tipoevento_id and r.tipoevento_id.color else "#3498db",
                } for r in records]
                return self._json_response(data if not id else (data[0] if data else {}))

            body = {}
            if request.httprequest.data:
                body = json.loads(request.httprequest.data.decode('utf-8'))
            
            # ✅ Elimina nulos para que Odoo no los rechace
            body = {k: v for k, v in body.items() if v is not None}

            if request.httprequest.method == 'POST':
                if not body.get('nombre'):
                    return self._json_response({"error": "Falta el nombre"}, status=400)
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