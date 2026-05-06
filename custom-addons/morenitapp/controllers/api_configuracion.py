import json
import logging
import traceback
from odoo import http
from odoo.http import request
_logger = logging.getLogger(__name__)
class ConfiguracionController(http.Controller):
    MODELS = {
        'tipoevento': 'morenitapp.tipoevento',
        'tipocargo': 'morenitapp.tipocargo',
        'tipoautoridad': 'morenitapp.tipoautoridad',
        'rol': 'morenitapp.rol',
        'grupoproveedor': 'morenitapp.grupoproveedor',
        'tiponotificacion': 'morenitapp.notificacion.tipo'
    }
    def _cors_headers(self):
        return [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
            ('Access-Control-Max-Age', '86400'),
        ]
    def _response_cors(self):
        return request.make_response('', headers=self._cors_headers())
    def _json_response(self, data, status=200):
        headers = [('Content-Type', 'application/json')] + self._cors_headers()
        return request.make_response(
            json.dumps(data, default=str),
            headers=headers,
            status=status
        )
    def _error_response(self, message, status=500):
        return self._json_response({'error': message, 'status': status}, status=status)
    @http.route([
        '/api/configuracion/<string:tipo>',
        '/api/configuracion/<string:tipo>/<int:id>'
    ], auth='public', type='http', csrf=False,
       methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
    def gestion_configuracion(self, tipo, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._response_cors()
        model_name = self.MODELS.get(tipo)
        if not model_name:
            return self._error_response("Recurso de configuración no encontrado", 404)
        obj = request.env[model_name].sudo()
        method = request.httprequest.method
        try:
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = obj.search(domain)
                res = []
                for r in records:
                    row = {'id': r.id}
                    if tipo == 'tipoevento':
                        row.update({
                            'codigo': getattr(r, 'cod_tipo_evento', ''),
                            'nombre': getattr(r, 'nombre_tipo_evento', ''),
                            'color': getattr(r, 'color', ''),
                        })
                    elif tipo == 'tipocargo':
                        row.update({
                            'codigo': getattr(r, 'codTipoCargo', ''),
                            'nombre': getattr(r, 'nombreTipoCargo', ''),
                            'observaciones': getattr(r, 'observaciones', '') or ''
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
                    elif tipo == 'tiponotificacion':
                        row.update({
                            'nombre': getattr(r, 'name', '')
                        })
                    res.append(row)
                return self._json_response(res)
            if method in ['POST', 'PUT']:
                try:
                    raw_data = request.httprequest.data.decode('utf-8') if request.httprequest.data else ''
                    params = json.loads(raw_data) if raw_data else dict(kw)
                except Exception:
                    params = dict(kw)
                target_id = id or params.pop('id', None)
                if method == 'PUT' or target_id:
                    rec = obj.browse(int(target_id))
                    if not rec.exists():
                        return self._error_response("Registro no encontrado", 404)
                    rec.write(params)
                    return self._json_response({"status": "updated", "id": rec.id})
                nuevo = obj.create(params)
                return self._json_response({"success": True, "id": nuevo.id}, status=201)
            if method == 'DELETE':
                if not id:
                    return self._error_response("ID requerido para eliminar", 400)
                registro = obj.browse(id)
                if not registro.exists():
                    return self._error_response("Registro no encontrado", 404)
                registro.unlink()
                return self._json_response({'status': 'deleted', 'id': id})
            return self._error_response("Método no permitido", 405)
        except Exception as e:
            _logger.error("Error en Configuración API: %s", traceback.format_exc())
            return self._error_response(str(e), 500)