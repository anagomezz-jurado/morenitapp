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
            ('Access-Control-Allow-Headers', 'Content-Type'),
        ])

    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['GET', 'OPTIONS'])
    def get_hermanos(self, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._options_response(['GET'])

        try:
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
                    "calle_nombre": h.calle_id.nombreCalle if h.calle_id else '',
                    "calle_id": h.calle_id.id if h.calle_id else False,
                    "piso": h.piso or '',
                    "puerta": h.puerta or '',
                    "metodo_pago": h.metodo_pago or 'metalico',
                    "iban": h.iban or '',
                    "responsable": bool(h.responsable),
                })
            return request.make_response(json.dumps(data), headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')])
        except Exception as e:
            return self._error_response(str(e))

    

    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['POST', 'OPTIONS'])
    def crear_hermano(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._options_response(['POST'])

        try:
            datos = json.loads(request.httprequest.data)
            iban_valor = datos.pop('iban', '') 
            
            # Si es pago por banco, inyectamos los datos bancarios en la creación
            if datos.get('metodo_pago') == 'banco' and iban_valor:
                # El formato (0, 0, {...}) crea el registro relacionado simultáneamente
                datos['datos_banco_ids'] = [(0, 0, {
                    'iban': iban_valor[0:4],
                    'banco': iban_valor[4:8],
                    'sucursal': iban_valor[8:12],
                    'cuenta': iban_valor[12:22],
                })]

            nuevo_hermano = request.env['morenitapp.hermano'].sudo().create(datos)
            return request.make_response(
                json.dumps({"status": "success", "id": nuevo_hermano.id}),
                headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
            )
        except Exception as e:
            _logger.error(f"Error en API crear_hermano: {str(e)}")
            return self._error_response(str(e))

    @http.route('/api/hermanos/<int:id>', auth='public', type='http', csrf=False, methods=['PUT', 'OPTIONS'])
    def update_hermano(self, id, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._options_response(['PUT'])
        
        try:
            datos = json.loads(request.httprequest.data)
            iban_valor = datos.pop('iban', None)
            hermano = request.env['morenitapp.hermano'].sudo().browse(id)
            
            if not hermano.exists():
                return self._error_response("Hermano no encontrado", status=404)

            if iban_valor is not None:
                if hermano.datos_banco_ids:
                    # Actualizar el primer registro bancario existente
                    hermano.datos_banco_ids[0].write({
                        'iban': iban_valor[0:4],
                        'banco': iban_valor[4:8],
                        'sucursal': iban_valor[8:12],
                        'cuenta': iban_valor[12:22],
                    })
                elif iban_valor:
                    # Crear si no tenía
                    datos['datos_banco_ids'] = [(0, 0, {
                        'iban': iban_valor[0:4],
                        'banco': iban_valor[4:8],
                        'sucursal': iban_valor[8:12],
                        'cuenta': iban_valor[12:22],
                    })]

            hermano.write(datos)
            return request.make_response(
                json.dumps({"status": "success"}), 
                headers=[('Content-Type', 'application/json'), ('Access-Control-Allow-Origin', '*')]
            )
        except Exception as e:
            return self._error_response(str(e))