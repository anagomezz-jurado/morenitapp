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
        # En type='json', request.params ya trae el contenido de 'params' de la petición
        data = request.params
        try:
            email = (data.get('email') or '').strip()
            telefono = (data.get('telefono') or '').strip()
            contrasena = data.get('contrasena')

            if not email or not contrasena:
                return {"success": False, "error": "Email y contraseña son obligatorios"}

            # --- VALIDACIÓN MANUAL DE DUPLICADOS ---
            # Verificamos si el email ya existe
            user_exist = request.env['morenitapp.usuario'].sudo().search([('email', '=ilike', email)], limit=1)
            if user_exist:
                return {"success": False, "error": "El correo electrónico ya está en uso"}

            # Verificamos si el teléfono ya existe (solo si se envió teléfono)
            if telefono:
                tel_exist = request.env['morenitapp.usuario'].sudo().search([('telefono', '=', telefono)], limit=1)
                if tel_exist:
                    return {"success": False, "error": "El número de teléfono ya está registrado"}

            vals = {
                'nombre': data.get('nombre'),
                'apellido1': data.get('apellido1'),
                'apellido2': data.get('apellido2'),
                'email': email,
                'contrasena': contrasena,
                'telefono': telefono,
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
                "rol_id": nuevo.rol_id.id if nuevo.rol_id else 2,
                "telefono": nuevo.telefono
            }
        except Exception as e:
            _logger.error("Error en registro: %s", str(e))
            return {"success": False, "error": "Error interno del servidor"}

    # --- EDITAR USUARIO ---
    @http.route('/api/usuarios/update', auth='public', type='json', methods=['POST'], csrf=False, cors='*')
    def editar_usuario(self, **post):
        data = request.params
        try:
            user_id = data.get('id')
            if not user_id:
                return {"success": False, "error": "ID de usuario requerido"}

            usuario = request.env['morenitapp.usuario'].sudo().browse(int(user_id))
            if not usuario.exists():
                return {"success": False, "error": "Usuario no encontrado"}

            vals = {}
            if 'nombre' in data: vals['nombre'] = data['nombre']
            if 'email' in data: 
                # Validar que el nuevo email no lo tenga otro
                new_email = data['email'].strip()
                dup = request.env['morenitapp.usuario'].sudo().search([('email', '=ilike', new_email), ('id', '!=', usuario.id)])
                if dup: return {"success": False, "error": "El nuevo correo ya está en uso"}
                vals['email'] = new_email
            
            if 'telefono' in data:
                new_tel = data['telefono'].strip()
                dup_tel = request.env['morenitapp.usuario'].sudo().search([('telefono', '=', new_tel), ('id', '!=', usuario.id)])
                if dup_tel: return {"success": False, "error": "El nuevo teléfono ya está en uso"}
                vals['telefono'] = new_tel

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
            if not user_id: return {"success": False, "error": "ID requerido"}
            
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

            if not email or not contrasena:
                return {"success": False, "error": "Faltan credenciales"}

            usuario = request.env['morenitapp.usuario'].sudo().search([
                ('email', '=ilike', email)
            ], limit=1)

            # Comprobación de contraseña (asumiendo que guardas texto plano por ahora)
            if usuario and usuario.contrasena and usuario.contrasena.strip() == contrasena:
                return {
                    "success": True,
                    "id": usuario.id,
                    "nombre": usuario.nombre,
                    "email": usuario.email,
                    "rol_id": usuario.rol_id.id if usuario.rol_id else 2,
                    "telefono": usuario.telefono or '',
                    "token": str(usuario.id) # Usamos el ID como token básico para tu lógica de Flutter
                }
            return {"success": False, "error": "Credenciales incorrectas"}
        except Exception as e:
            return {"success": False, "error": "Error en el servidor"}