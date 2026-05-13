from odoo import http
from odoo.http import request
import json
import logging
import traceback

_logger = logging.getLogger(__name__)


class ActivityLogsController(http.Controller):

    def _response_cors(self):
        response = request.make_response('')
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
        return response

    def _json_response(self, data, status=200):
        body = json.dumps(data)

        response = request.make_response(
            body,
            headers=[
                ('Content-Type', 'application/json'),
                ('Access-Control-Allow-Origin', '*')
            ]
        )

        response.status_code = status
        return response

    def _error_response(self, message, status=500):
        return self._json_response({
            'success': False,
            'error': message
        }, status)

    @http.route(
        ['/api/activity-logs', '/api/activity-logs/<int:log_id>'],
        auth='public',
        type='http',
        csrf=False,
        methods=['GET', 'POST', 'OPTIONS']
    )
    def activity_logs_handler(self, log_id=None, **kw):

        if request.httprequest.method == 'OPTIONS':
            return self._response_cors()

        try:
            method = request.httprequest.method
            sudo_env = request.env['morenitapp.activity.log'].sudo()

            # =========================
            # GET
            # =========================
            if method == 'GET':

                if log_id:
                    log = sudo_env.browse(log_id)

                    if not log.exists():
                        return self._error_response('Log no encontrado', 404)

                    data = {
                        'id': log.id,
                        'user_id': log.user_id,
                        'user_name': log.user_name,
                        'action': log.action,
                        'entity_name': log.entity_name,
                        'description': log.description or '',
                        'created_at': log.create_date.isoformat() if log.create_date else None,
                    }

                    return self._json_response(data)

                limit = int(kw.get('limit', 20))

                logs = sudo_env.search(
                    [],
                    limit=limit,
                    order='create_date desc'
                )

                data = [{
                    'id': log.id,
                    'user_id': log.user_id,
                    'user_name': log.user_name,
                    'action': log.action,
                    'entity_name': log.entity_name,
                    'description': log.description or '',
                    'created_at': log.create_date.isoformat() if log.create_date else None,
                } for log in logs]

                return self._json_response(data)

            # =========================
            # POST
            # =========================
            elif method == 'POST':

                body = request.httprequest.data
                payload = json.loads(body) if body else {}
                params = payload.get('params', payload)

                nuevo_log = sudo_env.create({
                    'user_id': params.get('user_id', ''),
                    'user_name': params.get('user_name', ''),
                    'action': params.get('action', 'update'),
                    'entity_name': params.get('entity_name', ''),
                    'description': params.get('description', ''),
                })

                return self._json_response({
                    'success': True,
                    'status': 'created',
                    'id': nuevo_log.id
                })

        except Exception as e:
            _logger.error(traceback.format_exc())
            return self._error_response(str(e))