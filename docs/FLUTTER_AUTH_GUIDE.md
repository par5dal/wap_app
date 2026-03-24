# Guía de Autenticación para Flutter — What a Plan (WAP)

> Documento de referencia para el agente de desarrollo de la aplicación Flutter.
> Describe todos los flujos de autenticación, endpoints, estructuras de datos y estrategia de tokens
> usados por el frontend web. **El frontend nunca llama a Supabase directamente**: todo pasa
> por el backend NestJS.

---

## 1. Arquitectura general

```
Flutter App
    │
    │  HTTP requests (Bearer token / cookies)
    ▼
NestJS Backend  ←──────────── API REST (https://api.whataplan.net)
    │
    │  Supabase Auth SDK (server-side)
    ▼
Supabase Auth
```

- **Base URL**: definida en la variable de entorno `NEXT_PUBLIC_API_URL` del frontend (`env.apiUrl`).
- Todas las peticiones llevan cabecera `Content-Type: application/json`.
- Las peticiones autenticadas llevan cabecera `Authorization: Bearer <accessToken>`.
- Además se envían cookies con `withCredentials: true` (cookie `sb_refresh_token` httpOnly gestionada por el backend). En Flutter hay que activar el envío de cookies de sesión si se usa el modo cookie.

---

## 2. Roles de usuario

| Rol        | Descripción                                      |
|------------|--------------------------------------------------|
| `CONSUMER` | Usuario estándar. Puede ver y guardar eventos.   |
| `PROMOTER` | Crea y gestiona eventos. Tiene dashboard propio. |
| `ADMIN`    | Acceso total al panel de administración.         |

---

## 3. Objeto `AuthUser` (usuario en sesión)

```json
{
  "id": "uuid-de-supabase",
  "email": "usuario@ejemplo.com",
  "role": "CONSUMER | PROMOTER | ADMIN",
  "profileComplete": true,
  "firstName": "Juan",
  "lastName": "García",
  "subscriptionStatus": "active | inactive | null",
  "avatarUrl": "https://...",
  "emailVerified": true,
  "authProvider": "email | google | apple"
}
```

Este objeto viene en el cuerpo de la respuesta de login/register (campo `user`).
También puede reconstruirse descodificando el JWT (ver sección 8).

---

## 4. Estrategia de tokens

| Token          | Duración | Almacenamiento web          | Almacenamiento Flutter recomendado   |
|----------------|----------|-----------------------------|--------------------------------------|
| `accessToken`  | 1 hora   | Memoria (Zustand, no persiste) | `flutter_secure_storage` o memoria  |
| `refreshToken` | 7 días   | `sessionStorage`            | `flutter_secure_storage`             |

- El backend también setea una cookie httpOnly `sb_refresh_token`. En Flutter es más simple trabajar con los tokens del body y no depender de cookies.
- Cuando el `accessToken` expira, se usa el `refreshToken` para obtener uno nuevo (ver sección 9).

---

## 5. Cabeceras en peticiones autenticadas

```
Authorization: Bearer <accessToken>
Content-Type: application/json
Accept-Language: es   (o en, pt — idioma del usuario)
x-lang: es
```

---

## 6. Flujos de autenticación

### 6.1 Registro con email y contraseña

**Endpoint:** `POST /auth/register`

**Request body:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123",
  "role": "CONSUMER"
}
```
> `role` puede ser `"CONSUMER"` (por defecto) o `"PROMOTER"` si se registra como promotor.

**Response 201:**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "uuid",
    "email": "usuario@ejemplo.com",
    "role": "CONSUMER",
    "profileComplete": false,
    "firstName": null,
    "lastName": null,
    "subscriptionStatus": null,
    "avatarUrl": null,
    "emailVerified": false,
    "authProvider": "email"
  }
}
```

**Paso adicional — crear perfil (opcional pero recomendado):**

Inmediatamente después del registro, el frontend llama a:

`POST /users/profile`  *(requiere `Authorization: Bearer <accessToken>`)*

```json
{
  "first_name": "Juan",
  "last_name": "García"
}
```

> Si este paso falla el usuario ya existe; se puede reintentar más tarde desde el perfil.

**Errores frecuentes:**
- `409 Conflict` → El email ya está registrado.
- `400 Bad Request` → Validación fallida (array de mensajes en `message`).

**Límite de peticiones:** 3 intentos por hora por dispositivo.

---

### 6.2 Login con email y contraseña

**Endpoint:** `POST /auth/login`

