import json
import logging
import base64
from odoo import http, fields
from odoo.http import request

_logger = logging.getLogger(__name__)

class LibroController(http.Controller):

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
        if request.httprequest.data:
            try:
                data = json.loads(request.httprequest.data.decode('utf-8'))
                return data.get('params', data)
            except Exception:
                return {}
        return request.params.copy()

    @http.route(['/api/libros', '/api/libros/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_libros(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({}, status=200)

        sudo_model = request.env['morenitapp.libro'].sudo()
        method = request.httprequest.method
        
        try:
            # --- GET: Obtener ---
            if method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = sudo_model.search(domain)
                data = []
                for r in records:
                    data.append({
                        "id": r.id,
                        "cod_libro": r.cod_libro or "",
                        "nombre": r.nombre or "",
                        "anio": r.anio or 0,
                        "descripcion": r.descripcion or "",
                        "importe": r.importe or 0.0,
                        "fecha_recibo": fields.Date.to_string(r.fecha_recibo) if r.fecha_recibo else None,
                        "texto_recibo_evento": r.texto_recibo_evento or "", 
                        "texto_anunciante": r.texto_anunciante or "",
                        "tipoevento_id": r.tipoevento_id.id if r.tipoevento_id else None,
                        "total_anunciantes": getattr(r, 'total_anunciantes', 0.0),
                        "anunciantes": [{
                            "id": a.id,
                            "proveedor_id": a.proveedor_id.id,
                            "proveedor_nombre": a.proveedor_id.nombre if a.proveedor_id else "Sin nombre",
                            "importe": a.importe,
                            "cobrado": a.cobrado,
                            "fecha_cobro": fields.Date.to_string(a.fecha_cobro) if a.fecha_cobro else None
                        } for a in r.anunciantes_ids],
                        "archivos": [{
                            "id": f.id,
                            "nombre": f.name,
                            "base64": f.datas.decode('utf-8') if f.datas else None,
                            "mimetype": f.mimetype
                        } for f in r.adjuntos_ids]
                    })
                return self._json_response(data if not id else (data[0] if data else {}))

            # --- POST / PUT: Crear o Editar ---
            if method in ['POST', 'PUT']:
                params = self._get_params()
                id_record = id or params.get('id')
                
                # Extraer datos complejos
                anunciantes_in = params.pop('anunciantes', None)
                archivos_nuevos = params.pop('subir_archivos', [])
                archivos_quedan_ids = params.pop('archivos_ids_quedan', None)

                # Filtrar solo campos que existen en Odoo
                final_vals = {k: v for k, v in params.items() if k in sudo_model._fields and k != 'id'}

                # 1. GESTIÓN DE ANUNCIANTES (Eliminar, Editar, Crear)
                if anunciantes_in is not None:
                    commands = []
                    if id_record:
                        # Detectar eliminados: comparamos IDs actuales vs IDs recibidos
                        record = sudo_model.browse(int(id_record))
                        ids_recibidos = [int(a['id']) for a in anunciantes_in if a.get('id')]
                        ids_actuales = record.anunciantes_ids.ids
                        for id_del in set(ids_actuales) - set(ids_recibidos):
                            commands.append((2, id_del, 0)) # 2 = Eliminar de DB

                    for anc in anunciantes_in:
                        a_vals = {
                            'importe': float(anc.get('importe', 0.0)),
                            'cobrado': anc.get('cobrado', False),
                            'fecha_cobro': anc.get('fecha_cobro') or False,
                            'proveedor_id': anc.get('proveedor_id'),
                        }
                        if anc.get('id'):
                            commands.append((1, int(anc['id']), a_vals)) # 1 = Update
                        else:
                            commands.append((0, 0, a_vals)) # 0 = Create
                    final_vals['anunciantes_ids'] = commands

                # 2. GESTIÓN DE ARCHIVOS (Sincronizar y Subir)
                attachment_commands = []
                if id_record and archivos_quedan_ids is not None:
                    # Comando 6 reemplaza la lista por los IDs que el usuario NO borró
                    attachment_commands.append((6, 0, [int(x) for x in archivos_quedan_ids]))

                for file in archivos_nuevos:
                    if file.get('base64'):
                        new_attach = request.env['ir.attachment'].sudo().create({
                            'name': file.get('nombre', 'adjunto'),
                            'datas': file.get('base64'), 
                            'res_model': 'morenitapp.libro',
                        })
                        attachment_commands.append((4, new_attach.id)) # 4 = Vincular
                
                if attachment_commands:
                    final_vals['adjuntos_ids'] = attachment_commands

                # PERSISTENCIA
                if id_record:
                    record = sudo_model.browse(int(id_record))
                    if not record.exists():
                        return self._json_response({"success": False, "error": "No existe"}, 404)
                    record.write(final_vals)
                    return self._json_response({"success": True, "id": record.id})
                else:
                    nuevo = sudo_model.create(final_vals)
                    return self._json_response({"success": True, "id": nuevo.id}, 201)

            # --- DELETE ---
            if method == 'DELETE':
                target_id = id or self._get_params().get('id')
                record = sudo_model.browse(int(target_id))
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"success": False}, 404)

        except Exception as e:
            _logger.error(f"API Error: {str(e)}")
            return self._json_response({"success": False, "error": str(e)}, 500)