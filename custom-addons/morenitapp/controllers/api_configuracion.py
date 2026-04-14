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
            # --- CREAR O EDITAR (POST/PUT) ---
            if method in ['POST', 'PUT']:
                params = self._get_params()
                
                # 1. Extraer ID y limpiar campos técnicos de Odoo que no deben escribirse
                record_id = record_id or params.pop('id', None)
                
                # 2. Filtrar campos: Odoo fallará si envías campos que no existen o son de solo lectura
                # Eliminamos los que terminan en _name o _display que usamos para la UI en Flutter
                params = {k: v for k, v in params.items() if not k.endswith('_name') and not k.endswith('_display')}

                # 3. Conversión explícita de campos Many2one (deben ser IDs enteros)
                # Añadimos 'direccion' que es como lo llama tu modelo según el mapper
                relational_fields = ['tipocargo_id', 'tipoautoridad_id', 'localidad_id', 'direccion', 'codPostal_id']
                for field in relational_fields:
                    if field in params:
                        try:
                            params[field] = int(params[field]) if params[field] else False
                        except:
                            params[field] = False

                if method == 'PUT' or record_id:
                    rec = sudo_env.browse(int(record_id))
                    if not rec.exists():
                        return self._error_response("Registro no encontrado", 404)
                    rec.write(params)
                    return self._json_response({"success": True, "id": rec.id})
                else:
                    # POST: Crear
                    nuevo = sudo_env.create(params)
                    return self._json_response({"success": True, "id": nuevo.id}, status=201)

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