**Request body:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}
```

**Response 200:**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "uuid",
    "email": "usuario@ejemplo.com",
    "role": "CONSUMER | PROMOTER | ADMIN",
    "profileComplete": true,
    "firstName": "Juan",
    "lastName": "García",
    "subscriptionStatus": "active",
    "avatarUrl": "https://...",
    "emailVerified": true,
    "authProvider": "email"
  }
}
```

**Errores frecuentes:**
- `401 Unauthorized` → Credenciales incorrectas.
- `400 Bad Request` → Email inválido o contraseña demasiado corta (< 8 caracteres).

**Redirección post-login (referencia para Flutter):**
- `role === "ADMIN"` → pantalla de admin
- cualquier otro rol → dashboard/home

**Límite de peticiones:** 5 intentos por minuto, bloqueo de 5 minutos.

---

### 6.3 OAuth con Google — flujo completo

**Paso 1 — Obtener URL de autorización:**

`GET /auth/google/login?lang=es&role=CONSUMER`

| Query param | Descripción                             |
|-------------|-----------------------------------------|
| `lang`      | Idioma (`es`, `en`, `pt`)               |
| `role`      | Rol inicial si es nuevo usuario (`CONSUMER` o `PROMOTER`) |

**Response:**
```json
{
  "url": "https://accounts.google.com/o/oauth2/auth?..."
}
```

**Paso 2 — Redirigir al usuario:**

Abrir `data.url` en un navegador/webview. El usuario se autentica con Google. Supabase lo redirige a la URL de callback configurada en el backend con los tokens en el **fragment** de la URL:

```
https://app.whataplan.net/auth/callback#access_token=XXX&refresh_token=YYY&type=...
```

**Paso 3 — Extraer tokens del fragment y llamar al backend:**

`POST /auth/google/callback`

```json
{
  "accessToken": "token-de-supabase-extraido-del-hash",
  "refreshToken": "refresh-token-del-hash",
  "lang": "es",
  "role": "CONSUMER"
}
```

> `role` es opcional; solo se usa si el usuario es nuevo.

**Response 200:**
```json
{
  "accessToken": "eyJ... (token WAP, puede ser distinto al de Supabase)",
  "refreshToken": "eyJ...",
  "isNewUser": false,
  "user": { "id": "...", "email": "...", "role": "CONSUMER", ... }
}
```

> `isNewUser: true` si acaba de crearse la cuenta → mostrar pantalla de bienvenida.

> El backend aplica **upsert**: si el usuario ya existe hace login; si no existe lo crea con el `role` indicado.

---

### 6.4 OAuth con Apple — flujo idéntico al de Google

Mismos pasos, cambiando `google` por `apple` en los endpoints:

- `GET /auth/apple/login?lang=es&role=CONSUMER`
- `POST /auth/apple/callback` (mismo body y response que Google)

> Apple solo funciona en HTTPS (no en localhost sin tunnel).

---

### 6.5 Logout

**Endpoint:** `POST /auth/logout`  *(requiere `Authorization: Bearer <accessToken>`)*

**Request body:** vacío `{}`

**Response 200:** `{}` *(o simplemente 2xx)*

**Acciones locales tras logout:**
- Eliminar `accessToken` de memoria.
- Eliminar `refreshToken` del almacenamiento seguro.
- Limpiar el objeto de usuario en sesión (equivalente al store).
- Limpiar caché de queries (React Query / equivalente en Flutter).
- Navegar a la pantalla de login.

---

### 6.6 Renovación del access token (refresh)

El interceptor de Axios del frontend en web detecta respuestas `401` y llama automáticamente a:

**Endpoint:** `POST /auth/refresh`

**Request body:**
```json
{
  "refreshToken": "el-refresh-token-almacenado"
}
```

La cookie `sb_refresh_token` también se envía automáticamente si está configurada.

**Response 200:**
```json
{
  "accessToken": "eyJ... (nuevo token, válido 1h)",
  "refreshToken": "eyJ... (nuevo refresh token, válido 7d)"
}
```

**Lógica de circuit breaker (implementar en Flutter):**
1. En cada petición, si hay `accessToken`, añadir cabecera `Authorization: Bearer <token>`.
2. Si la respuesta es `401` y la petición no es una ruta de auth:
   - Si no hay `refreshToken` → no intentar refresh, redirigir a login.
   - Si ya se está haciendo un refresh → encolar la petición y esperar.
   - Si el refresh falla definitivamente → marcar "refresh permanentemente fallido", hacer logout, redirigir a login.
3. Una vez el refresh funciona, reintentar todas las peticiones en cola con el nuevo token.
4. El circuit breaker se resetea cuando el usuario vuelve a hacer login (nuevo `accessToken`).

