import json
import logging
import traceback
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class UbicacionesAPI(http.Controller):

    def _response_cors(self):
        headers = [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
            ('Access-Control-Max-Age', '86400'),
        ]
        return request.make_response('', headers=headers)

    def _json_response(self, data, status=200):
        headers = [
            ('Content-Type', 'application/json'),
            ('Access-Control-Allow-Origin', '*'),
        ]
        return request.make_response(json.dumps(data), headers=headers, status=status)

    def _error_response(self, message, status=500):
        return self._json_response({'error': message, 'status': status}, status=status)

    @http.route([
        '/api/ubicacion/<string:tipo>', 
        '/api/ubicacion/<string:tipo>/<int:id>'
    ], auth='public', type='http', csrf=False, methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    def api_ubicaciones(self, tipo, id=None, **kw):
        
        if request.httprequest.method == 'OPTIONS':
            return self._response_cors()

        map_model = {
            'provincias': 'morenitapp.provincia',
            'localidades': 'morenitapp.localidad',
            'cp': 'morenitapp.codigopostal',
            'calles': 'morenitapp.calle'
        }
        
        model_name = map_model.get(tipo)
        if not model_name:
            return self._error_response("Recurso no encontrado", 404)
        
        obj = request.env[model_name].sudo()
        method = request.httprequest.method

        try:
            # --- GET ---
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = obj.search(domain)
                res = []
                # --- DENTRO DE method == 'GET' ---
                for r in records:
                    row = {'id': r.id, 'display_name': r.display_name}
                    
                    if tipo == 'provincias':
                        row.update({
                            'codProvincia': getattr(r, 'codProvincia', ''),
                            'nombreProvincia': getattr(r, 'nombreProvincia', '')
                        })
                    elif tipo == 'localidades':
                        row.update({
                            'nombreLocalidad': getattr(r, 'nombreLocalidad', ''),
                            'codProvincia_id': r.codProvincia_id.id if r.codProvincia_id else 0,
                        })
                    elif tipo == 'cp':
                        row.update({
                            'name': getattr(r, 'name', ''),
                            'localidad_id': r.localidad_id.id if r.localidad_id else 0,
                        })
                    # --- AÑADE ESTA SECCIÓN ---
                    elif tipo == 'calles':
                        row.update({
                            'nombreCalle': getattr(r, 'nombreCalle', r.display_name),
                            'localidadId': r.localidad_id.id if r.localidad_id else 0,
                            'codPostalId': r.codPostal_id.id if r.codPostal_id else 0,
                        })
                    # --------------------------
                    res.append(row)
                return self._json_response(res)
            # --- POST (CREAR) ---
            if method == 'POST':
                body = request.httprequest.data.decode('utf-8')
                vals = json.loads(body) if body else {}
                nuevo = obj.create(vals)
                
                res_data = {
                    'id': nuevo.id,
                    'display_name': nuevo.display_name,
                    'status': 'created'
                }
                
                if tipo == 'provincias':
                    res_data.update({
                        'codProvincia': getattr(nuevo, 'codProvincia', ''),
                        'nombreProvincia': getattr(nuevo, 'nombreProvincia', '')
                    })
                elif tipo == 'localidades':
                    res_data.update({
                        'nombreLocalidad': getattr(nuevo, 'nombreLocalidad', ''),
                        'codProvincia_id': nuevo.codProvincia_id.id if nuevo.codProvincia_id else 0
                    })
                elif tipo == 'cp':
                    res_data.update({
                        'name': getattr(nuevo, 'name', ''),
                        'localidad_id': nuevo.localidad_id.id if nuevo.localidad_id else 0
                    })
                elif tipo == 'calles':
                    res_data.update({
                        'nombreCalle': getattr(nuevo, 'nombreCalle', nuevo.display_name),
                        'localidad_id': nuevo.localidad_id.id if nuevo.localidad_id else 0,
                        # Asegúrate que aquí coincida con lo que pusiste en el cleanId de Flutter
                        'codPostal_id': nuevo.codPostal_id.id if nuevo.codPostal_id else 0,
                    })

                return self._json_response(res_data, status=201)
                
                

                return self._json_response(res_data, status=201)

            # --- PUT ---
            if method == 'PUT' and id:
                body = request.httprequest.data.decode('utf-8')
                vals = json.loads(body) if body else {}
                registro = obj.browse(id)
                if registro.exists():
                    registro.write(vals)
                    return self._json_response({'status': 'updated', 'id': id})
                return self._error_response("No encontrado", 404)

            # --- DELETE ---
            if method == 'DELETE' and id:
                registro = obj.browse(id)
                if registro.exists():
                    registro.unlink()
                    return self._json_response({'status': 'deleted', 'id': id})
                return self._error_response("No encontrado", 404)

        except Exception as e:
            _logger.error("Error API: %s", traceback.format_exc())
            return self._error_response(str(e))