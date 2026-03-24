# Apple Guideline 1.2 — Guía de integración para frontends

Este documento describe los cambios que deben implementar los clientes (app móvil y web) para cumplir con los requisitos del Apple App Store Guideline 1.2: **EULA/Términos, reportes de contenido, bloqueo de usuarios y suspensión de cuentas**.

---

## Índice

1. [R1 — Aceptación de Términos y Condiciones (EULA)](#r1--aceptación-de-términos-y-condiciones-eula)
2. [R3 — Reportes de contenido](#r3--reportes-de-contenido)
3. [R4 — Bloqueo de usuarios](#r4--bloqueo-de-usuarios)
4. [R5 — Suspensión de cuentas](#r5--suspensión-de-cuentas)
5. [Tabla resumen de errores](#tabla-resumen-de-errores)

---

## R1 — Aceptación de Términos y Condiciones (EULA)

### ¿Qué ha cambiado?

A partir de ahora, **todos los usuarios deben aceptar los términos y condiciones** antes de poder usar la aplicación. Si un usuario autenticado aún no los ha aceptado, **cualquier llamada a la API (excepto `/auth/accept-terms`) devolverá un error `403`** con el código `TERMS_NOT_ACCEPTED`.

### Flujo de registro de un nuevo usuario

1. El usuario completa el registro (`POST /auth/register`) — esto no cambia.
2. Tras recibir los tokens, **antes de navegar al home**, mostrar la pantalla de términos y condiciones.
3. El usuario lee y pulsa "Acepto" → llamar a `POST /auth/accept-terms` con la versión actual de los términos.
4. Una vez confirmado el `200 OK`, navegar normalmente a la aplicación.

### Flujo de login de un usuario existente

Al recibir la respuesta del login, comprobar si el usuario ya tiene términos aceptados. Si no los tiene:

1. Interceptar el error `403 TERMS_NOT_ACCEPTED` en el cliente (o comprobarlo proactivamente).
2. Mostrar la pantalla de EULA.
3. Llamar a `POST /auth/accept-terms` y continuar.

> **Nota:** Los usuarios registrados antes de este cambio no tendrán `terms_accepted_at`, por lo que verán esta pantalla en su primer login tras la actualización de la app.

### Endpoint

**`POST /auth/accept-terms`**

- Autenticación requerida (Bearer token / cookie).
- Body:
  ```
  {
    "version": "1.0"
  }
  ```
  La versión identifica la edición de los términos que el usuario ha leído. Usar `"1.0"` para la versión inicial. Si en el futuro se actualicen los términos, se incrementará (ej. `"1.1"`, `"2.0"`).
- Respuesta exitosa `200`: `{ "ok": true }`

### Cuándo volver a pedir aceptación (versionado de T&C)

El backend gestiona la versión requerida en el servidor. Cuando los T&C cambian:

1. El servidor incrementa `REQUIRED_TERMS_VERSION` (p.ej. `"1.0"` → `"1.1"`).
2. Automáticamente, **todos los usuarios con la versión anterior recibirán `403 TERMS_NOT_ACCEPTED`** en la próxima petición autenticada. La respuesta incluye la versión requerida:
   ```json
   {
     "statusCode": 403,
     "message": {
       "code": "TERMS_NOT_ACCEPTED",
       "message": "You must accept the terms and conditions before proceeding",
       "requiredVersion": "1.1"
     }
   }
   ```
3. El cliente muestra la pantalla EULA con el contenido de la nueva versión y llama a `POST /auth/accept-terms` con la versión indicada en `requiredVersion`.

**Endpoint adicional para pre-cargar la versión requerida** (útil en pantalla de EULA o al iniciar la app):

`GET /auth/terms-info` — público, no requiere autenticación.
- Respuesta `200`: `{ "requiredVersion": "1.0" }`
- Usar esto para saber qué versión de los T&C mostrar al usuario y qué valor enviar en `POST /auth/accept-terms`.

> El contenido de los T&C vive en el cliente (múltiples idiomas). El servidor solo guarda la **versión requerida** como token de comparación.

---

## R3 — Reportes de contenido

### ¿Qué ha cambiado?

Los usuarios pueden reportar **eventos** o **perfiles de otros usuarios** que consideren inapropiados. Esto es un requisito de Apple para que la app disponga de mecanismos de moderación.

### ¿Dónde mostrar la opción de reportar?

- En la pantalla de detalle de un **evento**: menú contextual (⋮ o similar) → "Reportar evento".
- En el **perfil de otro usuario**: menú contextual → "Reportar usuario".
- El usuario que reporta nunca debe poder reportarse a sí mismo (validarlo en el cliente para mejor UX).

### Flujo

1. El usuario selecciona "Reportar".
2. Mostrar un selector de motivo:
   - `SPAM` — Es publicidad o spam
   - `INAPPROPRIATE` — Contenido inapropiado u ofensivo
   - `MISLEADING` — Información falsa o engañosa
   - `HARASSMENT` — Acoso o comportamiento abusivo
   - `OTHER` — Otro motivo
3. Opcionalmente, mostrar un campo de texto libre para descripción adicional (máx. 500 caracteres).
4. Enviar el reporte.
5. Mostrar un mensaje de confirmación ("Tu reporte ha sido enviado y será revisado por nuestro equipo").

> Si el usuario ya tiene un reporte pendiente sobre el mismo contenido, la API devolverá `400`. En ese caso mostrar: "Ya has reportado este contenido anteriormente".

### Endpoint

**`POST /reports`**

- Autenticación requerida.
- Body: se debe incluir **uno** de los dos campos objetivo, no ambos ni ninguno:
  ```
  {
    "reported_event_id": "uuid-del-evento",   // O este
    "reported_user_id": "uuid-del-usuario",    // O este
    "reason": "SPAM",
    "description": "Texto libre opcional"
  }
  ```
- Respuesta exitosa `201`: objeto con el reporte creado.

---

## R4 — Bloqueo de usuarios

### ¿Qué ha cambiado?

Los usuarios pueden **bloquear a otros usuarios** para impedir interacciones. Apple exige que la app ofrezca esta funcionalidad.

### ¿Dónde mostrar la opción de bloquear?

- En el **perfil de otro usuario**: menú contextual → "Bloquear usuario".
- También puede mostrarse junto a la opción de reportar.

### Comportamiento esperado en el cliente

- Al bloquear a alguien, ese usuario **desaparece automáticamente del feed, búsquedas y listados** de eventos — el backend filtra en todos los endpoints de feed y búsqueda de eventos.
- **Excepción: tiles del mapa.** Para no invalidar el caché global de Redis (que mejoraría el rendimiento del mapa), las tiles no se filtran en el backend. El cliente debe:
  1. Cargar `GET /users/me/blocked` al iniciar sesión para obtener la lista de IDs bloqueados.
  2. Al renderizar marcadores en el mapa, filtrar en cliente los que pertenezcan a IDs bloqueados.
- Al desbloquear, actualizar la lista local y el mapa se actualizará en la siguiente carga de tile (TTL 5-15 min o al refrescar).

### Endpoints

**Obtener lista de bloqueados** — llamar al iniciar sesión para sincronizar estado local:

`GET /users/me/blocked`
- Autenticación requerida.
- Respuesta: `{ "blockedIds": ["uuid1", "uuid2", ...] }`

**Bloquear usuario:**

`POST /users/:id/block`
- Autenticación requerida. `:id` = UUID del usuario a bloquear.
- Es idempotente: si ya estaba bloqueado, devuelve `200` igualmente.
- Respuesta `200`: `{ "ok": true }`

**Desbloquear usuario:**

`DELETE /users/:id/block`
- Autenticación requerida. `:id` = UUID del usuario a desbloquear.
- Respuesta `200`: `{ "ok": true }`

---

## R5 — Suspensión de cuentas

### ¿Qué ha cambiado?

Los administradores pueden **suspender cuentas de usuario**. Un usuario suspendido recibe un error `403` con el código `ACCOUNT_SUSPENDED` en cualquier llamada autenticada.

### Flujo en el cliente

El cliente debe ser capaz de interceptar el error `403 ACCOUNT_SUSPENDED` y mostrar una pantalla o mensaje apropiado:

- Título: "Tu cuenta ha sido suspendida"
- Texto: explicar que pueden ponerse en contacto con soporte si creen que es un error.
- **No reintentar** la petición. Forzar cierre de sesión o pantalla de bloqueo.

La respuesta del servidor incluye:
```json
{
  "statusCode": 403,
  "message": {
    "code": "ACCOUNT_SUSPENDED",
    "message": "Your account has been suspended",
    "reason": "Motivo de la suspensión (si aplica)"
  }
}
```

Se puede mostrar el `reason` al usuario si está disponible.

### Cuándo puede ocurrir este error

- Al llamar a **cualquier endpoint autenticado** si la cuenta está suspendida.
- La comprobación ocurre en el guard de autenticación, antes de llegar al controlador.

> Los endpoints de admin para suspender/unsuspend (`POST /admin/users/:id/suspend` y `POST /admin/users/:id/unsuspend`) sólo son accesibles por usuarios con rol `ADMIN`.

### Efecto en el feed de eventos

When a promoter is suspended, **sus eventos desaparecen automáticamente del feed, búsquedas, listado por categoría y página del promotor**. En el mapa (tiles), los eventos desaparecerán una vez expire el caché del tile afectado (TTL de 5 a 15 minutos según el nivel de zoom). No se requiere ninguna acción extra en el cliente.

---

## Tabla resumen de errores

| Código HTTP | `code` en body | Cuándo ocurre | Acción en el cliente |
|---|---|---|---|
| `403` | `TERMS_NOT_ACCEPTED` | Usuario autenticado que no ha aceptado los términos | Mostrar pantalla EULA → llamar `/auth/accept-terms` |
| `403` | `ACCOUNT_SUSPENDED` | Cuenta suspendida por un admin | Mostrar pantalla de suspensión, cerrar sesión |
| `400` | — | Reporte duplicado pendiente | "Ya reportaste este contenido" |
| `409` | — | Intentar bloquearse a sí mismo | Validar en cliente antes de llamar |

---

## Checklist de implementación

### App móvil (Flutter/React Native)

- [ ] Interceptor global de respuestas HTTP que detecte `403 TERMS_NOT_ACCEPTED` y redirija a pantalla de EULA
- [ ] Interceptor global que detecte `403 ACCOUNT_SUSPENDED` y muestre pantalla de suspensión
- [ ] Pantalla de EULA: llamar `GET /auth/terms-info` para obtener la versión requerida; mostrar contenido correspondiente; al aceptar llamar `POST /auth/accept-terms` con esa versión
- [ ] Llamar a `POST /auth/accept-terms` justo después del registro, antes de navegar al home
- [ ] Botón "Reportar" en detalle de evento y perfil de usuario
- [ ] Selector de motivo para reportes + campo descripción opcional
- [ ] Cargar `GET /users/me/blocked` al iniciar sesión y guardar en estado/store local
- [ ] Interfaz para bloquear/desbloquear usuarios desde su perfil
- [ ] Filtrar marcadores del **mapa** por IDs bloqueados en el cliente (el feed y búsquedas ya los filtra el backend)

### Web (Next.js)

- [ ] Middleware o wrapper de fetch que detecte `403 TERMS_NOT_ACCEPTED` y muestre modal/página de EULA
- [ ] Middleware que detecte `403 ACCOUNT_SUSPENDED` y redirija a página de suspensión
- [ ] Página/modal de EULA: llamar `GET /auth/terms-info` para la versión requerida; al aceptar llamar `POST /auth/accept-terms` con esa versión
- [ ] Opción de reportar contenido desde la UI (eventos y perfiles)
- [ ] Gestión de bloqueos (cargar lista, bloquear/desbloquear desde perfil de usuario)
- [ ] Filtrar marcadores del **mapa** por IDs bloqueados en el cliente (el feed y búsquedas ya los filtra el backend)