**Rutas que NO deben disparar el interceptor de refresh si devuelven 401:**
- `/auth/login`
- `/auth/register`
- `/auth/refresh`
- `/auth/google/login`
- `/auth/google/callback`
- `/auth/password/reset-request`
- `/auth/password/reset`

**Rutas públicas que tampoco deben forzar refresh ni logout ante 401:**
Patrones: `/events/tiles/`, `/events/promoter/`, `/events/`, `/promoters/`, `/categories`, `/venues`

---

### 6.7 Recuperación de contraseña (forgot password)

**Paso 1 — Solicitar email de reset:**

**Endpoint:** `POST /auth/password/reset-request`

```json
{
  "email": "usuario@ejemplo.com"
}
```

**Response:** `200 OK` — El backend envía un email con un enlace mágico de Supabase.
El enlace expira en **1 hora**.

---

**Paso 2 — Establecer nueva contraseña:**

El usuario llega a la app desde el enlace del email. La URL tiene el token en el **fragment**:
```
https://app.whataplan.net/auth/reset-password#access_token=XXX&type=recovery
```

En Flutter: usar un deep link / universal link para capturar esta URL y extraer `access_token` del fragment. Verificar que `type === "recovery"`.

**Endpoint:** `POST /auth/password/reset`

```json
{
  "token": "access_token_extraido_del_hash",
  "newPassword": "nuevaContraseña123"
}
```

**Response:** `200 OK` — Redirigir a login.

**Errores:**
- `400` → Token expirado o inválido; pedir al usuario que solicite un nuevo enlace.

---

### 6.8 Verificación de email

Cuando el usuario se registra, Supabase envía un email de verificación con un enlace que contiene un `token` como query parameter:

```
https://app.whataplan.net/auth/verify-email?token=XXXXX
```

**Endpoint:** `GET /auth/verify-email/:token`

*(No hay body; el token va en la URL path.)*

**Response:** `200 OK` — Email verificado. Redirigir al home si está autenticado, o a login si no lo está.

**Errores:**
- `400/404` → Token inválido o ya utilizado.

**Reenviar email de verificación:**

**Endpoint:** `POST /auth/resend-verification`  *(requiere autenticación)*

Request body: vacío `{}`.

**Response:** `200 OK`.

---

### 6.9 Upgrade de CONSUMER a PROMOTER

**Endpoint:** `POST /users/me/upgrade-to-promoter`  *(requiere `Authorization: Bearer <accessToken>`)*

Request body: depende del plan de suscripción elegido (vacío o con payload de pago).

**Response 200:**
```json
{
  "accessToken": "eyJ... (nuevo token con role=PROMOTER, puede no venir)",
  "refreshToken": "...",
  "user": {
    "role": "PROMOTER",
    "subscriptionStatus": "active"
  }
}
```

Si `accessToken` está en la respuesta → reemplazar tokens almacenados.
Si no viene → actualizar localmente solo `role` y `subscriptionStatus` del usuario en sesión.

---

## 7. Estructura del JWT

El `accessToken` es un JWT emitido por Supabase con la siguiente estructura relevante:

```json
{
  "sub": "uuid-del-usuario",
  "email": "usuario@ejemplo.com",
  "role": "authenticated",
  "user_metadata": {
    "role": "CONSUMER | PROMOTER | ADMIN"
  },
  "app_metadata": {
    "role": "CONSUMER | PROMOTER | ADMIN"
  },
  "exp": 1234567890,
  "iat": 1234567890
}
```

> ⚠️ **IMPORTANTE**: El campo `payload.role = "authenticated"` es interno de Supabase y debe ignorarse.
> El **rol real de la aplicación** está en `payload.user_metadata.role` (o `payload.app_metadata.role`).

En Flutter se puede usar el paquete `dart_jsonwebtoken` o decodificar manualmente en base64 para extraer el rol del JWT cuando el backend no devuelva el objeto `user` completo.

---

## 8. Rutas protegidas (referencia para Flutter)

El middleware del frontend es solo de i18n (prefijo de idioma). La protección de rutas se hace en el cliente verificando si hay sesión activa. En Flutter:

| Pantalla / sección        | Requiere autenticación | Rol mínimo  |
|---------------------------|------------------------|-------------|
| Home, listado de eventos  | No                     | —           |
| Detalle de evento         | No (parcialmente)      | —           |
| Favoritos                 | Sí                     | CONSUMER    |
| Dashboard                 | Sí                     | CONSUMER    |
| Crear/editar eventos      | Sí                     | PROMOTER    |
| Panel de admin            | Sí                     | ADMIN       |
| Upgrade a promotor        | Sí                     | CONSUMER    |

