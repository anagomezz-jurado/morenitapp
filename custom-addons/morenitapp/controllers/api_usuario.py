import json
import logging
from odoo import http
from odoo.http import request

_logger = logging.getLogger(__name__)

class UsuarioAPI(http.Controller):

    # --- LISTAR USUARIOS ---
    @http.route('/api/usuarios', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def listar_usuarios(self, **post):
        try:
            usuarios = request.env['morenitapp.usuario'].sudo().search([])
            lista = []
            for u in usuarios:
                lista.append({
                    'id': u.id,
                    'nombre': u.nombre,
                    'email': u.email,
                    'rol_id': u.rol_id.id if u.rol_id else 2,
                    'telefono': u.telefono or '',
                    'apellido1': u.apellido1 or '',
                    'apellido2': u.apellido2 or ''
                })
            return {"success": True, "usuarios": lista}
        except Exception as e:
            return {"success": False, "error": str(e)}

    # --- REGISTRAR / CREAR USUARIO ---
    @http.route('/api/registrar', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def crear_usuario(self, **post):
        data = request.params
        try:
            if not data.get('email') or not data.get('contrasena'):
                return {"success": False, "error": "Email y contraseña son obligatorios"}

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
            return {
                "success": True,
                "id": nuevo.id,
                "nombre": nuevo.nombre,
                "email": nuevo.email,
                "rol_id": nuevo.rol_id.id
            }
        except Exception as e:
            return {"success": False, "error": str(e)}

    # --- EDITAR USUARIO ---
    @http.route('/api/usuarios/update', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def editar_usuario(self, **post):
        data = request.params
        try:
            user_id = data.get('id')
            usuario = request.env['morenitapp.usuario'].sudo().browse(int(user_id))
            if not usuario.exists():
                return {"success": False, "error": "Usuario no encontrado"}

            # Mapeo de campos permitidos para actualizar
            vals = {}
            if 'nombre' in data: vals['nombre'] = data['nombre']
            if 'email' in data: vals['email'] = data['email']
            if 'rol_id' in data: vals['rol_id'] = data['rol_id']
            if 'contrasena' in data: vals['contrasena'] = data['contrasena']
            
            usuario.write(vals)
            return {"success": True}
        except Exception as e:
            return {"success": False, "error": str(e)}

    # --- ELIMINAR USUARIO ---
    @http.route('/api/usuarios/delete', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def eliminar_usuario(self, **post):
        data = request.params
        try:
            user_id = data.get('id')
            usuario = request.env['morenitapp.usuario'].sudo().browse(int(user_id))
            if usuario.exists():
                usuario.unlink()
                return {"success": True}
            return {"success": False, "error": "No existe el usuario"}
        except Exception as e:
            return {"success": False, "error": str(e)}

    # --- LOGIN ---
    @http.route('/api/login', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def api_login(self, **post):
        try:
            data = request.params 
            email = (data.get('email') or '').strip()
            contrasena = (data.get('contrasena') or '').strip()

            usuario = request.env['morenitapp.usuario'].sudo().search([
                ('email', '=ilike', email)
            ], limit=1)

            if usuario and usuario.contrasena and usuario.contrasena.strip() == contrasena:
                return {
                    "success": True,
                    "id": usuario.id,
                    "nombre": usuario.nombre,
                    "email": usuario.email,
                    "rol_id": usuario.rol_id.id,
                    "token": "dummy_token_123" # Odoo no usa JWT nativo, puedes mandar un string fijo o el ID
                }
            return {"success": False, "error": "Credenciales incorrectas"}
        except Exception as e:
            return {"success": False, "error": str(e)}