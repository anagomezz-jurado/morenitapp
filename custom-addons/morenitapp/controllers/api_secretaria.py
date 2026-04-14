import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class SecretariaController(http.Controller):

    def _get_cors_headers(self):
        return [
            ('Access-Control-Allow-Origin', '*'),
            ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
            ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
        ]

    def _json_response(self, data, status=200):
        headers = [('Content-Type', 'application/json')] + self._get_cors_headers()
        return request.make_response(json.dumps(data), headers=headers, status=status)

    def _get_params(self):
        data = {}
        if request.httprequest.data:
            try:
                data = json.loads(request.httprequest.data.decode('utf-8'))
                _logger.info(f"DATOS RECIBIDOS: {data}") # LOG PARA DEPURAR
                return data.get('params', data)
            except Exception as e:
                _logger.error(f"Error decodificando JSON: {e}")
        return request.params.copy()

    def _handle_request(self, model_name, record_id, fields_map):
        method = request.httprequest.method
        if method == 'OPTIONS': 
            return self._json_response({}, status=200)
        
        sudo_env = request.env[model_name].sudo()

        try:
            if method == 'GET':
                domain = [('id', '=', record_id)] if record_id else []
                records = sudo_env.search(domain)
                return self._json_response([fields_map(r) for r in records])

            if method == 'DELETE':
                rec = sudo_env.browse(record_id)
                if rec.exists():
                    rec.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"success": False, "error": "No encontrado"}, status=404)

            # --- CORRECCIÓN AQUÍ: POST / PUT ---
            if method in ['POST', 'PUT']:
                params = self._get_params()
                
                # 1. Limpieza de datos técnicos
                params.pop('id', None)
                params = {k: v for k, v in params.items() if not k.endswith('_name')}

                # 2. Mapeo de campos relacionales (Many2one)
                # Odoo necesita el ID entero o False si es nulo
                relational_fields = [
                    'tipoautoridad_id', 'tipocargo_id', 'localidad_id', 
                    'direccion_id', 'direccion', 'direccionCofradia'
                ]
                
                for field in relational_fields:
                    if field in params:
                        try:
                            val = params[field]
                            params[field] = int(val) if val else False
                        except:
                            params[field] = False

                # 3. Mapeos específicos de nombres de campos Flutter -> Odoo
                if model_name == 'morenitapp.cofradia':
                    # Flutter envía 'direccion_id', Odoo tiene 'direccionCofradia'
                    if 'direccion_id' in params:
                        params['direccionCofradia'] = params.pop('direccion_id')
                
                if model_name == 'morenitapp.cargo':
                    # Flutter envía 'direccion', Odoo tiene 'direccion' (pero asegurar int)
                    pass

                # 4. Operación en Base de Datos
                if method == 'PUT' or record_id:
                    target_id = record_id or params.get('id')
                    rec = sudo_env.browse(int(target_id))
                    if not rec.exists():
                        return self._json_response({"success": False, "error": "No encontrado"}, status=404)
                    rec.write(params)
                    return self._json_response({"success": True, "id": rec.id})
                else:
                    nuevo = sudo_env.create(params)
                    return self._json_response({"success": True, "id": nuevo.id}, status=201)

        except Exception as e:
            _logger.error(f"Error API Secretaria ({model_name}): {str(e)}")
            return self._json_response({"success": False, "error": str(e)}, status=500)
    # --- RUTAS ---

    @http.route(['/api/autoridades', '/api/autoridades/<int:record_id>'], type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_autoridades(self, record_id=None, **kw):
        def mapper(r): return {
            "id": str(r.id),
            "codAutoridad": r.codAutoridad or "",
            "nombreAutoridad": r.nombreAutoridad or "",
            "nombreSaluda": r.nombreSaluda or "",
            "cargo": r.cargo or "",
            "direccion": r.direccion or "",
            "telefono": r.telefono or "",
            "correoElectronico": r.correoElectronico or "",
            "observaciones": r.observaciones or "",
            "tipoautoridad_id": r.tipoautoridad_id.id if r.tipoautoridad_id else None,
            "tipoautoridad_name": r.tipoautoridad_id.display_name if r.tipoautoridad_id else "",
            "localidad_id": r.localidad_id.id if r.localidad_id else None,
            "localidad_name": r.localidad_id.display_name if r.localidad_id else "",
        }
        return self._handle_request('morenitapp.autoridad', record_id, mapper)

    @http.route(['/api/cargos', '/api/cargos/<int:record_id>'], type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_cargos(self, record_id=None, **kw):
        def mapper(r): return {
            "id": str(r.id),
            "codCargo": r.codCargo or "",
            "nombreCargo": r.nombreCargo or "",
            "tipocargo_id": r.tipocargo_id.id if r.tipocargo_id else None,
            "tipocargo_name": r.tipocargo_id.display_name if r.tipocargo_id else "",
            "fechaInicioCargo": str(r.fechaInicioCargo) if r.fechaInicioCargo else "",
            "fechaFinCargo": str(r.fechaFinCargo) if r.fechaFinCargo else None,
            # Localización
            "direccion": r.direccion.id if r.direccion else None,
            "direccion_name": r.direccion.display_name if r.direccion else "",
            "puerta": r.puerta or "",
            "piso": r.piso or "",
            "localidad_id": r.localidad_id.id if r.localidad_id else None,
            "codPostal_id": r.codPostal_id.id if r.codPostal_id else None,
            # Contacto e Info Adicional
            "telefono": r.telefono or "",
            "observaciones": r.observaciones or "",
            "motivo": r.motivo or "",
            "textoSaludo": r.textoSaludo or "",
        }
        
        return self._handle_request('morenitapp.cargo', record_id, mapper)

    @http.route(['/api/cofradias', '/api/cofradias/<int:record_id>'], type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_cofradias(self, record_id=None, **kw):
        def mapper(r): return {
            "id": str(r.id),
            "cifCofradia": r.cifCofradia or "",
            "nombreCofradia": r.nombreCofradia or "",
            "antiguedadCofradia": r.antiguedadCofradia or 0,
            "emailCofradia": r.emailCofradia or "",
            "telefonoCofradia": r.telefonoCofradia or "",
            "paginaWeb": r.paginaWeb or "",
            "observaciones": r.observaciones or "",
            # Campos Many2one
            "direccion_id": r.direccionCofradia.id if r.direccionCofradia else None,
            "direccion_name": r.direccionCofradia.display_name if r.direccionCofradia else "",
            "puerta": r.puerta or "",
            "piso": r.piso or "",
            "localidad_id": r.localidad_id.id if r.localidad_id else None,
        }
        
        # Asegúrate de que en _handle_request los campos terminados en _id se conviertan a int
        return self._handle_request('morenitapp.cofradia', record_id, mapper)