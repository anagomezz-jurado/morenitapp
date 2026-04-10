import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class MorenitAppAPI(http.Controller):

    def _error_response(self, message, status=500):
        return request.make_response(
            json.dumps({"status": "error", "message": message}),
            status=status,
            headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
        )

    def _options_response(self, methods):
        return request.make_response('', headers=[
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', ', '.join(methods + ['OPTIONS'])),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ])

    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['GET', 'OPTIONS'])
    def get_hermanos(self, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._options_response(['GET'])

        try:
            # --- CAMBIO NECESARIO: Buscamos TODOS para poder filtrar en la App ---
            hermanos = request.env['morenitapp.hermano'].sudo().search([])
            data = []
            for h in hermanos:
                def clean(val): return str(val) if val else ""

                data.append({
                    "id": h.id,
                    "numero_hermano": h.numero_hermano or 0,
                    "codigo_hermano": clean(h.codigo_hermano),
                    "nombre": clean(h.nombre),
                    "apellido1": clean(h.apellido1),
                    "apellido2": clean(h.apellido2),
                    "dni": clean(h.dni),
                    "telefono": clean(h.telefono),
                    "email": clean(h.email),
                    "sexo": h.sexo or 'Hombre',
                    "fecha_alta": h.fecha_alta.strftime('%Y-%m-%d') if h.fecha_alta else '',
                    "fecha_nacimiento": h.fecha_nacimiento.strftime('%Y-%m-%d') if h.fecha_nacimiento else '',
                    "calle_nombre": h.calle_id.nombreCalle if h.calle_id else '',
                    "calle_id": h.calle_id.id if h.calle_id else False,
                    "piso": clean(h.piso),
                    "puerta": clean(h.puerta),
                    "metodo_pago": h.metodo_pago or 'metalico',
                    "iban": clean(h.iban),
                    "responsable": bool(h.responsable),
                    # --- NUEVOS CAMPOS EN JSON ---
                    "estado": h.estado if h.estado else "activo",
                    "fecha_baja": h.fecha_baja.strftime('%Y-%m-%d') if h.fecha_baja else '',
                    "motivo_baja": clean(h.motivo_baja),
                })
            return request.make_response(json.dumps(data), headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')])
        except Exception as e:
            return self._error_response(str(e))

    @http.route('/api/hermanos/<int:id>', auth='public', type='http', csrf=False, methods=['PUT', 'OPTIONS'])
    def update_hermano(self, id, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._options_response(['PUT'])
        
        try:
            datos = json.loads(request.httprequest.data)
            hermano = request.env['morenitapp.hermano'].sudo().browse(id)

            # LIMPIEZA CRÍTICA: Convertir strings de mentira en valores reales de Python/Odoo
            for campo in ['fecha_nacimiento', 'fecha_baja', 'fecha_alta']:
                if campo in datos:
                    if datos[campo] in ["false", "null", "", False]:
                        datos[campo] = False # Odoo entiende False como NULL en la DB

            # Si el estado es activo, nos aseguramos de limpiar los campos de baja
            if datos.get('estado') == 'activo':
                datos['fecha_baja'] = False
                datos['motivo_baja'] = ""

            hermano.write(datos)
            return request.make_response(json.dumps({"status": "success"}), headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')])
        except Exception as e:
            return self._error_response(str(e))