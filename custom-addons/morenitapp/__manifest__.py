{
    'name': "MorenitApp",
    'summary': "Gestión completa de la Hermandad",
    'description': "Módulo para gestionar hermanos, eventos, libros, autoridades, usuarios y proveedores",
    'author': "Ana Gómez",
    'category': 'Tools',
    'version': '1.0',
    'depends': ['base'],
    'data': [
        # 1. Primero la seguridad (Primero Grupos, luego Reglas de Acceso)
        'security/ir.model.access.csv',
        'security/groups.xml',
        
        # 2. Vistas maestras
        'views/provincia_views.xml',
        'views/localidad_views.xml',
        'views/codigopostal_views.xml',
        'views/calle_views.xml',
        
        # 3. Vistas de gestión
        'views/hermanos_views.xml',
        'views/banco_views.xml',
        'views/libro_views.xml',
        'views/proveedores_views.xml',
        'views/autoridades_views.xml',
        'views/cargos_views.xml',
        'views/cofradias_views.xml',
        'views/organizadores_views.xml',
        'views/rol_views.xml',
        'views/tipos_views.xml',
        'views/usuario_view.xml',
        'views/grupos_usuarios.xml',
        
        # 4. Acciones y Menús (Siempre al final)
        'views/actions_morenitapp.xml',
        'views/menus_morenitapp.xml',
        
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
}