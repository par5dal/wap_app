# Guía de migración UUID para Frontends

> **Versión del backend:** migración int4 → UUID completada  
> **Fecha:** Marzo 2026  
> **Impacto:** BREAKING CHANGE — todos los IDs de entidades cambian de número entero a UUID string

---

## ¿Qué ha cambiado?

Todos los identificadores de entidades propias del sistema (eventos, usuarios, categorías, venues, productos, suscripciones, notificaciones, promotores) han pasado de ser **números enteros** (`1`, `42`, `189`) a **strings con formato UUID v4** (`"550e8400-e29b-41d4-a716-446655440001"`).

Los IDs externos de Stripe (`cus_xxx`, `sub_xxx`, `prod_xxx`, `price_xxx`) **no cambian**.

---

## 1. Parámetros de ruta (`:id`)

Cualquier endpoint que acepte un `:id` en la URL ahora **exige formato UUID**. Enviar un número entero devolverá `400 Bad Request` automáticamente.

### Endpoints afectados

| Módulo | Rutas con `:id` |
|---|---|
| **Eventos** | `GET /events/:id` · `PATCH /events/:id` · `DELETE /events/:id` · `PATCH /events/:id/submit-review` · `PATCH /events/:id/unpublish` · `PATCH /events/:id/status` · `POST /events/:id/favorite` · `DELETE /events/:id/favorite` · `GET /events/:id/stats` · `POST /events/:id/view` · `POST /events/:id/share` |
| **Eventos (público)** | `GET /events/public/:id` |
| **Promotores** | `GET /promoters/:id` · `POST /promoters/:id/follow` · `DELETE /promoters/:id/follow` · `GET /promoters/:id/followers` · `GET /promoters/:id/follower-stats` |
| **Eventos por promotor** | `GET /events/promoter/:promoterId` |
| **Categorías** | `GET /categories/:id` · `PATCH /categories/:id` · `DELETE /categories/:id` · `PATCH /categories/:id/deactivate` · `PATCH /categories/:id/activate` |
| **Notificaciones** | `PATCH /notifications/:id/read` · `DELETE /notifications/:id` |
| **Productos** | `GET /products/:id` · `PATCH /products/:id` · `DELETE /products/:id` |
| **Venues** | `DELETE /venues/:id` |
| **Usuarios** | `GET /users/public/:id` · `PATCH /users/:id` · `DELETE /users/:id` |
| **Admin** | `PATCH /admin/events/:id/approve` · `PATCH /admin/events/:id/reject` · `GET /admin/users/:userId/events` |

### Qué hacer

- Actualizar todas las construcciones de URL que concatenen un ID: antes `"/events/" + eventId` (donde `eventId` era `42`), ahora `"/events/" + eventId` (donde `eventId` es `"550e8400-e29b-41d4-a716-446655440001"`).
- **Nunca** hardcodear un ID numérico en una URL de API.
- El backend responde `400 Bad Request` con el mensaje `"Validation failed (uuid is expected)"` si el formato no es UUID válido.

---

## 2. Query parameters con IDs

Los parámetros de filtrado que referenciaban IDs de entidades también cambian a UUID string.

| Parámetro | Endpoint | Antes | Ahora |
|---|---|---|---|
| `category_id` | `GET /events/search` | `?category_id=1` | `?category_id=550e8400-e29b-41d4-a716-446655440001` |
| `category_id` | `GET /events/clustering/map-points` | `?category_id=1` | `?category_id=<uuid>` |
| `category_id` | `GET /events/clustering/grid` | `?category_id=1` | `?category_id=<uuid>` |
| `category_id` | `GET /events/tiles/:z/:x/:y` | `?category_id=1` | `?category_id=<uuid>` |

El resto de query parameters (`page`, `limit`, `lat`, `lon`, `radius`, `min_price`, `max_price`, `start_date`, `end_date`, `search`, `sort`, `zoomLevel`) **no cambian**.

---

## 3. Cuerpos de petición (request body)

### Crear / actualizar evento

El campo `category_ids` pasa de array de números a **array de UUID strings**.

```
Antes: { "category_ids": [1, 3] }
Ahora: { "category_ids": ["550e8400-e29b-41d4-a716-446655440001", "550e8400-e29b-41d4-a716-446655440003"] }
```

- El backend valida que cada elemento sea un UUID válido. Enviar números enteros en este array devolverá `400 Bad Request`.
- Aplica tanto a `POST /events` (CreateEventDto) como a `PATCH /events/:id` (UpdateEventDto).

### Resto de bodies

No hay otros campos de ID en bodies de petición que el frontend envíe directamente. Los demás campos de las entidades (título, descripción, fechas, precio, etc.) no cambian.

---

## 4. Respuestas de la API (response body)

El campo `id` de **todas** las entidades devueltas ahora es un UUID string. Esto incluye las relaciones anidadas.

### Estructura general

- Cualquier campo llamado `id`, `user_id`, `event_id`, `category_id`, `venue_id`, `promoter_id`, `billing_account_id`, `subscription_id`, `product_id`, `price_id`, `notification_id` que pertenezca a entidades propias del sistema es ahora un UUID string.
- Los IDs de Stripe (`stripe_customer_id`, `stripe_subscription_id`, `stripe_product_id`, `stripe_price_id`) **no cambian** y siguen siendo los strings propios de Stripe.

### Por módulo

