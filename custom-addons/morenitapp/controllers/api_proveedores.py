from odoo import http
from odoo.http import request
import json

class ProveedorController(http.Controller):

    def _cors_response(self, data=None):
        """ Inyecta cabeceras CORS necesarias para Flutter Web y Mobile """
        headers = [
            ('Content-Type', 'application/json'),
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
        ]
        return request.make_response(json.dumps(data or {}), headers=headers)

    @http.route('/api/proveedores', auth='public', type='http', methods=['GET', 'POST', 'OPTIONS'], csrf=False)
    def get_proveedores(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._cors_response()

        proveedores = request.env['morenitapp.proveedor'].sudo().search([])
        data = []
        for p in proveedores:
            data.append({
                'id': p.id,
                'cod_proveedor': p.cod_proveedor or '',
                'nombre': p.nombre or '',
                'contacto': p.contacto or '',
                'telefono': p.telefono or '',
                'email': p.email or '',
                "calle_id": p.calle_id.id if p.calle_id else None,
                        "numero": p.numero or "",
                        "escalera": p.escalera or "",
                        "bloque": p.bloque or "",
                        "portal": p.portal or "",
                        "piso": p.piso or "",
                        "puerta": p.puerta or "",
                'observaciones': p.observaciones or '',
                'anunciante': p.anunciante or False,
                'grupo_id': p.grupo_id.id if p.grupo_id else None,
                'grupo_nombre': p.grupo_id.nombre if p.grupo_id else '',
            })
        return self._cors_response({'success': True, 'proveedores': data})

    @http.route('/api/proveedores/crear', auth='public', type='http', methods=['POST', 'OPTIONS'], csrf=False)
    def crear_proveedor(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._cors_response()

        try:
            # Al ser type='http', leemos el body manualmente
            body = json.loads(request.httprequest.data)
            params = body.get('params', body) # Soporta con o sin 'params'
            
            if not params.get('nombre') or not params.get('cod_proveedor'):
                return self._cors_response({'success': False, 'error': 'Código y Nombre obligatorios'})

            nuevo = request.env['morenitapp.proveedor'].sudo().create({
                'cod_proveedor': params.get('cod_proveedor'),
                'nombre': params.get('nombre'),
                'contacto': params.get('contacto'),
                'telefono': params.get('telefono'),
                'email': params.get('email'),
                'calle_id': params.get('calle_id'),
                'numero': params.get('numero'),
                'escalera': params.get('escalera'),
                'bloque': params.get('bloque'),
                'portal': params.get('portal'),
                'piso': params.get('piso'),
                'puerta': params.get('puerta'),
                'observaciones': params.get('observaciones'),
                'anunciante': params.get('anunciante', False),
                'grupo_id': params.get('grupo_id'),
            })
            return self._cors_response({'success': True, 'id': nuevo.id})
        except Exception as e:
            return self._cors_response({'success': False, 'error': str(e)})

    @http.route('/api/proveedores/update', auth='public', type='http', methods=['POST', 'OPTIONS'], csrf=False)
    def update_proveedor(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._cors_response()

        try:
            body = json.loads(request.httprequest.data)
            params = body.get('params', body)
            p_id = params.get('id')
            
            proveedor = request.env['morenitapp.proveedor'].sudo().browse(int(p_id))
            if proveedor.exists():
                proveedor.write({
                    'cod_proveedor': params.get('cod_proveedor'),
                    'nombre': params.get('nombre'),
                    'contacto': params.get('contacto'),
                    'telefono': params.get('telefono'),
                    'email': params.get('email'),
                    'calle_id': params.get('calle_id'),
                    'numero': params.get('numero'),
                    'escalera': params.get('escalera'),
                    'bloque': params.get('bloque'),
                    'portal': params.get('portal'),
                    'piso': params.get('piso'),
                    'puerta': params.get('puerta'),
                    'observaciones': params.get('observaciones'),
                    'anunciante': params.get('anunciante'),
                    'grupo_id': params.get('grupo_id'),
                })
                return self._cors_response({'success': True})
            return self._cors_response({'success': False, 'error': 'No encontrado'})
        except Exception as e:
            return self._cors_response({'success': False, 'error': str(e)})

    @http.route('/api/proveedores/delete', auth='public', type='http', methods=['POST', 'OPTIONS'], csrf=False)
    def eliminar_proveedor(self, **post):
        if request.httprequest.method == 'OPTIONS':
            return self._cors_response()

        try:
            body = json.loads(request.httprequest.data)
            params = body.get('params', body)
            p_id = params.get('id')
            
            proveedor = request.env['morenitapp.proveedor'].sudo().browse(int(p_id))
            if proveedor.exists():
                proveedor.unlink()
                return self._cors_response({'success': True})
            return self._cors_response({'success': False, 'error': 'No encontrado'})
        except Exception as e:
            return self._cors_response({'success': False, 'error': str(e)})