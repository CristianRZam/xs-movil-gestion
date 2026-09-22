# Autorización móvil

La política global está en `lib/core/authorization/access_control.dart` y se registra en GetIt. Se alimenta de `roles`, `permissions`, `active` y `exp` del JWT existente, conservado en Flutter Secure Storage. La sesión se restaura al arrancar y se actualiza al guardar/eliminar el token. La expiración revoca el acceso y notifica a las rutas.

| Función | SUPER_ADMIN | Otros roles no vacíos |
| --- | --- | --- |
| Consultar productos y movimientos | Sí | Sí |
| Crear, editar y eliminar productos | Sí | No |
| Entradas, mermas y ajustes manuales | Sí | No |
| Operar órdenes, cambiar estado y cancelar | Sí | Sí |
| Eliminar órdenes | Sí | No |
| Ventas y apertura/cierre de caja | Sí | Sí |
| Conteo de inventario | Sí | No |
| Reportes y dashboard global del negocio | Sí | No |
| Dashboard personal del día | Resumen global | Solo operaciones propias |
| Perfil | Sí | Sí |

Un token ausente, inválido, vencido, inactivo o sin roles no concede capacidades. `SUPER_ADMIN` debe coincidir exactamente con un elemento de `roles`; tener el rol `ADMIN` no equivale a superadministrador.

## Uso

- `getIt<AccessControl>().allows(AppCapability.manageInventory)` comprueba una acción al ejecutarla.
- `AccessVisibility(capability: ..., child: ...)` oculta un componente y reacciona a cambios de sesión.
- `AccessGuard(capability: ..., builder: ...)` protege rutas antes de construir pantallas o cargar datos.
- `ApiAccessPolicy` aplica las mismas capacidades en el interceptor Dio, incluso si una acción se dispara sin su botón. Al añadir endpoints se debe revisar este mapa. `POST /product/init` es una consulta y permanece disponible.

## Permisos futuros

Actualmente `AuthorizationMode.roles` ignora los permisos para conceder acceso. Para activar permisos, configurar `AuthorizationMode.permissions` y `permissionRequirements` con los códigos reales del backend por capacidad. Se exigirán todos los códigos configurados; las capacidades sin mapeo serán denegadas. `SUPER_ADMIN` conserva acceso completo. Se pueden dividir las capacidades operativas en acciones más específicas cuando se defina esa matriz.

La web ya lee `permissions` del JWT: su guard exige todos los permisos de ruta y su directiva acepta cualquiera de los permisos de una lista. La app usa capacidades comunes para mantener coherencia entre rutas, botones y solicitudes.

## Dashboard personal

`GET /api/dashboard` selecciona el alcance en el backend: `GLOBAL` para `ROLE_SUPER_ADMIN` y `PERSONAL` para los demás roles activos. El cliente no envía usuario, fecha ni alcance. La respuesta personal contiene `summaryDate`, `todaySales`, `todaySalesCount`, `averageSale`, `todayOrders`, `topProducts` y `paymentMethods`; `weeklySales` queda vacío porque este resumen solo cubre el día.

Las ventas se atribuyen a `sales.created_by`, es decir, a quien registró el cobro, aunque otra persona haya creado la orden. Solo se incluyen ventas `COMPLETED` no eliminadas. Las órdenes se atribuyen a `orders.created_by` y se cuentan en cualquier estado, excluyendo las eliminadas. Los productos y medios de pago se filtran por las mismas ventas propias del día.

El período es desde las 00:00 inclusive hasta las 00:00 del día siguiente, según la hora local del servidor, coherente con el `LocalDateTime.now()` existente al registrar ventas. La pantalla muestra la fecha enviada por el backend. No requiere migración de tablas.

El interceptor permite consultar este endpoint a usuarios operativos; `AppCapability.dashboard` sigue reservando la visualización global para `SUPER_ADMIN`. Flutter rechaza respuestas sin `scope` y no muestra un resumen global a un usuario operativo. Por ello debe actualizarse el backend antes de usar esta versión móvil.

Las comprobaciones de widgets e interceptor controlan el cliente; la API valida la firma del JWT y decide el alcance del dashboard usando la sesión autenticada. La web no se modificó.

Validación: `flutter analyze --no-pub` y `flutter test --no-pub`.