**Eventos** — `GET /events`, `GET /events/:id`, `GET /events/search`, etc.
- `event.id` → UUID string
- `event.promoter.id` → UUID string
- `event.categories[].id` → UUID string
- `event.images[].id` → UUID string
- `event.venue.id` → UUID string

**Usuarios** — `GET /users/me`, `GET /users/public/:id`
- `user.id` → UUID string

**Categorías** — `GET /categories`, `GET /categories/:id`
- `category.id` → UUID string

**Promotores** — `GET /promoters`, `GET /promoters/:id`
- `promoter.id` → UUID string (mismo UUID que el `user.id` del promotor)

**Notificaciones** — `GET /notifications`
- `notification.id` → UUID string
- `notification.user_id` → UUID string

**Billing** — `GET /billing/my-subscription`, `GET /billing/pricing-plans`
- `billingAccount.id` → UUID string
- `billingAccount.user_id` → UUID string
- `subscription.id` → UUID string
- `subscription.billing_account_id` → UUID string
- `product.id` → UUID string
- `price.id` → UUID string
- `stripe_customer_id`, `stripe_subscription_id` → **sin cambios**

**Venues** — `GET /venues/my-venues`
- `venue.id` → UUID string

---

## 5. Autenticación — Token JWT y usuario en sesión

### Login / registro / refresh

Los endpoints `POST /auth/login`, `POST /auth/register` y `POST /auth/refresh` devuelven el usuario con `id` como UUID string.

```
Antes: { "user": { "id": 42, "email": "...", "role": "PROMOTER" } }
Ahora: { "user": { "id": "550e8400-e29b-41d4-a716-446655440042", "email": "...", "role": "PROMOTER" } }
```

### Impacto en el estado de la aplicación

- Si se almacena el `user.id` en `localStorage`, `sessionStorage`, Zustand, Redux, Context o cualquier store del frontend, hay que asegurarse de tratarlo como string (nunca parsearlo a número).
- Cualquier comparación del tipo `if (currentUser.id === someId)` debe usar comparación de strings.
- Si el ID de usuario se usa como clave de caché (React Query, SWR, etc.), el cache se invalidará en el primer login post-migración, lo que es el comportamiento correcto.

### Tokens de usuario ya existentes

Los tokens JWT emitidos antes de la migración referenciarán IDs numéricos. Tras la migración, el usuario deberá volver a hacer login para obtener un token con UUID. En producción habrá que planificar una invalidación de sesiones activas o comunicarlo al usuario.

---

## 6. Manejo de errores nuevos relacionados con UUIDs

| Situación | Status HTTP | Mensaje del body |
|---|---|---|
| ID numérico en ruta (ej: `/events/123`) | `400 Bad Request` | `"Validation failed (uuid is expected)"` |
| UUID con formato inválido en ruta | `400 Bad Request` | `"Validation failed (uuid is expected)"` |
| `category_ids` con números en lugar de UUIDs | `400 Bad Request` | Errores de validación del campo |
| `category_id` (query param) con número | `400 Bad Request` | Errores de validación del campo |
| UUID válido que no existe en BD | `404 Not Found` | `"[Entidad] with ID [uuid] not found"` |

---

## 7. Mapa / Tiles / Clustering

Los endpoints de mapa también aplican el cambio de `category_id`:

- `GET /events/tiles/:z/:x/:y?category_id=<uuid>` — el parámetro `z`, `x`, `y` son números (sin cambios); `category_id` ahora UUID.
- `GET /events/clustering/map-points?category_id=<uuid>`
- `GET /events/clustering/grid?category_id=<uuid>`

Las respuestas de tiles y clustering incluyen el campo `primary_category_id` que ahora es un UUID string (o `null`).

---

## 8. Checklist de actualización

- [ ] Revisar todas las llamadas a la API que construyen URLs con IDs numéricos hardcodeados o almacenados como número
- [ ] Actualizar los modelos/interfaces/types del frontend: `id: number` → `id: string` en todas las entidades
- [ ] Actualizar el store de autenticación: `user.id` como string
- [ ] Actualizar el body de creación/edición de eventos: `category_ids` como `string[]`
- [ ] Actualizar los filtros de búsqueda y mapa: `category_id` como string UUID
- [ ] Revisar comparaciones de IDs (`===`, `==`) para que sean comparaciones de strings
- [ ] Revisar parseos de IDs (`parseInt`, `Number()`) y eliminarlos donde se use el ID como clave de entidad
- [ ] Revisar el manejo de caché (React Query keys, SWR keys) que incluyan IDs
- [ ] Forzar re-login de usuarios para renovar tokens JWT (en producción)
- [ ] Actualizar los mocks/fixtures de tests de frontend con UUIDs en lugar de números

---

## 9. Lo que NO cambia

- Rutas que usan **slugs** en lugar de IDs (`GET /events/eventos/:slug`, `GET /events/planes/categoria/:slug`, `GET /categories/slug/:slug`) — sin cambios.
- Todos los campos que no son IDs de entidades (título, descripción, precio, fechas, coordenadas, paginación, etc.) — sin cambios.
- IDs de Stripe (`stripe_customer_id`, `stripe_subscription_id`, etc.) — sin cambios.
- Estructura de autenticación (cookies, headers, flujo OAuth) — sin cambios.
- Endpoints de salud (`GET /health`), sitemap, contacto y subida de ficheros (firma Cloudinary) — sin cambios en su interfaz.
