from odoo import http
from odoo.http import request
import json

class MorenitAppAPI(http.Controller):

    # --- MÉTODO PARA LISTAR (GET) ---
    @http.route('/api/hermanos', auth='public', type='http', csrf=False, methods=['GET'])
    def get_hermanos(self, **kw):
        hermanos = request.env['morenitapp.hermano'].sudo().search([])
        data = []
        for h in hermanos:
            data.append({
                "id": h.id,
                "nombre": h.nombre,
                "apellido1": h.apellido1,
                "apellido2": h.apellido2,
                "nombre_completo": h.nombre_completo,
                "telefono": h.telefono or '',
                "dni": h.dni,
                "fecha_nacimiento": str(h.fecha_nacimiento) if h.fecha_nacimiento else '',
                "metodo_pago": h.metodo_pago,
            })
        return request.make_response(
            json.dumps(data),
            headers=[('Content-Type', 'application/json')]
        )

    @http.route('/api/hermanos', auth='public', type='json', csrf=False, methods=['POST'])
    def crear_hermano(self, **post):
        # En type='json', Odoo pone los datos directamente en 'post' 
        # o en 'request.jsonrequest'. Vamos a usar el que sea más seguro:
        datos = post or request.jsonrequest
        
        try:
            # Validamos que vengan datos
            if not datos:
                return {"status": "error", "message": "No se recibieron datos"}

            # Creamos el registro. 
            # sudo() es importante para evitar problemas de permisos desde la App
            nuevo = request.env['morenitapp.hermano'].sudo().create(datos)
            
            return {
                "status": "success",
                "id": nuevo.id,
                "nombre": nuevo.nombre_completo
            }
        except Exception as e:
            # Esto saldrá en tu terminal de Odoo para que veas el error real
            print("--- ERROR ODOO CREATE ---", str(e))
            return {
                "status": "error", 
                "message": str(e)
            }