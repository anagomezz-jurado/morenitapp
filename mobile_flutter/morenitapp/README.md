# MorenitApp — Aplicación Flutter

**Autora:** Ana Gómez Jurado  
**Proyecto:** Trabajo de Fin de Grado  
**Acceso a la aplicación:** [https://morenitapp.com/#/login](https://morenitapp.com/#/login)

---

## Índice

1. [Descripción general](#1-descripción-general)
2. [Requisitos previos](#2-requisitos-previos)
3. [Instalación y configuración](#3-instalación-y-configuración)
4. [Estructura del proyecto](#4-estructura-del-proyecto)
5. [Arquitectura](#5-arquitectura)
6. [Módulos principales](#6-módulos-principales)
7. [Carpeta shared — código compartido](#7-carpeta-shared--código-compartido)
8. [Gestión de estado](#8-gestión-de-estado)
9. [Navegación](#9-navegación)
10. [Identidad visual](#10-identidad-visual)
11. [Dependencias principales](#11-dependencias-principales)
12. [Funcionalidades destacadas](#12-funcionalidades-destacadas)

---

## 1. Descripción general

MorenitApp es una aplicación móvil y web desarrollada con **Flutter** que sirve como plataforma de gestión integral para una cofradía. Permite administrar el padrón de hermanos, la agenda de eventos y cultos, la biblioteca digital, el directorio de proveedores, la secretaría y las comunicaciones internas, todo ello conectado a un backend **Odoo** mediante una API REST propia.

La aplicación está disponible en **web, Android e iOS** desde una única base de código Flutter, y diferencia tres niveles de acceso: administrador, usuario estándar e invitado.

---

## 2. Requisitos previos

| Herramienta | Versión requerida |
|---|---|
| Flutter | 13.813.134 |
| Dart | 4.858.007 |
| Odoo (backend) | Instancia propia en [morenitapp.com](https://morenitapp.com) |

Además es necesario tener instalado:

- Android Studio o Xcode (según la plataforma de desarrollo)
- Un navegador moderno para la versión web
- Git para clonar el repositorio

---

## 3. Instalación y configuración

### 3.1 Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd morenitapp
```

### 3.2 Instalar dependencias

```bash
flutter pub get
```

### 3.3 Configurar las variables de entorno

Crear un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
API_URL=https://morenitapp.com
```

> Este archivo **no debe subirse al repositorio** (inclúyelo en `.gitignore`). Contiene la URL base de la API de Odoo. Si cambia el servidor, solo hay que modificar este valor sin tocar ningún archivo de código fuente. La clase `Environment` lo carga una única vez al arrancar la app desde `main.dart` y lo expone globalmente mediante `Environment.apiUrl`.

El archivo `.env` debe declararse también en `pubspec.yaml` como asset para que Flutter lo incluya en la compilación:

```yaml
flutter:
  assets:
    - .env
    - assets/icono.png
```

### 3.4 Generar iconos y splash screen

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Ambos comandos leen la configuración definida en `pubspec.yaml` y generan automáticamente los iconos en todos los tamaños requeridos por cada plataforma (Android, iOS, web, Windows, macOS) y la splash screen nativa con fondo blanco (`#ffffff`) e icono de la aplicación.

### 3.5 Ejecutar la aplicación

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### 3.6 Compilar para producción

```bash
# Web
flutter build web --release

# Android (APK)
flutter build apk --release

# Android (App Bundle)
flutter build appbundle --release
```

---

## 4. Estructura del proyecto

```
morenitapp/
├── assets/                              # Recursos estáticos (icono, imágenes)
│   └── icono.png
├── .env                                 # Variables de entorno (no incluir en Git)
├── pubspec.yaml                         # Configuración del proyecto y dependencias
└── lib/
    ├── main.dart                        # Punto de entrada de la aplicación
    ├── config/                          # Configuración global
    │   ├── environment.dart             # Carga del archivo .env
    │   ├── app_theme.dart               # Tema visual y componente MainBackground
    │   └── router/
    │       ├── app_router.dart          # Definición de rutas y lógica de redirección
    │       └── app_router_notifier.dart # Conexión entre autenticación y router
    └── features/
        ├── auth/                        # Autenticación e identidad del usuario
        │   ├── domain/
        │   │   ├── entities/user.dart
        │   │   ├── datasources/auth_datasource.dart
        │   │   └── repositories/auth_repository.dart
        │   ├── infrastructure/
        │   │   ├── errors/auth_errors.dart
        │   │   ├── mappers/user_mapper.dart
        │   │   ├── datasources/auth_datasource_impl.dart
        │   │   └── repositories/auth_repository_impl.dart
        │   └── presentation/
        │       ├── providers/
        │       │   ├── auth_provider.dart
        │       │   ├── login_form_provider.dart
        │       │   └── register_form_provider.dart
        │       └── screens/
        │           ├── login_screen.dart
        │           └── register_screen.dart
        ├── panel-gestion/
        │   ├── home_screen.dart         # Panel de administración
        │   ├── activity_log.dart        # Entidad y datasource del log de actividad
        │   ├── activity_log_provider.dart
        │   ├── configuracion/           # Datos maestros (tipos, roles, grupos...)
        │   ├── eventos-cultos/          # Agenda de eventos, organizadores y notificaciones
        │   ├── hermanos/                # Padrón de hermanos
        │   ├── libros/                  # Biblioteca digital y anunciantes
        │   ├── proveedores/             # Directorio de proveedores
        │   ├── secretaria/              # Autoridades, cargos y cofradías hermanas
        │   ├── ubicaciones/             # Catálogo geográfico (provincias, calles...)
        │   └── usuarios/                # Gestión de usuarios del sistema
        ├── panel_usuario/
        │   ├── panel_usuario_screen.dart
        │   └── perfil/
        │       ├── perfil_screen.dart
        │       ├── libro_screen.dart
        │       └── notificaciones_screen.dart
        └── shared/                      # Código reutilizable transversal
            ├── excel/
            │   └── excel_service.dart   # Generación de archivos Excel
            ├── infrastructure/
            │   ├── inputs/              # Campos Formz con validación integrada
            │   │   ├── dni.dart
            │   │   ├── email.dart
            │   │   ├── full_name.dart
            │   │   ├── password.dart
            │   │   ├── telefono.dart
            │   │   └── inputs.dart      # Barrel de exportación
            │   └── services/
            │       ├── key_value_storage_service.dart      # Contrato abstracto
            │       └── key_value_storage_service_impl.dart # Impl. con SharedPreferences
            └── widgets/
                ├── calle_search_delegate.dart   # Buscador de calles reutilizable
                ├── custom_filled_button.dart    # Botón primario con estilo unificado
                ├── custom_text_form_field.dart  # Campo de texto con estilo unificado
                ├── disenio_informes.dart        # Diseño base para informes PDF
                ├── filtro_avanzado_model.dart   # Modelo de datos para filtros avanzados
                ├── formulario_filtros.dart      # Widget de filtros avanzados
                ├── menu_diseno.dart             # Componentes visuales compartidos del menú
                ├── menu_usuario.dart            # Menú lateral para usuarios estándar
                ├── plantilla_formularios.dart   # Plantilla base para formularios completos
                ├── plantilla_ventanas.dart      # Plantilla base para tablas de gestión
                └── side_menu.dart              # Menú lateral para administradores
```

---

## 5. Arquitectura

La aplicación está construida sobre **Clean Architecture** (Arquitectura Limpia), un patrón que separa el código en capas con responsabilidades bien definidas. Cada capa solo conoce a la que tiene por debajo, nunca al revés, lo que hace que el código sea más fácil de mantener, probar y modificar.

```
┌──────────────────────────────────────────────────────┐
│                   PRESENTATION                       │
│         Flutter widgets + Riverpod providers         │
│   Las pantallas leen estado y llaman a providers.    │
│        No contienen lógica de negocio ni red.        │
├──────────────────────────────────────────────────────┤
│                     DOMAIN                           │
│       Entidades · Datasources abstractos             │
│            Repositorios abstractos                   │
│  Reglas de negocio puras. Sin dependencias externas. │
│  Si mañana cambia Flutter u Odoo, esta capa no       │
│  necesita modificarse.                               │
├──────────────────────────────────────────────────────┤
│                 INFRASTRUCTURE                       │
│   Implementaciones concretas de datasources y repos  │
│   Llamadas HTTP reales a Odoo con Dio.               │
│   Mappers de JSON a entidades Dart.                  │
│   Si cambia el backend, solo se toca esta capa.      │
└──────────────────────────────────────────────────────┘
```

### Flujo de datos

```
Pantalla (screen)
    │  ref.watch(provider)
    ▼
Provider / Notifier (Riverpod)
    │  repository.getXxx()
    ▼
Repository (abstracción)
    │  datasource.getXxx()
    ▼
Datasource Impl (Dio → Odoo API)
    │  HTTP GET / POST / PUT / DELETE
    ▼
Backend Odoo → JSON
    │  Mapper / fromJson
    ▼
Entidad Dart → estado del provider → UI actualizada
```

---

## 6. Módulos principales

### Autenticación (`auth`)

Gestiona el inicio de sesión, registro, verificación de sesión activa y acceso como invitado. Es el módulo más transversal: el resto de funcionalidades dependen de él para saber quién es el usuario y qué permisos tiene.

**Roles del sistema:**

| Rol | ID | Acceso |
|---|---|---|
| Administrador | 1 | Acceso total a todas las rutas |
| Usuario estándar | 2 | Panel personal, perfil, libros, eventos y notificaciones |
| Invitado | 3 | Solo lectura de un conjunto reducido de rutas sin cuenta |

**Características clave:**
- Al arrancar la app, `AuthNotifier` verifica automáticamente si hay un token guardado en `SharedPreferences` y lo valida contra Odoo. Si la sesión sigue siendo válida, el usuario entra directamente sin necesidad de iniciar sesión de nuevo.
- El acceso como invitado crea un usuario ficticio con rol 3 y un token predefinido, permitiendo explorar el calendario, los eventos y la biblioteca sin registrarse.
- Los formularios de login y registro usan inputs Formz tipados (`email.dart`, `password.dart`, `full_name.dart`, `telefono.dart`) con validación en tiempo real campo a campo.
- El registro incluye confirmación de contraseña, aceptación de términos y preferencia de notificaciones por email.

###  Hermanos (`hermanos`)

Módulo central de la aplicación. Gestiona el padrón completo de hermanos de la cofradía con todas sus operaciones: altas, bajas, reactivaciones y edición de datos.

**Datos gestionados por hermano:**
- Identificación: número de hermano, código (generado automáticamente), nombre, apellidos, DNI
- Contacto: email, teléfono
- Filiación: sexo, fecha de alta, fecha de nacimiento, si está bautizado
- Dirección completa con selector de calle autocompletable
- Datos bancarios (IBAN, banco, sucursal, cuenta) visibles solo si el método de pago es domiciliado
- Estado: activo o baja, con fecha de baja, motivo y fecha de reactivación
- Método de pago: domiciliado o metálico

**Características clave:**
- El código de hermano se genera automáticamente combinando el número con la letra del sexo (H/M).
- El sistema de filtros avanzados permite filtrar por cualquier campo con operadores de comparación (contiene, igual a, mayor que, menor que), combinando varios filtros a la vez.
- La baja requiere confirmación con fecha y motivo obligatorio. La reactivación actualiza el estado en Odoo y registra la fecha automáticamente.
- Exportación de listados a Excel y PDF con logotipo de la cofradía en la cabecera.
- Todas las operaciones quedan registradas en el log de actividad visible en el panel de administración.

### Eventos y Cultos (`eventos-cultos`)

Agenda completa de la cofradía con tres subentidades: eventos, organizadores y notificaciones.

**Eventos:**
- Calendario interactivo (librería `table_calendar`) con marcadores de colores según el tipo de evento.
- Los marcadores del calendario muestran hasta tres círculos de colores por día, uno por evento, usando el color del tipo de evento.
- Formulario completo con selector de fechas (fecha + hora), tipo de evento, lugar y organizador.
- Si la fecha de fin resulta anterior a la de inicio tras modificarla, se ajusta automáticamente.

**Organizadores:**
- Gestión de entidades organizadoras con datos de contacto, dirección y cuatro imágenes en base64: logo, firma del presidente, firma del secretario y firma del tesorero.
- Las imágenes se seleccionan desde la galería del dispositivo, se codifican en base64 y se almacenan directamente en Odoo.

**Notificaciones:**
- Envío de correos electrónicos a todos los hermanos que han aceptado recibir notificaciones.
- La lista de destinatarios se obtiene en tiempo real desde el provider de usuarios, filtrando automáticamente los que tienen `recibirNotiEmail == true`.
- Formulario con dos pestañas: mensaje (asunto, tipo y texto) y destinatarios (lista con nombre, email e icono de verificación).

### Libros (`libros`)

Biblioteca digital de la cofradía con gestión de anunciantes vinculados y archivos adjuntos.

**Características clave:**
- Un libro puede tener múltiples anunciantes (vinculados al directorio de proveedores) y múltiples archivos adjuntos.
- Los importes de los anunciantes se editan directamente en línea dentro de la tabla, sin abrir formularios adicionales.
- Gestión del estado de cobro de cada anunciante con checkbox y fecha de cobro.
- Los archivos adjuntos se seleccionan desde el dispositivo con `FilePicker`, se codifican en base64 y se sincronizan con Odoo.
- Generación de PDF con el listado de anunciantes e importes para impresión directa desde la app.
- La vista para usuarios finales (biblioteca digital) permite abrir y descargar cada archivo según la plataforma: nueva pestaña del navegador en web, apertura con la app nativa en móvil.

### Proveedores (`proveedores`)

Directorio de proveedores con la dualidad **proveedor / anunciante**.

- Los proveedores marcados como anunciantes (`anunciante == true`) aparecen en el selector de anunciantes del módulo de libros.
- La pantalla de anunciantes filtra automáticamente usando el provider derivado `listaSoloAnunciantes`.
- Al crear un nuevo proveedor desde la pantalla de anunciantes, el switch de anunciante arranca activado (`forcedAnunciante: true`).
- Selector de grupo de proveedores vinculado al módulo de configuración.
- Selector de calle con autocompletado en cascada de provincia, localidad y código postal.

### Secretaría (`secretaria`)

Gestión de tres entidades: autoridades, cargos y cofradías hermanas.

**Diseño destacado:** uso de un `SecretariaNotifier<T>` genérico parametrizado con el tipo de entidad. En lugar de tres notifiers idénticos, uno solo acepta las funciones de fetch, save, update y delete como parámetros en el constructor, eliminando la duplicación de código.

- **Autoridades:** datos de identificación, nombre de saluda para documentos protocolarios, tipo de autoridad y datos de contacto y dirección.
- **Cargos:** tipo de cargo, fechas de inicio y fin, dirección, texto de saludo y observaciones.
- **Cofradías hermanas:** CIF, nombre, año de fundación, contacto y dirección completa.
- Exportación a Excel y PDF en los tres listados.

### Ubicaciones (`ubicaciones`)

Catálogo geográfico en cascada utilizado por todos los formularios que requieren dirección.

```
Provincia → Localidad → Código Postal → Calle
```

- Cada nivel filtra automáticamente al seleccionar el nivel superior mediante providers derivados.
- Antes de eliminar cualquier elemento, se comprueba si tiene dependencias en el nivel inferior (por ejemplo, no se puede eliminar una provincia si tiene localidades vinculadas), mostrando un diálogo de advertencia explicativo.
- La creación de calles nuevas está disponible desde cualquier formulario que use el selector de calle, sin necesidad de ir al módulo de ubicaciones.

### Configuración (`configuracion`)

Datos maestros que alimentan los selectores del resto de módulos.

| Catálogo | Uso |
|---|---|
| Tipos de evento | Selector en el formulario de eventos; color en el calendario |
| Tipos de cargo | Selector en el formulario de cargos |
| Tipos de autoridad | Selector en el formulario de autoridades |
| Roles | Selector en el formulario de usuarios |
| Grupos de proveedores | Selector en el formulario de proveedores |
| Tipos de notificación | Selector en el formulario de notificaciones |

Los tipos de evento tienen un selector visual de color con 12 colores predefinidos en paleta, mostrando previsualización en tiempo real del color elegido.

### Usuarios (`usuarios`)

Gestión administrativa del catálogo completo de usuarios del sistema.

- El rol (administrador o usuario estándar) se asigna desde un dropdown.
- El botón de eliminar no aparece cuando la fila corresponde al usuario autenticado actualmente, evitando que un administrador se borre a sí mismo.
- Los botones de editar y eliminar se reemplazan por un icono de candado para los usuarios sin permisos de administración.
- La contraseña no se devuelve desde el servidor; en la edición solo se actualiza si el campo no está vacío.

---

## 7. Carpeta shared — código compartido

La carpeta `features/shared` contiene todo el código reutilizable que no pertenece a ningún módulo concreto pero que es usado por varios de ellos. Se divide en tres bloques.

### 7.1 `infrastructure/inputs/` — Validación de formularios

Cada archivo define un campo de formulario tipado con la librería **Formz**. Los inputs encapsulan sus propias reglas de validación y se reutilizan en los formularios de registro y perfil. El archivo `inputs.dart` actúa como barrel, reexportando todos en una única importación.

| Archivo | Campo | Reglas de validación |
|---|---|---|
| `email.dart` | Correo electrónico | Formato válido con expresión regular |
| `full_name.dart` | Nombre completo | No vacío, longitud mínima |
| `password.dart` | Contraseña | Longitud mínima de caracteres |
| `telefono.dart` | Teléfono | Mínimo 9 caracteres numéricos |
| `dni.dart` | DNI | Exactamente 9 caracteres |

Los inputs son objetos **Formz** que tienen dos estados internos: `pure` (sin tocar) y `dirty` (modificado por el usuario). Los errores de validación solo se muestran cuando el campo está en estado `dirty` o cuando el usuario intenta enviar el formulario con `_touchEveryField`, que marca todos los campos como sucios a la vez.

### 7.2 `infrastructure/services/` — Servicios de infraestructura

**`key_value_storage_service.dart`** — Contrato abstracto que define la interfaz de almacenamiento local clave-valor: `getValue`, `setKeyValue` y `removeKey`. La capa de presentación depende de esta abstracción, no de la implementación concreta.

**`key_value_storage_service_impl.dart`** — Implementación concreta con **SharedPreferences**. Se usa para persistir el token de sesión del usuario entre reinicios de la app. Si el usuario cierra la app y la vuelve a abrir, `AuthNotifier` lee el token guardado, lo valida contra Odoo y restaura la sesión automáticamente sin pedir credenciales de nuevo.

**`excel/excel_service.dart`** — Servicio de generación de archivos Excel usando la librería `excel`. Recibe los encabezados y las filas de datos como listas de cadenas de texto y produce un archivo `.xlsx` descargable. Es usado por todos los módulos que ofrecen exportación tabular: hermanos, eventos, configuración, secretaría, ubicaciones y proveedores.

### 7.3 `widgets/` — Plantillas y componentes reutilizables

#### Plantillas de pantalla

**`plantilla_ventanas.dart`**
Plantilla base para todas las pantallas de listado y gestión en tabla. Recibe el título, las columnas, las filas, un indicador de carga, filtros adicionales opcionales y callbacks para las acciones (nuevo registro, refrescar, descargar Excel, descargar PDF). Gracias a esta plantilla, cada pantalla de gestión solo define sus datos específicos sin repetir la estructura de tabla, cabecera ni botones de acción. Cualquier cambio en el diseño de la tabla se aplica automáticamente a todos los módulos.

**`plantilla_formularios.dart`**
Plantilla base para formularios completos que ocupan pantalla entera (nuevo hermano, nuevo evento, nuevo organizador...). Proporciona la estructura visual coherente con `MainBackground` y gestiona el scroll, el padding y la disposición del contenido del formulario.

#### Menús de navegación

**`side_menu.dart`** — Menú lateral deslizante para usuarios **administradores**. Contiene todos los enlaces a los módulos de gestión: hermanos activos, hermanos de baja, eventos, calendario, libros, proveedores, anunciantes, secretaría, ubicaciones, configuración y usuarios. Se abre desde el botón de hamburguesa del panel de administración.

**`menu_usuario.dart`** — Versión reducida del menú lateral para usuarios **no administradores**. Solo muestra las secciones accesibles según su rol: panel de usuario, perfil, biblioteca digital, agenda y notificaciones.

**`menu_diseno.dart`** — Componentes visuales compartidos entre ambos menús: estilos de cabecera del menú, separadores, tiles de navegación con icono y etiqueta, y el pie de menú con el botón de cerrar sesión.

#### Componentes de formulario

**`custom_text_form_field.dart`** — Campo de texto con el estilo visual unificado de la app: bordes redondeados, color de foco verde primario (`#051906`) y mensajes de error con formato consistente. Sustituye al `TextFormField` estándar de Flutter en todos los formularios de la aplicación.

**`custom_filled_button.dart`** — Botón primario reutilizable con el color de la app, esquinas redondeadas e indicador de carga integrado. Cuando `onPressed` es `null`, el botón se deshabilita automáticamente, lo que se usa para bloquear el envío de formularios mientras se procesa una petición o la validación no es correcta.

#### Filtros avanzados

**`filtro_avanzado_model.dart`** — Modelo de datos que representa un filtro avanzado activo: campo sobre el que filtrar, operador de comparación (contiene, igual a, mayor que, menor que) y valor introducido por el usuario.

**`formulario_filtros.dart`** — Widget interactivo que permite al usuario construir filtros avanzados de forma visual: seleccionar el campo, el operador y el valor, añadir varios filtros encadenados y eliminarlos individualmente. Integrado actualmente en la pantalla de hermanos activos y preparado para usarse en cualquier otro listado.

#### Búsqueda geográfica y documentos

**`calle_search_delegate.dart`** — `SearchDelegate` personalizado para buscar calles de la base de datos de Odoo. Muestra los resultados en tiempo real mientras el usuario escribe y permite seleccionar una calle para autocompletar automáticamente los campos de provincia, localidad y código postal del formulario. Se reutiliza en los formularios de hermanos, organizadores, proveedores, autoridades, cargos y cofradías. Si la calle buscada no existe, ofrece la opción de crearla al vuelo mediante `_dialogoCrearCalleRapido`.

**`disenio_informes.dart`** — Diseño base para todos los documentos PDF generados con la librería `pdf`. Define la cabecera común (logotipo de la cofradía, título del informe, fecha de generación), los estilos de tabla, los colores corporativos y la tipografía. Todos los módulos que generan PDFs usan este diseño para garantizar una apariencia uniforme en todos los documentos exportados.

---

## 8. Gestión de estado

La aplicación utiliza **Riverpod** como sistema de gestión de estado global. Todos los providers se instancian dentro de un `ProviderScope` raíz en `main.dart`.

| Patrón | Cuándo se usa |
|---|---|
| `AsyncNotifierProvider` | Datos asíncronos del servidor con estados loading/data/error automáticos |
| `StateNotifierProvider` | Estado complejo con múltiples operaciones y transiciones manuales |
| `StateProvider` | Estado simple de un único valor (filtro seleccionado, provincia activa...) |
| `Provider` | Instancias únicas compartidas (repositorios, datasources) |
| `FutureProvider` | Datos que se cargan una sola vez al arrancar (catálogos de configuración) |

**Providers derivados:** combinan la salida de otros providers para producir datos ya filtrados o transformados, evitando lógica duplicada en las pantallas. Ejemplos: `hermanosActivosFiltradosProvider` (lista de activos ya filtrada por texto y filtros avanzados), `listaSoloAnunciantes` (proveedores marcados como anunciantes), `usuariosConEmailProvider` (usuarios con notificaciones activas), `listaEventosRecientes` (eventos futuros ordenados cronológicamente).

**Patrón `ref.invalidateSelf()`:** tras cualquier operación de escritura exitosa (crear, editar, eliminar), el notifier invalida su propio estado. Riverpod detecta la invalidación, llama de nuevo al método `build()` y recarga los datos desde el servidor, manteniendo la UI siempre sincronizada sin gestionar manualmente la lista en memoria.

**Autodipose:** los providers de formulario (`loginFormProvider`, `registerFormProvider`) usan `.autoDispose`, de modo que su estado se destruye automáticamente al cerrar la pantalla. Esto evita que los campos queden rellenos con datos de una sesión anterior si el usuario vuelve a la pantalla de login tras cerrar sesión.

---

## 9. Navegación

La navegación está gestionada por **GoRouter** de forma declarativa. Todas las rutas están definidas en un único archivo (`app_router.dart`) y la lógica de acceso se centraliza en la función `redirect`, que se ejecuta automáticamente en cada intento de navegación.

### Niveles de acceso

| Estado | Comportamiento |
|---|---|
| No autenticado | Redirigido a `/login` desde cualquier ruta protegida |
| Invitado (rol 3) | Acceso a `/panel-usuario`, `/calendario`, `/listado-libros` y `/notificaciones-usuario` |
| Usuario estándar | Acceso a su panel personal, perfil, libros, eventos y notificaciones. Sin rutas de administración |
| Administrador | Acceso total. La función `redirect` devuelve `null` sin redirigir |

### Conexión con el sistema de autenticación

`GoRouterNotifier` extiende `ChangeNotifier` y se suscribe a los cambios del `AuthNotifier`. Cada vez que el estado de autenticación cambia (inicio de sesión, cierre de sesión, verificación de sesión al arrancar), llama a `notifyListeners()`, lo que provoca que GoRouter recalcule las redirecciones automáticamente.

### Paso de objetos entre pantallas

Las rutas de edición reciben el objeto completo a editar mediante el campo `extra` de GoRouter, evitando peticiones adicionales al servidor para obtener el detalle. El tipo del objeto se comprueba con `is` antes de usarlo, y si se navega a la ruta sin pasar datos, la pantalla se abre en modo creación.

---

## 10. Identidad visual

El tema visual está centralizado en `app_theme.dart` y se aplica automáticamente a todos los componentes de la app mediante Material Design 3.

| Elemento | Valor |
|---|---|
| Fuente principal | Palatino |
| Color primario oscuro | `#051906` |
| Color primario medio | `#09390C` |
| Fondo splash screen | `#ffffff` |
| Design system | Material Design 3 (`useMaterial3: true`) |

### Componente `MainBackground`

Es la base visual de todas las pantallas de la aplicación. Usa un `Stack` de dos capas:

- **Capa inferior:** rectángulo verde que ocupa el 35% superior de la pantalla con esquinas inferiores redondeadas, creando el efecto de cabecera característica.
- **Capa superior:** contenido real en un `CustomScrollView` con física de rebote. Incluye opcionalmente un título centrado en la zona verde y un icono flotante en círculo blanco con sombra que sobresale sobre la línea divisoria. El cuerpo se muestra en panel blanco con esquinas superiores redondeadas.

Al usar `MainBackground` como base en todas las pantallas en lugar de repetir el diseño en cada una, cualquier cambio en el componente se aplica automáticamente a toda la app.

---

## 11. Dependencias principales

| Paquete | Función |
|---|---|
| `flutter_riverpod` | Gestión de estado reactiva global |
| `go_router` | Navegación declarativa con redirecciones basadas en estado |
| `dio` | Peticiones HTTP a la API de Odoo |
| `flutter_dotenv` | Carga de variables de entorno desde `.env` |
| `formz` | Validación estructurada y tipada de campos de formulario |
| `equatable` | Comparación de objetos para detección de cambios en Riverpod |
| `table_calendar` | Calendario interactivo con marcadores de colores por evento |
| `pdf` + `printing` | Generación e impresión de documentos PDF desde la app |
| `excel` | Exportación de datos tabulares a archivos `.xlsx` |
| `file_picker` | Selección de archivos del dispositivo para adjuntarlos |
| `open_filex` | Apertura de archivos descargados con la app nativa del dispositivo |
| `path_provider` | Acceso a rutas del sistema de archivos (descargas, documentos...) |
| `google_fonts` | Gestión de fuentes tipográficas (Palatino) |
| `flutter_native_splash` | Generación de splash screen nativa para Android, iOS y web |
| `flutter_launcher_icons` | Generación de iconos en todos los tamaños para cada plataforma |
| `flutter_staggered_grid_view` | Cuadrículas con elementos de distintos tamaños en el panel |
| `intl` | Formatos de fechas, números y textos en español |
| `flutter_localizations` | Traducciones de componentes nativos de Flutter al español |
| `shared_preferences` | Persistencia local del token de sesión entre reinicios |
| `image_picker` | Selección de imágenes desde la galería (logos y firmas de organizadores) |

---

## 12. Funcionalidades destacadas

- **Acceso como invitado** sin necesidad de registro, con rol restringido a consulta pública de eventos, calendario y biblioteca.
- **Verificación automática de sesión** al arrancar la app: si hay token guardado, se valida contra Odoo y el usuario entra directamente sin introducir credenciales.
- **Filtros avanzados** en el padrón de hermanos: por cualquier campo, con operadores de comparación (contiene, igual a, mayor que, menor que) y filtrado en tiempo real combinando varios filtros a la vez.
- **Generación automática del código de hermano** al introducir el número de hermano y el sexo, concatenando ambos valores con un listener en tiempo real.
- **Selector de calle con autocompletado en cascada** de provincia, localidad y código postal. Si la calle no existe, se puede crear al vuelo sin salir del formulario.
- **Exportación a Excel y PDF** en todos los módulos de gestión, con logotipo de la cofradía en la cabecera de cada informe.
- **Biblioteca digital multiplataforma**: apertura en nueva pestaña en web y con la app nativa en móvil; descarga directa en ambas plataformas.
- **Vinculación del perfil de usuario con su hermano** de la cofradía mediante búsqueda por DNI, mostrando el número de hermano en el panel de usuario.
- **Notificaciones por correo** enviadas directamente desde la app a todos los hermanos que han aceptado recibirlas, con lista de destinatarios generada automáticamente.
- **Gestión de imágenes en base64**: logos y firmas de los organizadores se seleccionan desde la galería, se codifican y se almacenan directamente en Odoo.
- **Selector visual de color** para los tipos de evento, con paleta de 12 colores predefinidos y previsualización en tiempo real.
- **Panel lateral deslizante** para crear y editar registros sin abandonar el listado, con animación `SlideTransition` desde el lateral derecho.
- **Protección de auto-eliminación** en el módulo de usuarios: el botón de borrar no aparece para el usuario actualmente autenticado.
- **Registro de actividad reciente** en el panel de administración, con formato de tiempo relativo ("Hace X min", "Hace X horas").
- **Notifier genérico parametrizado** en el módulo de secretaría: un único `SecretariaNotifier<T>` gestiona las tres entidades (autoridades, cargos y cofradías) eliminando la duplicación de código.

---

*MorenitApp — Trabajo de Fin de Grado · Ana Gómez Jurado*