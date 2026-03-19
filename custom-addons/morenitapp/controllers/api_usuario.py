from odoo import http
from odoo.http import request

class UsuarioAPI(http.Controller):

    @http.route('/api/registrar', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def crear_usuario(self, **post):
        # En Odoo, si type='json', los datos vienen en request.params
        data = request.params
        
        try:
            # Validamos que lleguen los datos básicos
            if not data.get('email') or not data.get('contrasena'):
                return {"success": False, "error": "Faltan datos obligatorios (email/contrasena)"}

            vals = {
                'nombre': data.get('nombre'),
                'apellido1': data.get('apellido1'),
                'apellido2': data.get('apellido2'),
                'email': data.get('email'),
                'contrasena': data.get('contrasena'),
                'telefono': data.get('telefono'),
                'rol_id': data.get('rol_id', 2),
                'recibirNotiEmail': data.get('recibirNotiEmail', True),
                'recibirNotiTelefono': data.get('recibirNotiTelefono', False),
            }

            nuevo = request.env['morenitapp.usuario'].sudo().create(vals)
            return {"success": True, "id": nuevo.id}

        except Exception as e:
            return {"success": False, "error": str(e)}

    @http.route('/api/login', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def api_login(self, **post):
        data = request.params
        usuario = request.env['morenitapp.usuario'].sudo().search([
            ('email', '=', data.get('email')),
            ('contrasena', '=', data.get('password')) # 'password' es lo que envías desde el login de Flutter
        ], limit=1)

        if usuario:
            return {"id": usuario.id, "nombre": usuario.nombre, "rol_id": usuario.rol_id.id}
        return None