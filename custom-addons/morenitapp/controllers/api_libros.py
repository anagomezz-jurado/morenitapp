import json
import logging
from odoo import http, fields
from odoo.http import request

_logger = logging.getLogger(__name__)

class LibroController(http.Controller):

    def _get_cors_headers(self):
        return [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ]

    def _json_response(self, data, status=200):
        headers = [('Content-Type', 'application/json')] + self._get_cors_headers()
        return request.make_response(json.dumps(data), headers=headers, status=status)

    def _get_params(self):
        if request.httprequest.data:
            try:
                data = json.loads(request.httprequest.data.decode('utf-8'))
                return data.get('params', data)
            except Exception:
                return {}
        return request.params.copy()

    @http.route(['/api/libros', '/api/libros/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_libros(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({}, status=200)

        sudo_model = request.env['morenitapp.libro'].sudo()
        method = request.httprequest.method
        
        try:
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = sudo_model.search(domain)
                data = []
                for r in records:
                    data.append({
                        "id": r.id,
                        "cod_libro": r.cod_libro or "",
                        "nombre": r.nombre or "",
                        "anio": r.anio or 0,
                        "descripcion": r.descripcion or "",
                        "importe": r.importe or 0.0,
                        "fechaRecibo": fields.Datetime.to_string(r.fechaRecibo) if r.fechaRecibo else None,
                        "tipoevento_id": r.tipoevento_id.id if r.tipoevento_id else None,
                        "archivoLibro": r.archivoLibro.decode('utf-8') if r.archivoLibro else None,
                        "total_anunciantes": r.total_anunciantes,
                        "anunciantes": [{
                            "id": a.id,
                            "proveedor_id": a.proveedor_id.id,
                            "proveedor_nombre": a.proveedor_id.nombre if a.proveedor_id else "Sin nombre",
                            "importe": a.importe,
                            "cobrado": a.cobrado,
                            "fecha_cobro": fields.Date.to_string(a.fecha_cobro) if a.fecha_cobro else None
                        } for a in r.anunciantes_ids]
                    })
                return self._json_response(data)

            if method in ['POST', 'PUT']:
                params = self._get_params()
                anunciantes_data = params.pop('anunciantes', [])
                id_record = id or params.pop('id', None)
                
                # Limpiar vals para que solo entren campos reales del modelo Libro
                final_vals = {k: v for k, v in params.items() if k in sudo_model._fields}

                # Gestión de One2many para Anunciantes
                if anunciantes_data:
                    commands = []
                    for anc in anunciantes_data:
                        anc_vals = {
                            'importe': float(anc.get('importe', 0.0)),
                            'cobrado': anc.get('cobrado', False),
                            'fecha_cobro': anc.get('fecha_cobro') or False,
                            'proveedor_id': anc.get('proveedor_id'),
                        }
                        if anc.get('id'):
                            commands.append((1, int(anc['id']), anc_vals))
                        else:
                            commands.append((0, 0, anc_vals))
                    final_vals['anunciantes_ids'] = commands

                if id_record:
                    record = sudo_model.browse(int(id_record))
                    if not record.exists():
                        return self._json_response({"success": False, "error": "No encontrado"}, status=404)
                    record.write(final_vals)
                    return self._json_response({"success": True, "id": record.id})
                else:
                    nuevo = sudo_model.create(final_vals)
                    return self._json_response({"success": True, "id": nuevo.id}, status=201)

            if method == 'DELETE':
                record = sudo_model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"success": False, "error": "No encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"Error API: {str(e)}")
            return self._json_response({"error": str(e)}, status=500)