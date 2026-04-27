import json
import logging
import traceback
from odoo import http, fields
from odoo.http import request

_logger = logging.getLogger(__name__)

class MorenitAppAPI(http.Controller):

    # --- UTILIDADES DE RESPUESTA ---
    def _response_cors(self):
        headers = [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
            ('Access-Control-Max-Age', '86400'),
        ]
        return request.make_response('', headers=headers)

    def _json_response(self, data, status=200):
        headers = [('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
        return request.make_response(json.dumps(data), headers=headers, status=status)

    def _error_response(self, message, status=500):
        return self._json_response({'error': message, 'status': status}, status=status)

    @http.route(['/api/hermanos', '/api/hermanos/<int:id_hermano>'], auth='public', type='http', csrf=False, methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    def hermanos_handler(self, id_hermano=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._response_cors()

        try:
            method = request.httprequest.method
            sudo_env = request.env['morenitapp.hermano'].sudo()

            # --- GET: Obtener ---
            if method == 'GET':
                domain = [('id', '=', id_hermano)] if id_hermano else []
                hermanos = sudo_env.search(domain)
                data = []
                for h in hermanos:
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
                        "metodo_pago": h.metodo_pago or "metalico",
                        "responsable": bool(h.responsable),
                        "calle_id": h.calle_id.id if h.calle_id else None,
                        "calle_nombre": h.calle_id.nombreCalle if h.calle_id else "",
                        "piso": h.piso or "",
                        "puerta": h.puerta or "",
                        "iban": h.iban or "",
                        "estado": h.estado or "activo",
                        "fecha_baja": h.fecha_baja.strftime('%Y-%m-%d') if h.fecha_baja else None,
                        "motivo_baja": h.motivo_baja or "",
                        "fecha_reactivacion": h.fecha_reactivacion.strftime('%Y-%m-%d') if h.fecha_reactivacion else None,
                    })
                return self._json_response(data)

            # --- POST / PUT: Crear o Actualizar ---
            if method in ['POST', 'PUT']:
                body = request.httprequest.data
                payload = json.loads(body) if body else {}
                params = payload.get('params', payload)

                # 1. Definir registro objetivo
                hermano = None
                if id_hermano or params.get('id'):
                    target_id = id_hermano or params.get('id')
                    hermano = sudo_env.browse(int(target_id))

                # 2. LIMPIEZA DE CAMPOS: Solo permitir campos que existen y son escribibles
                # Esto evita errores 500 por campos calculados o inexistentes (como fecha_reactivacion)
                campos_modelo = sudo_env._fields
                datos_validos = {}
                
                prohibidos = ['id', 'codigo_hermano', 'calle_nombre', 'nombre_completo']
                
                for k, v in params.items():
                    if k in campos_modelo and k not in prohibidos:
                        campo = campos_modelo[k]
                        if not campo.readonly and not (campo.compute and not campo.inverse):
                            # Convertimos "false" o vacío en False real de Python
                            datos_validos[k] = v if v not in ["", "false", "null", None, False] else False

                # 3. LÓGICA DE ESTADOS (Manejo de Bajas y Reactivación)
                if hermano and hermano.exists():
                    nuevo_estado = datos_validos.get('estado')
                    
                    # SI SE PASA A ACTIVO (Reactivación)
                    if nuevo_estado == 'activo' and hermano.estado == 'baja':
                        datos_validos.update({
                            'fecha_reactivacion': fields.Date.today(), # <--- AÑADIDO
                            'fecha_baja': False,
                            'motivo_baja': False
                        })
                    
                    # SI SE PASA A BAJA
                    elif nuevo_estado == 'baja' and hermano.estado != 'baja':
                        if not datos_validos.get('fecha_baja'):
                            datos_validos['fecha_baja'] = fields.Date.today()
                        datos_validos['fecha_reactivacion'] = False

                try:
                    if method == 'POST' and not hermano:
                        nuevo = sudo_env.create(datos_validos)
                        return self._json_response({"status": "created", "id": nuevo.id})
                    else:
                        hermano.write(datos_validos)
                        return self._json_response({"status": "success", "id": hermano.id})
                except Exception as e:
                    _logger.error(f"Error Odoo: {str(e)}")
                    return self._error_response(f"Odoo dice: {str(e)}", 500)

            # --- DELETE ---
            if method == 'DELETE' and id_hermano:
                hermano = sudo_env.browse(id_hermano)
                if hermano.exists():
                    hermano.unlink()
                    return self._json_response({"status": "deleted"})
                return self._error_response("No encontrado", 404)

        except Exception as e:
            _logger.error(traceback.format_exc())
            return self._error_response(str(e))