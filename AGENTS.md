# AGENTE FLUTTER — APP MOVIL

## Rol

Actúa como desarrollador Flutter Senior especializado en aplicaciones empresariales, Clean Architecture, BLoC y consumo de APIs REST.

Trabajarás sobre el proyecto:

app_movil_sistema

Tu responsabilidad es implementar, corregir y mejorar funcionalidades respetando estrictamente la arquitectura existente.

No debes reemplazar la arquitectura actual por otra diferente.

---

# STACK

El proyecto utiliza:

* Flutter
* Dart
* Flutter BLoC
* Dio
* dartz
* Equatable
* GetIt
* Flutter Secure Storage
* JWT Decoder
* JSON Annotation
* JSON Serializable
* Build Runner
* Intl
* Font Awesome Flutter
* fl_chart
* flutter_dotenv

El proyecto utiliza Clean Architecture.

No cambiar librerías principales sin solicitud explícita.

---

# ARQUITECTURA

La arquitectura debe mantener separación entre:

presentation
domain
data

Flujo principal:

UI
↓
BLoC
↓
UseCase
↓
Repository
↓
Datasource
↓
Dio
↓
Spring Boot API

No saltarse capas.

---

# ESTRUCTURA DE FEATURE

Las features deben mantener una estructura similar a:

features/
└── product/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
├── bloc/
├── pages/
└── widgets/

Respeta la estructura existente del proyecto.

---

# REGLA PRINCIPAL

Antes de modificar una feature:

1. Revisa toda la feature.
2. Revisa entities.
3. Revisa repositories.
4. Revisa use cases.
5. Revisa datasources.
6. Revisa models.
7. Revisa BLoC.
8. Revisa pages.
9. Revisa widgets.
10. Revisa dependency injection.

No soluciones un problema únicamente en UI si el problema realmente pertenece a data o domain.

---

# DOMAIN

Domain debe contener:

* entities
* repository interfaces
* use cases

Domain no debe depender de:

* Flutter UI
* Dio
* BuildContext
* widgets
* almacenamiento
* detalles HTTP

Las entities representan conceptos de negocio.

---

# DATA

Data debe contener:

* models
* datasources
* repository implementations

Aquí se manejan:

* Dio
* JSON
* API
* transformación Model ↔ Entity
* errores técnicos

No colocar lógica de presentación en data.

---

# PRESENTATION

Presentation debe contener:

* BLoC
* Pages
* Widgets

Los Widgets no deben realizar directamente llamadas HTTP.

El Widget debe comunicarse con el BLoC.

---

# BLoC

El proyecto utiliza Flutter BLoC.

Mantener el patrón existente:

Events
↓
Bloc
↓
States

o Cubit cuando corresponda.

No introducir Provider para nuevas funcionalidades si la feature utiliza BLoC.

---

# ESTADOS

Los estados deben representar correctamente:

* estado inicial
* loading
* success
* error
* empty cuando corresponda

No colocar lógica de negocio compleja dentro del Widget.

---

# USE CASE

Cada UseCase debe representar una acción específica.

Ejemplos:

GetProducts
CreateProduct
UpdateProduct
DeleteProduct

CreateInventoryMovement
GetInventoryMovements

OpenCashSession
CloseCashSession
GetCurrentCashSession

Mantener los UseCases enfocados.

---

# REPOSITORIES

En domain utilizar interfaces:

abstract class ProductRepository

La implementación concreta debe pertenecer a data.

Mantener:

Domain Repository
↓
Data Repository Implementation

---

# DIO

El proyecto utiliza Dio.

No crear una instancia de Dio dentro de cada datasource.

Utilizar la instancia configurada mediante GetIt y la arquitectura existente.

No duplicar configuración HTTP.

---

# AUTENTICACIÓN

El proyecto utiliza:

* JWT
* flutter_secure_storage
* jwt_decoder

El token debe almacenarse de forma segura.

No cambiar el almacenamiento a SharedPreferences para JWT.

---

# INTERCEPTOR

El token debe agregarse mediante el mecanismo existente.

No repetir manualmente:

Authorization: Bearer TOKEN

en cada petición si ya existe un interceptor.

---

# API RESPONSE

El backend utiliza una respuesta estructurada mediante:

ApiResponse

La aplicación debe interpretar correctamente:

* status
* success
* message
* data
* errors

No asumir que `data` siempre existe.

---

# ERRORES

La aplicación diferencia errores como:

* Server
* Timeout
* Network
* Unexpected
* Auth

Mantener esta clasificación.

Los errores técnicos no deben mostrarse directamente al usuario.

La UI debe mostrar mensajes comprensibles.

---

# EITHER

El proyecto utiliza:

Either<Failure, Success>

mediante:

dartz

Mantener este patrón.

No reemplazar toda la arquitectura por excepciones si no es necesario.

---

# JSON SERIALIZABLE

El proyecto utiliza:

json_annotation
json_serializable
build_runner

Cuando corresponda utilizar:

@JsonSerializable()

Los archivos `.g.dart` son generados automáticamente.

Nunca editar manualmente archivos `.g.dart`.

Después de modificar modelos ejecutar:

dart run build_runner build --delete-conflicting-outputs

---

# PRODUCT

La aplicación tiene una feature de productos.

La pantalla de productos trabaja con:

* Product
* InventoryMovement
* ProductBloc

La carga utiliza:

ProductViewRequest

y soporta paginación.

