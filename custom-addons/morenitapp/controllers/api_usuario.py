import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class UsuarioAPI(http.Controller):

    def _get_user_dict(self, u):
        return {
            'id': u.id,
            'nombre': u.nombre or '',
            'apellido1': u.apellido1 or '',
            'apellido2': u.apellido2 or '',
            'email': u.email or '',
            'telefono': u.telefono or '',
            'rol_id': u.rol_id.id if u.rol_id else 2,
            'rol_name': u.rol_id.name if u.rol_id else 'Usuario',
            'recibirNotiEmail': u.recibirNotiEmail,
            'recibirNotiTelefono': u.recibirNotiTelefono,
            'token': str(u.id),
            'hermano_id': u.hermano_id.id if u.hermano_id else None,
            # ↓ CORRECCIÓN: 'numero_hermano' (snake_case) para que coincida con el mapper Flutter
            'numero_hermano': u.hermano_id.codigo_hermano if u.hermano_id else None,
        }

    @http.route('/api/usuarios', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def listar_usuarios(self, **kwargs):
        try:
            usuarios = request.env['morenitapp.usuario'].sudo().search([])
            return {
                "success": True, 
                "usuarios": [self._get_user_dict(u) for u in usuarios]
            }
        except Exception as e:
            return {"success": False, "error": str(e)}

    @http.route('/api/usuarios/create', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def crear_usuario_admin(self, **kwargs):
        """Creación desde el panel de gestión (usa 'password' de Flutter)"""
        data = request.params
        try:
            email = (data.get('email') or '').strip()
            if request.env['morenitapp.usuario'].sudo().search([('email', '=ilike', email)], limit=1):
                return {"success": False, "error": "El correo ya está registrado"}

            vals = {
                'nombre': data.get('nombre'),
                'apellido1': data.get('apellido1', ''),
                'apellido2': data.get('apellido2', ''),
                'email': email,
                'contrasena': data.get('password'), 
                'rol_id': data.get('rol_id', 2),
                'telefono': data.get('telefono', ''),
                'recibirNotiEmail': data.get('recibirNotiEmail', True),
                'recibirNotiTelefono': data.get('recibirNotiTelefono', False),
            }
            nuevo = request.env['morenitapp.usuario'].sudo().create(vals)
            return {"success": True, "user": self._get_user_dict(nuevo)}
        except Exception as e:
            _logger.error(f"Error creando usuario: {str(e)}")
            return {"success": False, "error": f"Error: {str(e)}"}

    @http.route('/api/usuarios/update', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def actualizar_usuario(self, **kwargs):
        data = request.params
        try:
            usuario = request.env['morenitapp.usuario'].sudo().browse(int(data.get('id')))
            if not usuario.exists():
                return {"success": False, "error": "Usuario no encontrado"}

            # Mapeamos dinámicamente lo que venga de Flutter
            vals = {}
            campos_permitidos = [
                'nombre', 'email', 'rol_id', 'telefono', 
                'recibirNotiEmail', 'recibirNotiTelefono', 'apellido1', 'apellido2','hermano_id'
            ]

            for campo in campos_permitidos:
                if campo in data:
                    vals[campo] = data[campo]

            # Manejo de contraseña (si viene)
            password = data.get('password') or data.get('contrasena')
            if password:
                vals['contrasena'] = password

            usuario.write(vals)
            return {"success": True, "user": self._get_user_dict(usuario)}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @http.route('/api/usuarios/delete', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def eliminar_usuario(self, **kwargs):
        data = request.params
        try:
            usuario = request.env['morenitapp.usuario'].sudo().browse(int(data.get('id')))
            if usuario.exists():
                usuario.unlink()
                return {"success": True}
            return {"success": False, "error": "No existe"}
        except Exception as e:
            return {"success": False, "error": str(e)}

    @http.route('/api/login', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def api_login(self, **kwargs):
        data = request.params
        email = (data.get('email') or '').strip()
        # Nota: Flutter puede enviar 'contrasena' o 'password' dependiendo del provider
        pwd = data.get('contrasena') or data.get('password') or ''

        usuario = request.env['morenitapp.usuario'].sudo().search([
            ('email', '=ilike', email),
            ('contrasena', '=', pwd.strip())
        ], limit=1)

        if usuario:
            return {"success": True, "user": self._get_user_dict(usuario)}
        return {"success": False, "error": "Credenciales inválidas"}

    @http.route('/api/registrar', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def registrar_usuario_publico(self, **kwargs):
        """Registro público (desde el Login)"""
        data = request.params
        try:
            email = (data.get('email') or '').strip()
            if request.env['morenitapp.usuario'].sudo().search([('email', '=ilike', email)]):
                return {"success": False, "error": "El correo ya está en uso"}

            nuevo = request.env['morenitapp.usuario'].sudo().create({
                'nombre': data.get('nombre'),
                'apellido1': data.get('apellido1', ''),
                'apellido2': data.get('apellido2', ''),
                'email': email,
                'contrasena': data.get('contrasena') or data.get('password'),
                'telefono': data.get('telefono', ''),
                'rol_id': 2, # Siempre estándar al registrarse
                'recibirNotiEmail': data.get('recibirNotiEmail', True),
                'recibirNotiTelefono': data.get('recibirNotiTelefono', False),
            })
            return {"success": True, "user": self._get_user_dict(nuevo)}
        except Exception as e:
            return {"success": False, "error": "Error interno al registrar"}