---

## 9. Resumen de endpoints de autenticación

| Método | Endpoint                          | Auth requerida | Descripción                            |
|--------|-----------------------------------|----------------|----------------------------------------|
| POST   | `/auth/register`                  | No             | Registro con email/contraseña          |
| POST   | `/auth/login`                     | No             | Login con email/contraseña             |
| POST   | `/auth/logout`                    | Sí             | Cierre de sesión                       |
| POST   | `/auth/refresh`                   | No*            | Renovar access token con refresh token |
| GET    | `/auth/google/login`              | No             | Obtener URL OAuth de Google            |
| POST   | `/auth/google/callback`           | No             | Completar login con Google             |
| GET    | `/auth/apple/login`               | No             | Obtener URL OAuth de Apple             |
| POST   | `/auth/apple/callback`            | No             | Completar login con Apple              |
| POST   | `/auth/password/reset-request`    | No             | Solicitar email de recuperación        |
| POST   | `/auth/password/reset`            | No             | Establecer nueva contraseña            |
| GET    | `/auth/verify-email/:token`       | No             | Verificar email con token              |
| POST   | `/auth/resend-verification`       | Sí             | Reenviar email de verificación         |
| POST   | `/users/profile`                  | Sí             | Crear perfil tras registro             |
| POST   | `/users/me/upgrade-to-promoter`   | Sí (CONSUMER)  | Promover usuario a PROMOTER            |

*`/auth/refresh` no lleva Bearer pero sí puede llevar cookie `sb_refresh_token`.

---

## 10. Diagrama de flujo — Login email/contraseña

```
Usuario introduce email + password
        │
        ▼
POST /auth/login
        │
   ┌────┴────┐
   │ Error   │ → mostrar mensaje de error
   └────┬────┘
        │ 200 OK
        ▼
Guardar accessToken en memoria
Guardar refreshToken en almacenamiento seguro
Guardar objeto user en sesión
        │
        ▼
   ¿role === ADMIN?
   ┌────┴────┐
  Sí        No
   │         │
   ▼         ▼
Admin    Dashboard/Home
```

---

## 11. Diagrama de flujo — OAuth (Google / Apple)

```
Usuario pulsa "Continuar con Google/Apple"
        │
        ▼
GET /auth/google/login?lang=es&role=CONSUMER
        │
        ▼
Abrir data.url en webview / navegador
        │
        ▼
Usuario se autentica con Google
        │
        ▼
Supabase redirige a deep link:
  /auth/callback#access_token=X&refresh_token=Y
        │
        ▼
Extraer tokens del fragment
        │
        ▼
POST /auth/google/callback { accessToken, refreshToken, lang, role? }
        │
   ┌────┴────┐
   │ Error   │ → mostrar error, ir a login
   └────┬────┘
        │ 200 OK
        ▼
Guardar tokens y user
        │
        ▼
   ¿isNewUser?
   ┌────┴────┐
  Sí        No
   │         │
   ▼         ▼
Bienvenida  "¡Hola de nuevo!"
        │
        ▼
Admin o Dashboard según role
```

---

## 12. Notas importantes para Flutter

1. **Nunca llamar a Supabase directamente** — toda la auth pasa por el backend NestJS.
2. **Almacenamiento seguro**: usar `flutter_secure_storage` para `refreshToken`.
3. **AccessToken solo en memoria**: no persiste el `accessToken` en disco; al relanzar la app, usar el `refreshToken` para obtener uno nuevo.
4. **Deep links / Universal Links**: configurar para capturar `#access_token=...` en los flujos de OAuth, forgot-password y verify-email.
5. **Interceptor de refresh**: implementar un interceptor HTTP (Dio interceptor) equivalente al de Axios descrito en la sección 6.6.
6. **Rate limiting en cliente**: el frontend aplica rate limiting local (5 intentos login/min, 3 intentos registro/hora). Replicar este comportamiento es opcional pero recomendado en Flutter.
7. **Cabeceras de idioma**: siempre enviar `Accept-Language` y `x-lang` con el idioma del usuario (`es`, `en`, `pt`).
8. **`profileComplete: false`**: si el usuario recién registrado tiene `profileComplete: false`, redirigir a la pantalla de completar perfil.
9. **Cookie mode vs Bearer mode**: el backend soporta ambos. Para Flutter, usar **exclusivamente Bearer token** en `Authorization` header; ignorar la cookie `sb_refresh_token`.
