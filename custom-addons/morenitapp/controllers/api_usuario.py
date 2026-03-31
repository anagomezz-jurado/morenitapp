from odoo import http
from odoo.http import request

class UsuarioAPI(http.Controller):

    @http.route('/api/usuarios', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def listar_usuarios(self, **post):
        try:
            # Buscamos todos los usuarios de tu modelo personalizado
            usuarios = request.env['morenitapp.usuario'].sudo().search([])
            lista = []
            for u in usuarios:
                lista.append({
                    'id': u.id,
                    'nombre': u.nombre,
                    'email': u.email,
                    'contrasena':u.contrasena,
                    'rol_id': u.rol_id.id
                })
            return {"success": True, "usuarios": lista}
        except Exception as e:
            return {"success": False, "error": str(e)}
        
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

            # En tu archivo Python de Odoo:
            nuevo = request.env['morenitapp.usuario'].sudo().create(vals)
            return {
                "success": True,
                "id": nuevo.id,
                "nombre": nuevo.nombre,
                "email": nuevo.email,
                "rol_id": nuevo.rol_id.id,
                "token": "generar_aqui_un_token_si_lo_usas" # Si no usas token, el mapper debe manejarlo
            }

        except Exception as e:
            return {"success": False, "error": str(e)}
        
        
    @http.route('/api/login', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def api_login(self, **post):
        try:
            # Usar request.params es lo más seguro para type='json'
            data = request.params 
            email = (data.get('email') or '').strip()
            contrasena = (data.get('contrasena') or '').strip()

            usuario = request.env['morenitapp.usuario'].sudo().search([
                ('email', '=ilike', email)
            ], limit=1)

            # Verificamos que 'usuario' exista antes de acceder a .contrasena
            if usuario and usuario.contrasena and usuario.contrasena.strip() == contrasena:
                return {
                    "success": True,
                    "id": usuario.id,
                    "nombre": usuario.nombre,
                    "rol_id": usuario.rol_id.id
                }

            return {"success": False, "error": "Email o contraseña incorrectos"}

        except Exception as e:
            return {"success": False, "error": str(e)}