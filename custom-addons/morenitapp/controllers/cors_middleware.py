from odoo.service.wsgi_server import application as odoo_app
from odoo.http import request
import logging

_logger = logging.getLogger(__name__)

CORS_HEADERS = [
    ('Access-Control-Allow-Origin', '*'),
    ('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE'),
    ('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With'),
    ('Access-Control-Max-Age', '86400'),
]

class CORSMiddleware:
    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        method = environ.get('REQUEST_METHOD', '')

        if method == 'OPTIONS':
            def cors_start_response(status, headers, exc_info=None):
                headers += CORS_HEADERS
                return start_response('200 OK', headers, exc_info)
            return self.app(environ, cors_start_response)

        def cors_start_response(status, headers, exc_info=None):
            headers += CORS_HEADERS
            return start_response(status, headers, exc_info)

        return self.app(environ, cors_start_response)