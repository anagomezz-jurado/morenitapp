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
                        "nombre_completo": h.nombre_completo or "",
                        "dni": h.dni or "",
                        "email": h.email or "",
                        "telefono": h.telefono or "",
                        "sexo": h.sexo or "Hombre",
                        "bautizado": bool(h.bautizado),
                        "fecha_nacimiento": h.fecha_nacimiento.strftime('%Y-%m-%d') if h.fecha_nacimiento else None,
                        "fecha_alta": h.fecha_alta.strftime('%Y-%m-%d') if h.fecha_alta else "",
                        "fecha_baja": h.fecha_baja.strftime('%Y-%m-%d') if h.fecha_baja else None,
                        "motivo_baja": h.motivo_baja or "",
                        "fecha_reactivacion": h.fecha_reactivacion.strftime('%Y-%m-%d') if h.fecha_reactivacion else None,
                        "metodo_pago": h.metodo_pago or "metalico",
                        "calle_id": h.calle_id.id if h.calle_id else None,
                        "numero": h.numero or "",
                        "escalera": h.escalera or "",
                        "bloque": h.bloque or "",
                        "portal": h.portal or "",
                        "piso": h.piso or "",
                        "puerta": h.puerta or "",
                        "estado": h.estado or "activo",
                        "observaciones": h.observaciones or "",
                        "iban_calculado": h.iban or "",  # Campo computado del modelo
                        "datos_banco": [
                            {
                                "id": b.id,
                                "iban": b.iban or "",
                                "banco": b.banco or "",
                                "sucursal": b.sucursal or "",
                                "cuenta": b.cuenta or "",
                            } for b in h.datos_banco_ids
                        ],
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

                # 2. LIMPIEZA DE CAMPOS (Solo escribibles)
                campos_modelo = sudo_env._fields
                datos_validos = {}
                # No enviamos campos computados o readonly de dirección
                prohibidos = ['id', 'codigo_hermano', 'nombre_completo', 'iban', 'localidad_id', 'codPostal_id', 'provincia_id']
                
                for k, v in params.items():
                    if k in campos_modelo and k not in prohibidos:
                        # Odoo usa False para valores nulos/vacíos
                        datos_validos[k] = v if v not in ["", "false", "null", None, False] else False

                # 3. MANEJO DE DATOS BANCARIOS (Relación One2many)
                # Si la App envía 'iban', 'banco', etc., creamos/editamos el registro relacionado
                if params.get('iban') or params.get('numero_cuenta'):
                    banco_vals = {
                        'iban': params.get('iban', False),
                        'banco': params.get('banco', False),
                        'sucursal': params.get('sucursal', False),
                        'cuenta': params.get('numero_cuenta', params.get('cuenta', False)),
                    }
                    
                    if hermano and hermano.exists() and hermano.datos_banco_ids:
                        # (1, ID, valores) -> Actualiza el banco existente
                        datos_validos['datos_banco_ids'] = [(1, hermano.datos_banco_ids[0].id, banco_vals)]
                    else:
                        # (0, 0, valores) -> Crea un nuevo registro de banco
                        datos_validos['datos_banco_ids'] = [(0, 0, banco_vals)]

                # 4. LÓGICA DE ESTADOS
                if hermano and hermano.exists():
                    nuevo_estado = datos_validos.get('estado')
                    if nuevo_estado == 'activo' and hermano.estado == 'baja':
                        datos_validos.update({
                            'fecha_reactivacion': fields.Date.today(),
                            'fecha_baja': False,
                            'motivo_baja': False
                        })
                    elif nuevo_estado == 'baja' and hermano.estado != 'baja':
                        datos_validos['fecha_baja'] = fields.Date.today()

                # 5. GUARDAR
                if method == 'POST' and not (hermano and hermano.exists()):
                    nuevo = sudo_env.create(datos_validos)
                    return self._json_response({"status": "created", "id": nuevo.id})
                else:
                    hermano.write(datos_validos)
                    return self._json_response({"status": "success", "id": hermano.id})

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