# MorenitApp

**Autora:** Ana Gómez Jurado  
**Proyecto:** Trabajo de Fin de Grado  
**Aplicación en producción:** [https://morenitapp.com/#/login](https://morenitapp.com/#/login)

Sistema de gestión integral para una cofradía compuesto por un backend **Odoo 16** con módulo personalizado en Python y una aplicación **Flutter** multiplataforma (web, Android e iOS) que se comunican a través de una API REST propia.

---

## Índice

1. [Visión general del sistema](#1-visión-general-del-sistema)
2. [Estructura del repositorio](#2-estructura-del-repositorio)
3. [Infraestructura — Docker Compose](#3-infraestructura--docker-compose)
4. [Backend — Módulo Odoo `morenitapp`](#4-backend--módulo-odoo-morenitapp)
5. [Frontend — Aplicación Flutter `mobile/`](#5-frontend--aplicación-flutter-mobile)
6. [Comunicación entre capas](#6-comunicación-entre-capas)
7. [Puesta en marcha en local](#7-puesta-en-marcha-en-local)
8. [Despliegue en producción](#8-despliegue-en-producción)

---

## 1. Visión general del sistema

```
┌──────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                            │
│              Navegador web · Android · iOS                       │
└────────────────────────────┬─────────────────────────────────────┘
                             │  HTTPS
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│              APLICACIÓN FLUTTER  (mobile/)                       │
│                                                                  │
│  Clean Architecture · Riverpod · GoRouter · Dio                  │
│  Pantallas → Providers → Repositorios → Datasources (HTTP)       │
└────────────────────────────┬─────────────────────────────────────┘
                             │  API REST (JSON)
                             │  /login · /hermanos · /eventos
                             │  /libros · /proveedores · ...
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│       BACKEND ODOO 16  (custom-addons/morenitapp)                │
│                                                                  │
│  Controladores HTTP → Modelos ORM → Lógica de negocio            │
│  Seguridad por grupos · Vistas XML · CORS middleware             │
└────────────────────────────┬─────────────────────────────────────┘
                             │  ORM Odoo / SQL
                             ▼
┌──────────────────────────────────────────────────────────────────┐
│                   PostgreSQL 15  (Docker)                        │
│                   Base de datos: MorenitApp                      │
└──────────────────────────────────────────────────────────────────┘
```

| Capa | Tecnología | Responsabilidad |
|---|---|---|
| Base de datos | PostgreSQL 15 | Persistencia de todos los datos |
| Backend / API | Odoo 16 + addon `morenitapp` | Modelos, lógica de negocio y endpoints REST |
| Frontend | Flutter / Dart | Interfaz de usuario multiplataforma |
| Contenedores | Docker Compose | Orquestación del entorno completo |

---

## 2. Estructura del repositorio

```
MORENITAPP/                              # Raíz del proyecto
├── docker-compose.yml                   # Orquestación de servicios
├── README.md                            # Este archivo
├── custom-addons/                       # Módulos personalizados de Odoo
│   └── morenitapp/                      # Módulo principal de la aplicación
│       ├── __init__.py                  # Punto de entrada del módulo Python
│       ├── __manifest__.py              # Metadatos: nombre, versión, dependencias
│       ├── controllers/                 # Controladores HTTP — API REST
│       │   ├── __init__.py
│       │   ├── api_configuracion.py     # Endpoints de datos maestros y catálogos
│       │   ├── api_eventos_cultos.py    # Endpoints de eventos, organizadores y notificaciones
│       │   ├── api_hermanos.py          # Endpoints del padrón de hermanos
│       │   ├── api_libros.py            # Endpoints de libros y anunciantes
│       │   ├── api_logs.py              # Endpoints del log de actividad
│       │   ├── api_proveedores.py       # Endpoints del directorio de proveedores
│       │   ├── api_secretaria.py        # Endpoints de autoridades, cargos y cofradías
│       │   ├── api_ubicaciones.py       # Endpoints del catálogo geográfico
│       │   ├── api_usuario.py           # Endpoints de usuarios y autenticación
│       │   └── cors_middleware.py       # Middleware CORS para peticiones desde Flutter web
│       ├── models/                      # Modelos de datos — ORM de Odoo
│       │   ├── __init__.py
│       │   ├── activitylog.py           # Log de actividad de las operaciones
│       │   ├── autoridad.py             # Autoridades de la cofradía
│       │   ├── banco.py                 # Datos bancarios vinculados a hermanos
│       │   ├── calle.py                 # Catálogo de calles
│       │   ├── cargo.py                 # Cargos de la cofradía
│       │   ├── codigopostal.py          # Catálogo de códigos postales
│       │   ├── cofradia.py              # Cofradías hermanas
│       │   ├── evento.py                # Eventos y cultos
│       │   ├── grupoproveedor.py        # Grupos de clasificación de proveedores
│       │   ├── hermano.py               # Padrón de hermanos (modelo central)
│       │   ├── libro.py                 # Libros y revistas de la cofradía
│       │   ├── libroanunciante.py       # Relación libro ↔ proveedor anunciante
│       │   ├── localidad.py             # Catálogo de localidades
│       │   ├── notificacion.py          # Notificaciones enviadas a hermanos
│       │   ├── organizador.py           # Organizadores de eventos
│       │   ├── proveedor.py             # Directorio de proveedores
│       │   ├── provincia.py             # Catálogo de provincias
│       │   ├── rol.py                   # Roles de usuario del sistema
│       │   ├── tipoautoridad.py         # Tipos de autoridad (catálogo)
│       │   ├── tipocargo.py             # Tipos de cargo (catálogo)
│       │   ├── tipoevento.py            # Tipos de evento con color (catálogo)
│       │   ├── tipoNotificacion.py      # Tipos de notificación (catálogo)
│       │   └── usuario.py               # Usuarios del sistema con rol y vinculación
│       ├── security/                    # Control de acceso
│       │   ├── groups.xml               # Definición de grupos de usuarios
│       │   └── ir.model.access.csv      # Permisos CRUD por modelo y grupo
│       ├── static/
│       │   └── description/
│       │       └── icon.png             # Icono del módulo en la interfaz de Odoo
│       ├── views/                       # Vistas XML para el back-office de Odoo
│       │   └── ...xml
│       └── resend_mail/                 # Módulo auxiliar para reenvío de correos
└── mobile/                              # Aplicación Flutter
    ├── README.md                        # Documentación completa de Flutter
    ├── pubspec.yaml
    ├── .env                             # Variables de entorno (no subir a Git)
    └── lib/
        └── ...                          # Ver mobile/README.md
```

---

## 3. Infraestructura — Docker Compose

El entorno completo se levanta con un único comando. El fichero `docker-compose.yml` define tres servicios que trabajan juntos:

```yaml
version: '3.8'

services:
  web:        # Odoo 16
  db:         # PostgreSQL 15
  pgadmin:    # pgAdmin 4 (administración visual de la BD)

volumes:
  web-data-morenitapp:   # Datos persistentes de Odoo
  db-data-morenitapp:    # Datos persistentes de PostgreSQL
```

### Servicio `web` — Odoo 16

| Parámetro | Valor | Descripción |
|---|---|---|
| Imagen | `odoo:16.0` | Versión oficial de Odoo |
| Puerto | `8069` | Interfaz web y API REST |
| Volumen código | `./custom-addons:/mnt/extra-addons` | El módulo se monta en caliente: cualquier cambio en `custom-addons/` es inmediatamente visible en Odoo sin reconstruir la imagen |
| Volumen datos | `web-data-morenitapp:/var/lib/odoo` | Sesiones, archivos adjuntos y datos internos de Odoo |
| Base de datos | `MorenitApp` | Nombre de la base de datos Odoo |

El comando de arranque apunta directamente a la base de datos `MorenitApp`:
```
odoo --db_host=db --db_user=odoo --db_password=odoo -d MorenitApp
```

### Servicio `db` — PostgreSQL 15

| Parámetro | Valor |
|---|---|
| Imagen | `postgres:15` |
| Puerto | `5432` |
| Base de datos | `postgres` (catálogo interno; Odoo crea `MorenitApp` aparte) |
| Usuario / contraseña | `odoo` / `odoo` |
| Volumen datos | `db-data-morenitapp` |

Los datos de PostgreSQL persisten en el volumen `db-data-morenitapp`, por lo que no se pierden al parar o reiniciar los contenedores.

### Servicio `pgadmin` — pgAdmin 4

| Parámetro | Valor |
|---|---|
| Imagen | `dpage/pgadmin4` |
| Puerto | `5050` → `http://localhost:5050` |
| Email de acceso | `admin@admin.com` |
| Contraseña | `admin` |

Interfaz web para explorar, consultar y administrar visualmente la base de datos PostgreSQL. Útil durante el desarrollo para inspeccionar las tablas generadas por el ORM de Odoo.

### Resumen de puertos

| Puerto local | Servicio | URL |
|---|---|---|
| `8069` | Odoo (API + back-office) | `http://localhost:8069` |
| `5432` | PostgreSQL | `localhost:5432` |
| `5050` | pgAdmin | `http://localhost:5050` |

---

## 4. Backend — Módulo Odoo `morenitapp`

El addon `morenitapp` es un módulo Python que extiende Odoo 16 con los modelos de datos de la cofradía y expone una API REST consumida por la app Flutter.

### 4.1 `__manifest__.py`

Archivo de metadatos obligatorio en todo módulo Odoo. Define el nombre, versión, autor, las dependencias de otros módulos Odoo (`base`, `mail`...) y la lista de archivos XML de datos, seguridad y vistas que Odoo debe cargar al instalar o actualizar el módulo.

### 4.2 `models/` — Modelos de datos

Cada archivo define una o varias clases que heredan de `models.Model`. El ORM de Odoo crea y mantiene automáticamente las tablas correspondientes en PostgreSQL.

#### Modelos de entidades principales

| Archivo | Modelo Odoo | Descripción |
|---|---|---|
| `hermano.py` | `morenitapp.hermano` | **Modelo central.** Padrón de hermanos con datos personales, bancarios, de dirección, estado (activo/baja) y método de pago |
| `banco.py` | `morenitapp.banco` | Datos bancarios asociados a cada hermano (IBAN, entidad, sucursal, cuenta) |
| `evento.py` | `morenitapp.evento` | Eventos y cultos con fecha de inicio/fin, lugar, tipo y organizador |
| `organizador.py` | `morenitapp.organizador` | Entidades organizadoras de eventos con logo y firmas (presidente, secretario, tesorero) almacenados como campos `Binary` en base64 |
| `notificacion.py` | `morenitapp.notificacion` | Notificaciones con asunto, mensaje HTML, tipo y lista de destinatarios. Al crearse con `enviarahora: true`, el modelo dispara el envío de correos automáticamente |
| `libro.py` | `morenitapp.libro` | Libros y revistas de la cofradía con archivos adjuntos y textos configurables para documentos |
| `libroanunciante.py` | `morenitapp.libro.anunciante` | Relación many-to-many entre libros y proveedores, con importe y estado de cobro |
| `proveedor.py` | `morenitapp.proveedor` | Directorio de proveedores. Campo booleano `anunciante` para marcar si es también anunciante de libros |
| `activitylog.py` | `morenitapp.activity.log` | Registro de operaciones realizadas (crear, editar, eliminar) sobre el padrón, con usuario y fecha |

#### Modelos de secretaría

| Archivo | Modelo Odoo | Descripción |
|---|---|---|
| `autoridad.py` | `morenitapp.autoridad` | Autoridades con nombre de saluda para documentos protocolarios y tipo de autoridad |
| `cargo.py` | `morenitapp.cargo` | Cargos con fechas de inicio y fin, texto de saludo y tipo de cargo |
| `cofradia.py` | `morenitapp.cofradia` | Cofradías hermanas con CIF, año de fundación y datos de contacto |

#### Modelos de ubicaciones (catálogo geográfico en cascada)

| Archivo | Modelo Odoo | Descripción |
|---|---|---|
| `provincia.py` | `morenitapp.provincia` | Catálogo de provincias |
| `localidad.py` | `morenitapp.localidad` | Localidades vinculadas a una provincia |
| `codigopostal.py` | `morenitapp.codigopostal` | Códigos postales vinculados a una localidad |
| `calle.py` | `morenitapp.calle` | Calles vinculadas a una localidad y un código postal |

#### Modelos de configuración (catálogos)

| Archivo | Modelo Odoo | Descripción |
|---|---|---|
| `tipoevento.py` | `morenitapp.tipo.evento` | Tipos de evento con código, nombre y color hexadecimal |
| `tipocargo.py` | `morenitapp.tipo.cargo` | Tipos de cargo |
| `tipoautoridad.py` | `morenitapp.tipo.autoridad` | Tipos de autoridad |
| `tipoNotificacion.py` | `morenitapp.tipo.notificacion` | Tipos de notificación |
| `grupoproveedor.py` | `morenitapp.grupo.proveedor` | Grupos de clasificación de proveedores |
| `rol.py` | `morenitapp.rol` | Roles del sistema (administrador, usuario, invitado) |

#### Modelo de usuarios

| Archivo | Modelo Odoo | Descripción |
|---|---|---|
| `usuario.py` | `morenitapp.usuario` | Usuarios del sistema con nombre, email, contraseña hasheada, rol, grupo y vinculación opcional con un hermano del padrón |

### 4.3 `controllers/` — API REST

Cada controlador hereda de `http.Controller` de Odoo y expone sus métodos como endpoints HTTP mediante el decorador `@http.route`. Todos los endpoints devuelven JSON.

#### `cors_middleware.py`

Middleware especial que añade las cabeceras CORS necesarias para que la aplicación Flutter en versión **web** pueda hacer peticiones HTTP al servidor Odoo desde un dominio diferente. Sin este middleware, el navegador bloquearía todas las peticiones de la app Flutter web por política de mismo origen.

#### `api_usuario.py` — Autenticación y usuarios

| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/login` | Valida email y contraseña. Devuelve los datos completos del usuario si las credenciales son correctas |
| `POST` | `/registrar` | Crea un nuevo usuario en el sistema |
| `POST` | `/usuarios` | Lista todos los usuarios (con filtros opcionales en el body) |
| `POST` | `/usuarios/create` | Crea un nuevo usuario desde el panel de administración |
| `POST` | `/usuarios/update` | Actualiza los datos de un usuario existente |
| `POST` | `/usuarios/delete` | Elimina un usuario |

#### `api_hermanos.py` — Padrón de hermanos

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/hermanos` | Lista completa de hermanos |
| `POST` | `/hermanos` | Crea un nuevo hermano |
| `PUT` | `/hermanos/<id>` | Actualiza los datos de un hermano |
| `DELETE` | `/hermanos/<id>` | Elimina un hermano |

#### `api_eventos_cultos.py` — Eventos, organizadores y notificaciones

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/eventos` | Lista de eventos |
| `POST` | `/eventos` | Crear evento |
| `PUT` | `/eventos/<id>` | Actualizar evento |
| `DELETE` | `/eventos/<id>` | Eliminar evento |
| `GET` | `/organizadores` | Lista de organizadores |
| `POST` | `/organizadores` | Crear organizador |
| `PUT` | `/organizadores/<id>` | Actualizar organizador |
| `DELETE` | `/organizadores/<id>` | Eliminar organizador |
| `GET` | `/notificaciones` | Lista de notificaciones enviadas |
| `POST` | `/notificaciones` | Crear y enviar notificación por correo |
| `DELETE` | `/notificaciones/<id>` | Eliminar notificación |

#### `api_libros.py` — Biblioteca digital

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/libros` | Lista de libros con anunciantes y archivos adjuntos |
| `POST` | `/libros` | Crear libro |
| `POST` | `/libros/<id>` | Actualizar libro (usa POST por diseño del controlador) |
| `DELETE` | `/libros/<id>` | Eliminar libro |

#### `api_proveedores.py` — Proveedores y anunciantes

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/proveedores` | Lista de proveedores |
| `POST` | `/proveedores/crear` | Crear proveedor |
| `POST` | `/proveedores/update` | Actualizar proveedor |
| `POST` | `/proveedores/delete` | Eliminar proveedor |

#### `api_secretaria.py` — Autoridades, cargos y cofradías

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/autoridades` | Lista de autoridades |
| `POST` | `/autoridades` | Crear autoridad |
| `PUT` | `/autoridades/<id>` | Actualizar autoridad |
| `DELETE` | `/autoridades/<id>` | Eliminar autoridad |
| `GET` | `/cargos` | Lista de cargos |
| `POST` | `/cargos` | Crear cargo |
| `PUT` | `/cargos/<id>` | Actualizar cargo |
| `DELETE` | `/cargos/<id>` | Eliminar cargo |
| `GET` | `/cofradias` | Lista de cofradías hermanas |
| `POST` | `/cofradias` | Crear cofradía |
| `PUT` | `/cofradias/<id>` | Actualizar cofradía |
| `DELETE` | `/cofradias/<id>` | Eliminar cofradía |

#### `api_ubicaciones.py` — Catálogo geográfico

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/provincias` | Lista de provincias |
| `POST` | `/provincias` | Crear provincia |
| `PUT` | `/provincias/<id>` | Actualizar provincia |
| `DELETE` | `/provincias/<id>` | Eliminar provincia |
| `GET` | `/localidades` | Lista de localidades |
| `POST/PUT/DELETE` | `/localidades/...` | CRUD de localidades |
| `GET` | `/codigospostales` | Lista de códigos postales |
| `POST/PUT/DELETE` | `/codigospostales/...` | CRUD de códigos postales |
| `GET` | `/calles` | Lista de calles |
| `POST` | `/calles` | Crear calle |
| `PUT` | `/calles/<id>` | Actualizar calle |
| `DELETE` | `/calles/<id>` | Eliminar calle |

#### `api_configuracion.py` — Datos maestros

| Método | Endpoint | Descripción |
|---|---|---|
| `GET/POST/PUT/DELETE` | `/tipos-evento/...` | CRUD de tipos de evento |
| `GET/POST/PUT/DELETE` | `/tipos-cargo/...` | CRUD de tipos de cargo |
| `GET/POST/PUT/DELETE` | `/tipos-autoridad/...` | CRUD de tipos de autoridad |
| `GET/POST/PUT/DELETE` | `/grupos-proveedor/...` | CRUD de grupos de proveedores |
| `GET/POST/PUT/DELETE` | `/notificaciones-tipos/...` | CRUD de tipos de notificación |
| `GET` | `/roles` | Lista de roles del sistema |

#### `api_logs.py` — Registro de actividad

| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/activity-logs` | Lista de registros de actividad |
| `POST` | `/activity-logs` | Guardar un nuevo registro de actividad |

### 4.4 `security/` — Control de acceso

#### `groups.xml`

Define los tres grupos de usuarios del módulo:

| Grupo | ID técnico | Descripción |
|---|---|---|
| Administrador | `group_morenitapp_admin` | Acceso total de lectura y escritura sobre todos los modelos |
| Usuario | `group_morenitapp_user` | Acceso de lectura sobre datos generales. Sin permisos de escritura |
| Invitado | `group_morenitapp_guest` | Acceso mínimo de solo lectura a datos públicos |

#### `ir.model.access.csv`

Archivo CSV leído por Odoo al instalar o actualizar el módulo. Define qué grupos tienen permisos de lectura (`perm_read`), escritura (`perm_write`), creación (`perm_create`) y eliminación (`perm_unlink`) sobre cada modelo:

```
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_hermano_admin,hermano admin,model_morenitapp_hermano,group_morenitapp_admin,1,1,1,1
access_hermano_user,hermano user,model_morenitapp_hermano,group_morenitapp_user,1,0,0,0
...
```

### 4.5 `views/` — Vistas XML

Vistas para el back-office interno de Odoo: formularios, listas y menús accesibles desde `http://localhost:8069`. Permiten gestionar los datos directamente desde la interfaz web de Odoo sin usar la app Flutter, lo que es especialmente útil durante el desarrollo y el mantenimiento de datos.

### 4.6 `resend_mail/` — Módulo auxiliar

Módulo auxiliar encargado del reenvío de correos electrónicos. Complementa la funcionalidad de notificaciones del módulo principal, gestionando los reintentos de envío cuando el servidor de correo no está disponible en el momento de crear la notificación.

### 4.7 `static/description/icon.png`

Icono del módulo que aparece en la interfaz de Odoo en la sección de Aplicaciones instaladas.

---

## 5. Frontend — Aplicación Flutter (`mobile/`)

La aplicación Flutter consume la API REST del módulo Odoo y presenta la información al usuario en una interfaz multiplataforma (web, Android, iOS).

### 5.1 Tecnologías

| Herramienta | Versión | Uso |
|---|---|---|
| Flutter | 13.813.134 | Framework de UI multiplataforma |
| Dart | 4.858.007 | Lenguaje de programación |
| Riverpod | — | Gestión de estado reactiva |
| GoRouter | — | Navegación declarativa con redirecciones por rol |
| Dio | — | Cliente HTTP para la API REST de Odoo |

### 5.2 Arquitectura — Clean Architecture

Cada módulo funcional de la app sigue tres capas bien separadas:

```
presentation/     ← Pantallas Flutter + providers Riverpod
                     Las pantallas solo leen estado y llaman a providers.
                     Sin lógica de negocio ni llamadas HTTP directas.

domain/           ← Reglas de negocio puras sin dependencias externas.
                     Entidades Dart · contratos abstractos de datasources
                     y repositorios. Si cambia Flutter u Odoo, esta capa
                     no necesita modificarse.

infrastructure/   ← Implementaciones concretas.
                     Llamadas HTTP reales a Odoo con Dio.
                     Parseo de JSON a entidades Dart (fromJson / mappers).
```

### 5.3 Módulos funcionales

| Módulo | Carpeta | Funcionalidad principal |
|---|---|---|
| Autenticación | `auth/` | Login, registro, sesión persistente, acceso como invitado |
| Panel administración | `panel-gestion/home_screen.dart` | Dashboard con estadísticas, actividad reciente y próximos eventos |
| Hermanos | `panel-gestion/hermanos/` | Padrón completo: altas, bajas, reactivaciones, filtros avanzados, exportación |
| Eventos y cultos | `panel-gestion/eventos-cultos/` | Calendario interactivo, gestión de organizadores y envío de notificaciones |
| Libros | `panel-gestion/libros/` | Biblioteca digital con anunciantes, archivos adjuntos y generación de PDF |
| Proveedores | `panel-gestion/proveedores/` | Directorio de proveedores y anunciantes |
| Secretaría | `panel-gestion/secretaria/` | Autoridades, cargos y cofradías hermanas |
| Ubicaciones | `panel-gestion/ubicaciones/` | Catálogo geográfico en cascada (provincia → calle) |
| Configuración | `panel-gestion/configuracion/` | Datos maestros y catálogos del sistema |
| Usuarios | `panel-gestion/usuarios/` | Gestión de usuarios y roles |
| Panel usuario | `panel_usuario/` | Vista reducida para usuarios no administradores |

### 5.4 Roles y acceso

| Rol | ID | Acceso en la app |
|---|---|---|
| Administrador | 1 | Acceso total a todos los módulos |
| Usuario estándar | 2 | Panel personal, perfil, libros, eventos y notificaciones |
| Invitado | 3 | Calendario, eventos y biblioteca (solo lectura, sin cuenta) |

### 5.5 Código compartido (`shared/`)

La carpeta `features/shared/` centraliza el código reutilizable entre módulos:

**`infrastructure/inputs/`** — Campos Formz con validación integrada: `email.dart`, `full_name.dart`, `password.dart`, `telefono.dart`, `dni.dart` y el barrel `inputs.dart`.

**`infrastructure/services/`** — Almacenamiento local clave-valor con SharedPreferences para persistir el token de sesión entre reinicios.

**`excel/excel_service.dart`** — Servicio de generación de archivos `.xlsx` usado por todos los módulos con exportación tabular.

**`widgets/`** — Componentes reutilizables: `plantilla_ventanas.dart` (tablas de gestión), `plantilla_formularios.dart` (formularios completos), `side_menu.dart` (menú admin), `menu_usuario.dart` (menú usuario), `calle_search_delegate.dart` (buscador de calles con autocompletado), `disenio_informes.dart` (diseño base de PDFs), `custom_text_form_field.dart`, `custom_filled_button.dart`, `formulario_filtros.dart`.

Para la documentación completa de Flutter, ver [`mobile/README.md`](mobile/README.md).

---

## 6. Comunicación entre capas

### Flujo de una petición completa

```
1. El usuario pulsa un botón en la pantalla Flutter
2. La pantalla llama a un método del provider (ref.read)
3. El provider llama al repositorio
4. El repositorio llama al datasource
5. El datasource envía la petición HTTP con Dio → Odoo
6. El controlador Odoo recibe la petición en @http.route
7. El controlador llama al modelo ORM de Odoo
8. El ORM ejecuta SQL en PostgreSQL
9. PostgreSQL devuelve los datos
10. El modelo construye la respuesta JSON
11. El controlador devuelve el JSON al datasource
12. El datasource parsea el JSON con fromJson → entidad Dart
13. El provider actualiza el estado (AsyncValue.data)
14. La pantalla se redibuja con los nuevos datos (ref.watch)
```

### Particularidades de Odoo en el JSON

El datasource de Flutter maneja explícitamente las particularidades del formato de respuesta de Odoo:

| Particularidad | Ejemplo Odoo | Cómo se maneja en Flutter |
|---|---|---|
| Campos vacíos devueltos como `false` booleano | `"nombre": false` | Función `clean()` en `fromJson` convierte `false` a `""` o `null` |
| Campos relacionales Many2one como lista | `"tipo_id": [3, "Procesión"]` | Se extrae `[0]` para el id y `[1]` para el nombre |
| Fechas con espacio en lugar de `T` | `"2026-03-15 18:00:00"` | `.replaceAll(' ', 'T')` antes de `DateTime.parse` |
| Imágenes como cadena base64 | `"logo": "iVBORw0KGgo..."` | `Image.memory(base64Decode(b64))` en Flutter |
| Respuesta envuelta en `result` (JSON-RPC) | `{"result": [...]}` | El datasource comprueba si existe `result` y lo extrae |

### Autenticación

La app no usa JWT ni sesiones de cookie de Odoo. El flujo es:

1. Flutter envía `POST /login` con email y contraseña.
2. El controlador Odoo valida las credenciales y devuelve los datos del usuario incluyendo su `id`.
3. Flutter guarda el `id` como token en **SharedPreferences** del dispositivo.
4. En cada arranque, `AuthNotifier` lee el `id` guardado, hace `POST /usuarios` buscando ese `id` y, si lo encuentra, restaura la sesión con datos actualizados desde Odoo.
5. Al cerrar sesión, se elimina el `id` de SharedPreferences.

---

## 7. Puesta en marcha en local

### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y en ejecución
- [Flutter SDK](https://docs.flutter.dev/get-started/install) versión 13.813.134
- Git

### Paso 1 — Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd morenitapp
```

### Paso 2 — Levantar el backend

```bash
docker compose up -d
```

Esto arranca los tres contenedores. La primera vez Odoo tarda unos minutos en inicializarse y crear la base de datos `MorenitApp`.

Verificar que todo está corriendo:

```bash
docker compose ps
```

### Paso 3 — Instalar el módulo en Odoo

1. Acceder a `http://localhost:8069`.
2. Ir a **Ajustes → Activar modo desarrollador**.
3. Ir a **Aplicaciones → Actualizar lista de aplicaciones**.
4. Buscar `morenitapp` e instalarlo.

Al instalarse, Odoo carga automáticamente todos los modelos (crea las tablas en PostgreSQL), los permisos de `ir.model.access.csv`, los grupos de `groups.xml` y los datos iniciales.

### Paso 4 — Configurar y ejecutar Flutter

```bash
cd mobile
```

Crear el archivo `.env` en la carpeta `mobile/`:

```env
API_URL=http://localhost:8069
```

Instalar dependencias y ejecutar:

```bash
flutter pub get
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

### Comandos útiles de Docker

```bash
# Ver logs de Odoo en tiempo real
docker logs -f odoo16

# Reiniciar Odoo tras cambios en el módulo Python
docker compose restart web

# Parar todos los servicios (los datos se conservan en los volúmenes)
docker compose down

# Parar y eliminar todos los datos (⚠️ irreversible)
docker compose down -v

# Acceder a la consola SQL de PostgreSQL
docker exec -it postgres15 psql -U odoo -d MorenitApp

# Abrir una shell dentro del contenedor de Odoo
docker exec -it odoo16 bash
```

### Actualizar el módulo tras cambios en código Python o XML

Cuando se modifica `custom-addons/morenitapp/` (modelos, controladores, datos o vistas):

```bash
# Opción 1: reiniciar el contenedor (recarga los controladores)
docker compose restart web

# Opción 2: actualizar el módulo desde la interfaz de Odoo
# Aplicaciones → morenitapp → Actualizar
# (necesario cuando se añaden nuevos campos a los modelos)
```

---

## 8. Despliegue en producción

En producción la aplicación está desplegada en `morenitapp.com` usando el mismo `docker-compose.yml` con variables de entorno seguras.

### Backend

Antes de desplegar en producción, reemplazar las credenciales por defecto en `docker-compose.yml`:

```yaml
environment:
  - POSTGRES_PASSWORD=<contraseña-segura>
  - PASSWORD=<contraseña-segura>
```

Se recomienda usar un fichero `.env` separado para las variables sensibles y referenciarlo con `env_file` en `docker-compose.yml`, manteniéndolo fuera del repositorio (en `.gitignore`).

### Frontend (Flutter web)

```bash
cd mobile

# Crear .env de producción
echo "API_URL=https://morenitapp.com" > .env

# Compilar
flutter build web --release
```

El resultado en `mobile/build/web/` se despliega como sitio estático en el servidor.

### Acceso a los servicios en producción

| Servicio | URL |
|---|---|
| Aplicación Flutter | [https://morenitapp.com/#/login](https://morenitapp.com/#/login) |
| Back-office Odoo | `https://morenitapp.com:8069` |
| pgAdmin | No expuesto públicamente en producción |

---

*MorenitApp — Trabajo de Fin de Grado · Ana Gómez Jurado*