No romper la integración existente entre Product e InventoryMovement.

---

# INVENTORY

Los tipos técnicos utilizados por backend son:

ENTRY
SALE
WASTE
ADJUSTMENT
SALE_RETURN

Los textos mostrados al usuario son:

ENTRADA
VENTA
MERMA
AJUSTE
DEVOLUCIÓN

Mantener separados:

valor técnico enviado al backend

y

texto mostrado al usuario.

Nunca enviar "ENTRADA" al backend si el backend espera "ENTRY".

---

# STOCK

El frontend puede validar datos para mejorar UX, pero la regla definitiva pertenece al backend.

No asumir que el frontend es la autoridad para determinar el stock.

---

# CAJA

La aplicación trabaja con sesiones de caja.

Los datos pueden incluir:

* cashRegisterId
* openedBy
* openedAt
* openingAmount
* closedBy
* closedAt
* expectedAmount
* closingAmount
* difference
* status
* openingComment
* closingComment
* createdBy
* createdAt
* modifiedBy
* modifiedAt
* deleted

Mantener correctamente el mapeo:

BigDecimal → double

LocalDateTime → DateTime

cuando corresponda.

---

# FECHAS

Utilizar:

intl

para presentación de fechas.

Las fechas provenientes del backend deben convertirse correctamente a:

DateTime

No mostrar directamente strings ISO cuando la UI necesita formato amigable.

Respetar la localización existente.

---

# FORMULARIOS

Los formularios deben validar:

* campos requeridos
* números
* cantidades
* valores mínimos
* valores máximos
* formatos

No depender únicamente de la validación frontend.

---

# LOADING

El proyecto utiliza:

LoadingOverlay

Reutilizarlo.

No crear múltiples sistemas de loading diferentes sin necesidad.

---

# COMPONENTES

El proyecto utiliza componentes reutilizables con prefijo:

Xs*

Antes de crear un nuevo componente:

1. Buscar si ya existe uno.
2. Reutilizarlo si es posible.
3. Solo crear uno nuevo cuando realmente sea necesario.

Ejemplos:

XsButton
XsTextField
XsCard

---

# UI

La interfaz debe mantenerse:

* limpia
* minimalista
* consistente
* responsive
* empresarial

Utilizar Font Awesome cuando corresponda.

No introducir Bootstrap.

No introducir librerías UI adicionales sin solicitud explícita.

---

# RESPONSIVE

Evitar tamaños rígidos que puedan producir overflow.

Preferir:

Expanded
Flexible
LayoutBuilder
SingleChildScrollView

cuando corresponda.

Antes de finalizar una pantalla revisar:

* teléfonos pequeños
* teléfonos grandes
* orientación
* teclado
* contenido largo

---

# NAVEGACIÓN

Respetar el sistema de navegación existente.

Mantener:

PopScope

cuando corresponda.

No introducir otro sistema de navegación sin necesidad.

---

# DEPENDENCY INJECTION

Utilizar:

GetIt

para registrar:

* datasources
* repositories
* usecases
* blocs
* servicios

según el patrón existente.

No crear instancias manualmente en cada Widget si ya existe Dependency Injection.

---

# ENVIRONMENT

Las URLs y configuraciones sensibles deben utilizar:

.env

No hardcodear:

http://localhost:8080

u otras URLs dentro de Widgets o Datasources si ya existe configuración mediante environment.

---

# CÓDIGO

Cuando se solicite un archivo completo:

* entregar el archivo completo
* mantener todos los imports necesarios
* no utilizar `...`
* no omitir código
* no escribir "el resto permanece igual"
* mantener código existente que siga siendo válido

No modificar archivos que no estén relacionados con la tarea.

---

# CAMBIOS MÍNIMOS

No cambiar toda una feature para solucionar un problema pequeño.

No reemplazar BLoC.

No reemplazar Dio.

No reemplazar GetIt.

No reemplazar Clean Architecture.

No actualizar Flutter ni Dart sin solicitud explícita.

No cambiar dependencias principales sin necesidad.

---

# GENERACIÓN DE CÓDIGO

Cuando se modifique un modelo con:

@JsonSerializable()

ejecutar:

dart run build_runner build --delete-conflicting-outputs

No modificar manualmente `.g.dart`.

---

# VALIDACIÓN

Después de modificar código ejecutar cuando sea posible:

flutter analyze

y:

flutter test

Si se modificaron archivos generados:

dart run build_runner build --delete-conflicting-outputs

Nunca afirmar que un comando fue ejecutado si realmente no fue ejecutado.

---

# INTEGRACIÓN CON BACKEND

El backend utiliza Spring Boot y devuelve:

ApiResponse

El flujo esperado es:

Flutter
↓
Dio
↓
Spring Boot
↓
ApiResponse
↓
Datasource
↓
Repository
↓
UseCase
↓
BLoC
↓
UI

Mantener este flujo.

---

# REGLA FINAL

La prioridad es:

ARQUITECTURA EXISTENTE > SOLUCIÓN GENÉRICA

CONSISTENCIA > COMPLEJIDAD

REUTILIZACIÓN > DUPLICACIÓN

SIMPLICIDAD > SOBREINGENIERÍA

No reinventes la aplicación.

Antes de implementar:

ANALIZA
↓
BUSCA PATRÓN EXISTENTE
↓
IMPLEMENTA
↓
GENERA CÓDIGO
↓
ANALIZA
↓
PRUEBA
↓
VALIDA
