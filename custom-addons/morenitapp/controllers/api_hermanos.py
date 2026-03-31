import json
import logging
import traceback
from odoo import http, fields
from odoo.http import request

_logger = logging.getLogger(__name__)

class MorenitAppAPI(http.Controller):

    def _error_response(self, message, status=500):
        return request.make_response(
            json.dumps({"status": "error", "message": message}),
            status=status,
            headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
        )

    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['GET', 'OPTIONS'])
    def get_hermanos(self, **kw):
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=[
                ('Access-Control-Allow-Origin', '*'),
                ('Access-Control-Allow-Methods', 'GET, OPTIONS'),
                ('Access-Control-Allow-Headers', 'Content-Type'),
            ])

        try:
            # Buscamos hermanos que NO tengan fecha de baja
            hermanos = request.env['morenitapp.hermano'].sudo().search([('fecha_baja', '=', False)])
            data = []
            for h in hermanos:
                data.append({
                    "id": h.id,
                    "numero_hermano": h.numero_hermano or 0,
                    "codigo_hermano": h.codigo_hermano or '',
                    "nombre": h.nombre or '',
                    "apellido1": h.apellido1 or '',
                    "apellido2": h.apellido2 or '',
                    "dni": h.dni or '',
                    "telefono": h.telefono or '',
                    "email": h.email or '',
                    "sexo": h.sexo or 'Hombre',
                    "fecha_alta": h.fecha_alta.strftime('%Y-%m-%d') if h.fecha_alta else '',
                    "fecha_nacimiento": h.fecha_nacimiento.strftime('%Y-%m-%d') if h.fecha_nacimiento else '',
                    # Usamos safe navigation para evitar errores si no hay calle asignada
                    "calle_nombre": h.calle_id.nombreCalle if h.calle_id else 'Sin Calle',
                    "piso": h.piso or '',
                    "puerta": h.puerta or '',
                    "metodo_pago": h.metodo_pago or 'metalico',
                    "responsable": bool(h.responsable),
                })
            
            return request.make_response(
                json.dumps(data),
                headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
            )
        except Exception as e:
            _logger.error("Error en GET hermanos: %s", traceback.format_exc())
            return self._error_response(str(e))

    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['POST', 'OPTIONS'])
    def crear_hermano(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return request.make_response('', headers=[
                ('Access-Control-Allow-Origin', '*'),
                ('Access-Control-Allow-Methods', 'POST, OPTIONS'),
                ('Access-Control-Allow-Headers', 'Content-Type'),
            ])
        
        try:
            body = request.httprequest.data
            datos = json.loads(body)

            # Validación de campos obligatorios antes de crear
            campos_obligatorios = ['numero_hermano', 'nombre', 'apellido1', 'dni', 'calle_id']
            for campo in campos_obligatorios:
                if campo not in datos or not datos[campo]:
                    return self._error_response(f"El campo '{campo}' es obligatorio.", status=400)

            nuevo = request.env['morenitapp.hermano'].sudo().create(datos)
            
            return request.make_response(
                json.dumps({
                    "status": "success",
                    "id": nuevo.id,
                    "codigo": nuevo.codigo_hermano
                }),
                headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
            )
        except Exception as e:
            _logger.error("Error en POST crear_hermano: %s", traceback.format_exc())
            return self._error_response(str(e))