import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class MorenitAppAPI(http.Controller):

    def _get_cors_headers(self):
        return [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ]

    def _json_response(self, data, status=200):
        headers = [('Content-Type', 'application/json')] + self._get_cors_headers()
        return request.make_response(json.dumps(data), headers=headers, status=status)

    @http.route(['/api/hermanos', '/api/hermanos/<int:id_hermano>'], auth='public', type='http', csrf=False, methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    def hermanos_handler(self, id_hermano=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({}, status=200)

        try:
            method = request.httprequest.method
            sudo_env = request.env['morenitapp.hermano'].sudo()

            # --- LISTAR (GET) ---
            if method == 'GET':
                hermanos = sudo_env.search([])
                data = []
                for h in hermanos:
                    # Mapeo de calles asignadas (para el responsable)
                    calles_list = []
                    if h.responsable and h.calles_responsable_ids:
                        calles_list = [{
                            "id": c.id,
                            "nombre": c.nombreCalle or ""
                        } for c in h.calles_responsable_ids]

                    data.append({
                        "id": h.id,
                        "numero_hermano": h.numero_hermano or 0,
                        "codigo_hermano": h.codigo_hermano or "",
                        "nombre": h.nombre or "",
                        "apellido1": h.apellido1 or "",
                        "apellido2": h.apellido2 or "",
                        "dni": h.dni or "",
                        "email": h.email or "",
                        "telefono": h.telefono or "",
                        "sexo": h.sexo or "Hombre",
                        "fecha_alta": h.fecha_alta.strftime('%Y-%m-%d') if h.fecha_alta else "",
                        "fecha_nacimiento": h.fecha_nacimiento.strftime('%Y-%m-%d') if h.fecha_nacimiento else "",
                        "metodo_pago": h.metodo_pago or "metalico",
                        "responsable": bool(h.responsable),
                        "calles_asignadas": calles_list,
                        "calle_id": h.calle_id.id if h.calle_id else None,
                        "calle_nombre": h.calle_id.nombreCalle if h.calle_id else "",
                        "piso": h.piso or "",
                        "puerta": h.puerta or "",
                        "iban": h.iban or "",
                        "estado": h.estado or "activo",
                        "fecha_baja": h.fecha_baja.strftime('%Y-%m-%d') if h.fecha_baja else "",
                        "motivo_baja": h.motivo_baja or "",
                    })
                return self._json_response(data)

            # --- ELIMINAR (DELETE) ---
            if method == 'DELETE':
                if not id_hermano:
                    return self._json_response({"status": "error", "message": "ID requerido"}, status=400)
                hermano = sudo_env.browse(id_hermano)
                if hermano.exists():
                    hermano.unlink()
                    return self._json_response({"status": "success", "id": id_hermano})
                return self._json_response({"status": "error", "message": "Registro no encontrado"}, status=404)

            # --- CREAR (POST) / ACTUALIZAR (PUT) ---
            if method in ['POST', 'PUT']:
                body = request.httprequest.data
                params = json.loads(body).get('params', {}) if body else {}
                
                # 1. Limpieza de campos que Flutter envía pero Odoo no debe escribir directamente
                campos_prohibidos = ['id', 'calles_asignadas', 'nombre_completo', 'codigo_hermano', 'calle_nombre']
                for c in campos_prohibidos:
                    params.pop(c, None)

                # 2. Traducción de la relación de calles (Many2many)
                # Si en Flutter envías una lista de IDs en 'calles_responsable'
                if 'calles_responsable' in params:
                    ids_calles = params.pop('calles_responsable')
                    if isinstance(ids_calles, list):
                        params['calles_responsable_ids'] = [(6, 0, ids_calles)]

                # 3. Formateo de fechas para Odoo (evitar strings vacíos)
                fechas = ['fecha_nacimiento', 'fecha_alta', 'fecha_baja']
                for f in fechas:
                    if params.get(f) in ["", "null", False, None]:
                        params[f] = False

                # 4. Lógica de persistencia
                if method == 'PUT' or id_hermano:
                    target_id = id_hermano or params.get('id')
                    hermano = sudo_env.browse(target_id)
                    if not hermano.exists():
                        return self._json_response({"status": "error", "message": "No encontrado"}, status=404)
                    
                    # Si el estado cambia a activo, limpiamos datos de baja
                    if params.get('estado') == 'activo':
                        params['fecha_baja'] = False
                        params['motivo_baja'] = False
                        
                    hermano.write(params)
                    return self._json_response({"status": "success", "id": hermano.id})
                else:
                    # Crear nuevo
                    nuevo = sudo_env.create(params)
                    return self._json_response({"status": "success", "id": nuevo.id})

        except Exception as e:
            _logger.error(f"Error en API MorenitApp: {str(e)}")
            return self._json_response({"status": "error", "message": str(e)}, status=500)