from odoo import http, fields  # ← añadir fields aquí
from odoo.http import request
import json
import logging

_logger = logging.getLogger(__name__)

class EventoCultoController(http.Controller):

    def _json_response(self, data, status=200):
        return request.make_response(
            json.dumps(data), 
            headers=[
                ('Content-Type', 'application/json'),
                ('Access-Control-Allow-Origin', '*'),
                ('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'),
                ('Access-Control-Allow-Headers', 'Content-Type, Authorization'),
            ], 
            status=status
        )

    # --- ORGANIZADORES ---
    @http.route(['/api/organizadores', '/api/organizadores/<int:id>'], 
                type='http', auth='public', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_organizadores(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({})

        model = request.env['morenitapp.organizador'].sudo()
        
        try:
            if request.httprequest.method == 'GET':
                domain = [('id', '=', id)] if id else []
                records = model.search(domain)
                data = [{
                    "id": r.id,
                    "cif": r.cif or "",
                    "nombre": r.nombre or "",
                    "telefono": r.telefono or "",
                    "email": r.email or "",
                    "calle_id": r.calle_id.id if r.calle_id else None,
                    "calle_name": r.calle_id.nombreCalle if r.calle_id else "",
                    "numero": r.numero or "",
                    "escalera": r.escalera or "",
                    "bloque": r.bloque or "",
                    "portal": r.portal or "",
                    "piso": r.piso or "",
                    "puerta": r.puerta or "",
                    "logo": r.logo.decode('utf-8') if r.logo else None,
                    "firma_presidente": r.firma_presidente.decode('utf-8') if r.firma_presidente else None,
                    "firma_secretario": r.firma_secretario.decode('utf-8') if r.firma_secretario else None,
                    "firma_tesorero": r.firma_tesorero.decode('utf-8') if r.firma_tesorero else None,
                } for r in records]
                return self._json_response(data if not id else data[0])

            body = json.loads(request.httprequest.data) if request.httprequest.data else {}

            if request.httprequest.method == 'POST':
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if request.httprequest.method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            return self._json_response({"error": str(e)}, status=500)

    # --- EVENTOS ---
    @http.route(['/api/eventos', '/api/eventos/<int:id>'], 
            type='http', auth='public', 
            methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], csrf=False)
    def api_eventos(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS': 
            return self._json_response({})
            
        model = request.env['morenitapp.evento'].sudo()
        try:
            if request.httprequest.method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = [{
                    "id": r.id,
                    "cod_evento": r.cod_evento or "",
                    "nombre": r.nombre or "",
                    "descripcion": r.descripcion or "",
                    "fecha_inicio": r.fecha_inicio.strftime('%Y-%m-%d %H:%M:%S') if r.fecha_inicio else None,
                    "fecha_fin": r.fecha_fin.strftime('%Y-%m-%d %H:%M:%S') if r.fecha_fin else None,
                    "lugar": r.lugar or "",
                    "anio": r.anio or 0,
                    "organizador_id": [r.organizador_id.id, r.organizador_id.nombre] if r.organizador_id else None,
                    "tipoevento_id": [r.tipoevento_id.id, r.tipoevento_id.nombre_tipo_evento] if r.tipoevento_id else None,
                    "tipo_nombre": r.tipoevento_id.nombre_tipo_evento if r.tipoevento_id else "General",
                    "color": r.color or "#3498db",
                } for r in records]
                return self._json_response(data if not id else (data[0] if data else {}))

            body = {}
            if request.httprequest.data:
                body = json.loads(request.httprequest.data.decode('utf-8'))
            body = {k: v for k, v in body.items() if v is not None}

            if request.httprequest.method == 'POST':
                if not body.get('nombre'):
                    return self._json_response({"error": "Falta el nombre"}, status=400)
                nuevo = model.create(body)
                return self._json_response({"success": True, "id": nuevo.id})

            if request.httprequest.method == 'PUT' and id:
                record = model.browse(id)
                if record.exists():
                    record.write(body)
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"Error en Eventos: {str(e)}")
            return self._json_response({"error": str(e)}, status=500)

    # --- NOTIFICACIONES ---
    # --- NOTIFICACIONES ---
    @http.route(['/api/notificaciones', '/api/notificaciones/<int:id>'],
                type='http', auth='public',
                methods=['GET', 'POST', 'DELETE', 'OPTIONS'], csrf=False)
    def api_notificaciones(self, id=None, **kw):
        if request.httprequest.method == 'OPTIONS':
            return self._json_response({})

        model = request.env['morenitapp.notificacion'].sudo()

        try:
            if request.httprequest.method == 'GET':
                records = model.search([('id', '=', id)] if id else [])
                data = [{
                    "id": r.id,
                    "asunto": r.asunto or "",
                    "mensaje": r.mensaje or "",
                    "tipoid": r.tipo_id.id if r.tipo_id else None,
                    "tiponombre": r.tipo_id.name if r.tipo_id else "Sin tipo",
                    "fecharegistro": r.fecha_registro.strftime('%Y-%m-%d %H:%M:%S') if r.fecha_registro else None,
                    "usuarioids": r.usuario_ids.ids,
                    # Añadimos nombre y email de cada destinatario
                    "destinatarios": [{
                        "id": u.id,
                        "nombre": u.nombre or "",
                        "email": u.email or "",
                    } for u in r.usuario_ids],
                } for r in records]
                return self._json_response(data if not id else (data[0] if data else {}))

            body = {}
            if request.httprequest.data:
                body = json.loads(request.httprequest.data.decode('utf-8'))

            if request.httprequest.method == 'POST':
                vals = {
                    'asunto': body.get('asunto'),
                    'mensaje': body.get('mensaje'),
                    # fecha_registro se pone automáticamente por el default del modelo
                }
                if body.get('tipoid'):
                    vals['tipo_id'] = body.get('tipoid')

                nueva = model.create(vals)
                nueva._onchange_tipo_id()
                nueva.write({'usuario_ids': [(6, 0, nueva.usuario_ids.ids)]})

                if body.get('enviarahora'):
                    nueva.action_enviar_notificacion()

                return self._json_response({
                    "success": True,
                    "id": nueva.id,
                    "message": "Notificación enviada correctamente"
                })

            if request.httprequest.method == 'DELETE' and id:
                record = model.browse(id)
                if record.exists():
                    record.unlink()
                    return self._json_response({"success": True})
                return self._json_response({"error": "No encontrado"}, status=404)

        except Exception as e:
            _logger.error(f"Error en Notificaciones: {str(e)}")
            return self._json_response({"error": str(e)}, status=500)