import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class UsuarioAPI(http.Controller):

    def _get_user_dict(self, u):
    # Extraer rol_id como entero puro
        try:
            rol_id = int(u.rol_id.id) if u.rol_id else 2
        except Exception:
            rol_id = 2

        return {
            'id': u.id,
            'nombre': u.nombre or '',
            'apellido1': u.apellido1 or '',
            'apellido2': u.apellido2 or '',
            'email': u.email or '',
            'telefono': u.telefono or '',
            'rol_id': rol_id,
            'rol_name': u.rol_id.name if u.rol_id else 'Usuario',
            'recibirNotiEmail': u.recibirNotiEmail,
            'token': str(u.id),
            'hermano_id': u.hermano_id.id if u.hermano_id else None,
            'numero_hermano': u.hermano_id.codigo_hermano if u.hermano_id else None,
        }

    @http.route('/api/usuarios', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def listar_usuarios(self, **kwargs):
        try:
            domain = kwargs.get('domain', [])
            usuarios = request.env['morenitapp.usuario'].sudo().search(domain)
            return {
                "success": True,
                "usuarios": [self._get_user_dict(u) for u in usuarios]
            }
        except Exception as e:
            return {"success": False, "error": str(e)}

    @http.route('/api/usuarios/create', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def crear_usuario_admin(self, **kwargs):
        try:
            email = (kwargs.get('email') or '').strip()
            if request.env['morenitapp.usuario'].sudo().search([('email', '=ilike', email)], limit=1):
                return {"success": False, "error": "El correo ya está registrado"}

            vals = {
                'nombre': kwargs.get('nombre'),
                'apellido1': kwargs.get('apellido1', ''),
                'apellido2': kwargs.get('apellido2', ''),
                'email': email,
                'contrasena': kwargs.get('password'),
                'rol_id': int(kwargs.get('rol_id', 2)), 
                'telefono': kwargs.get('telefono', ''),
                'recibirNotiEmail': kwargs.get('recibirNotiEmail', True),
            }
            nuevo = request.env['morenitapp.usuario'].sudo().create(vals)
            return {"success": True, "user": self._get_user_dict(nuevo)}
        except Exception as e:
            _logger.error(f"Error creando usuario: {str(e)}")
            return {"success": False, "error": f"Error: {str(e)}"}

    @http.route('/api/usuarios/update', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def actualizar_usuario(self, **kwargs):
        try:
            usuario = request.env['morenitapp.usuario'].sudo().browse(int(kwargs.get('id')))
            if not usuario.exists():
                return {"success": False, "error": "Usuario no encontrado"}

            vals = {}
            campos_texto = ['nombre', 'email', 'telefono', 'recibirNotiEmail', 'apellido1', 'apellido2']
            for campo in campos_texto:
                if campo in kwargs:
                    vals[campo] = kwargs[campo]

            # rol_id siempre como entero
            if 'rol_id' in kwargs:
                vals['rol_id'] = int(kwargs['rol_id'])

            # hermano_id como entero
            if 'hermano_id' in kwargs and kwargs['hermano_id'] is not None:
                vals['hermano_id'] = int(kwargs['hermano_id'])

            password = kwargs.get('password') or kwargs.get('contrasena')
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
            })
            return {"success": True, "user": self._get_user_dict(nuevo)}
        except Exception as e:
            return {"success": False, "error": "Error interno al registrar"}