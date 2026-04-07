import json
import logging
import traceback
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class ConfiguracionController(http.Controller):

    # --- UTILIDADES DE RESPUESTA (Igual que Ubicaciones) ---
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

    # --- MAPEO DE MODELOS ---
    MODELS = {
        'tipoevento': 'morenitapp.tipoevento',
        'tipocargo': 'morenitapp.tipocargo',
        'tipoautoridad': 'morenitapp.tipoautoridad',
        'rol': 'morenitapp.rol',
        'grupoproveedor': 'morenitapp.grupoproveedor'
    }

    @http.route([
        '/api/configuracion/<string:tipo>', 
        '/api/configuracion/<string:tipo>/<int:id>'
    ], auth='public', type='http', csrf=False, methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    def gestion_configuracion(self, tipo, id=None, **kw):
        
        if request.httprequest.method == 'OPTIONS':
            return self._response_cors()

        model_name = self.MODELS.get(tipo)
        if not model_name:
            return self._error_response("Recurso de configuración no encontrado", 404)

        obj = request.env[model_name].sudo()
        method = request.httprequest.method

        try:
            # --- GET (LISTAR O VER UNO) ---
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = obj.search(domain)
                res = []
                for r in records:
                    row = {'id': r.id}
                    # Adaptación de campos según el tipo (Uso de getattr para seguridad)
                    if tipo == 'tipoevento':
                        row.update({
                            'codigo': getattr(r, 'cod_tipo_evento', ''),
                            'nombre': getattr(r, 'nombre_tipo_evento', '')
                        })
                    elif tipo == 'tipocargo':
                        row.update({
                            'codigo': getattr(r, 'codTipoCargo', ''),
                            'nombre': getattr(r, 'nombreTipoCargo', ''),
                            'observaciones': getattr(r, 'observaciones', '')
                        })
                    elif tipo == 'tipoautoridad':
                        row.update({
                            'codigo': getattr(r, 'codTipoAutoridad', ''),
                            'nombre': getattr(r, 'nombreTipoAutoridad', '')
                        })
                    elif tipo == 'rol':
                        row.update({
                            'codigo': getattr(r, 'codRol', ''),
                            'nombre': getattr(r, 'name', '')
                        })
                    elif tipo == 'grupoproveedor':
                        row.update({
                            'codigo': getattr(r, 'cod_grupo', ''),
                            'nombre': getattr(r, 'nombre', '')
                        })
                    res.append(row)
                return self._json_response(res)

            # --- POST (CREAR) ---
            if method == 'POST':
                body = request.httprequest.data.decode('utf-8')
                vals = json.loads(body) if body else {}
                
                # Manejo opcional de la estructura 'params' que a veces envía Flutter
                if 'params' in vals:
                    vals = vals['params']
                
                nuevo = obj.create(vals)
                
                # Devolvemos el objeto creado con su ID para que Flutter actualice el estado
                res_data = {'id': nuevo.id, 'status': 'created'}
                
                # Mapeo de respuesta post-creación
                if tipo == 'tipoevento':
                    res_data.update({'codigo': getattr(nuevo, 'cod_tipo_evento', ''), 'nombre': getattr(nuevo, 'nombre_tipo_evento', '')})
                elif tipo == 'tipocargo':
                    res_data.update({'codigo': getattr(nuevo, 'codTipoCargo', ''), 'nombre': getattr(nuevo, 'nombreTipoCargo', '')})
                elif tipo == 'rol':
                    res_data.update({'codigo': getattr(nuevo, 'codRol', ''), 'nombre': getattr(nuevo, 'name', '')})

                return self._json_response(res_data, status=201)

            # --- PUT (ACTUALIZAR) ---
            if method == 'PUT' and id:
                body = request.httprequest.data.decode('utf-8')
                vals = json.loads(body) if body else {}
                if 'params' in vals: vals = vals['params']
                
                registro = obj.browse(id)
                if registro.exists():
                    # Evitar que el ID vaya en los vals de escritura
                    if 'id' in vals: vals.pop('id')
                    registro.write(vals)
                    return self._json_response({'status': 'updated', 'id': id})
                return self._error_response("Registro no encontrado", 404)

            # --- DELETE (ELIMINAR) ---
            if method == 'DELETE' and id:
                registro = obj.browse(id)
                if registro.exists():
                    registro.unlink()
                    return self._json_response({'status': 'deleted', 'id': id})
                return self._error_response("Registro no encontrado", 404)

        except Exception as e:
            _logger.error("Error en Configuración API: %s", traceback.format_exc())
            return self._error_response(str(e))