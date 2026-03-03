# 🏢 Sistema de Gestión Inmobiliaria

Base de datos relacional normalizada hasta **Tercera Forma Normal (3FN)** para la gestión integral del ciclo operativo de una inmobiliaria: propiedades, clientes, contratos, pagos, auditoría automática y reportes de morosidad.

**Autor:** Julian Andres Santamaria Bustamante

---

## 📑 Tabla de Contenidos

1. [Descripción General](#-descripción-general)
2. [Alcance Funcional](#-alcance-funcional)
3. [Estructura del Repositorio](#-estructura-del-repositorio)
4. [Requisitos e Instalación](#-requisitos-e-instalación)
5. [Arquitectura del Modelo de Datos](#-arquitectura-del-modelo-de-datos)
6. [Entidades Principales](#-entidades-principales)
7. [Funciones (UDF)](#-funciones-udf)
8. [Triggers y Automatización](#-triggers-y-automatización)
9. [Roles y Seguridad](#-roles-y-seguridad)
10. [Evento de Morosidad](#-evento-programado-de-morosidad)
11. [Índices y Optimización](#-índices-y-optimización)
12. [Notas de Consistencia de Negocio](#-notas-de-consistencia-de-negocio)
13. [Pruebas Rápidas](#-pruebas-rápidas)
14. [Consultas de Ejemplo](#-consultas-de-ejemplo)
15. [Normalización (3FN)](#-decisiones-de-diseño-y-normalización-3fn)

---

## 📌 Descripción General

Este proyecto implementa una base de datos relacional en **MySQL 8.0+** orientada a cubrir las necesidades operativas de una inmobiliaria moderna. El modelo está diseñado bajo principios de normalización hasta **3FN** para garantizar integridad, consistencia y escalabilidad.

El sistema permite:

- Gestionar un portafolio de propiedades (venta y arriendo)
- Registrar y administrar clientes y empleados
- Formalizar contratos con automatización de estados
- Administrar pagos periódicos y calcular deuda pendiente
- Calcular comisiones por ventas
- Auditar cambios críticos mediante triggers
- Generar reportes automáticos de morosidad
- Aplicar control de acceso basado en roles (RBAC)

---

## 🎯 Alcance Funcional

| Módulo | Estado |
|---|---|
| Venta de propiedades | ✅ Incluido |
| Arrendamiento de propiedades | ✅ Incluido |
| Gestión de cartera (pagos y morosidad) | ✅ Incluido |
| Trazabilidad histórica de cambios | ✅ Incluido |
| Seguridad por roles | ✅ Incluido |
| Automatización mediante eventos | ✅ Incluido |

---

## 📁 Estructura del Repositorio

```
PROYECTO_MYSQL_2/
├─ Docs/
│  ├─ Diagrama_ER.png
│  ├─ Modelo_Entidad-Relacion.png
│  └─ Normalizacion/
│     ├─ Normalizacion-1.png
│     └─ Normalizacion-2.png
├─ sql/
│  ├─ 00_run_all.sql
│  ├─ 01_db.sql
│  ├─ 02_catalogos.sql
│  ├─ 03_entidades.sql
│  ├─ 04_contratos_pagos.sql
│  ├─ 05_auditoria_reportes.sql
│  ├─ 06_indices.sql
│  ├─ 07_funciones.sql
│  ├─ 08_triggers.sql
│  ├─ 09_eventos.sql
│  ├─ 10_roles_usuarios.sql
│  ├─ 11_datos_prueba.sql
│  └─ Script_DDL_DML.sql
└─ README.md
```

---

## ⚙️ Requisitos e Instalación

**MySQL 8.0** o superior con permisos para: `CREATE DATABASE`, `CREATE ROLE / USER`, `CREATE TRIGGER`, `CREATE EVENT`, `CREATE FUNCTION`.

### 1. Habilitar el scheduler de eventos

```sql
SET GLOBAL event_scheduler = ON;
```

### 2. Verificar la activación

```sql
SHOW VARIABLES LIKE 'event_scheduler';
```

Resultado esperado:

```
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| event_scheduler  | ON    |
+------------------+-------+
```

### 3. Ejecutar el script

**Opción A — MySQL Workbench**

1. Abre MySQL Workbench y conéctate a tu servidor.
2. Ve a **File → Open SQL Script** y selecciona `sql/Script_DDL_DML.sql`.
3. Ejecuta con **Ctrl + Shift + Enter**.

> ⚠️ `SOURCE` no funciona en Workbench. Debes usar Open SQL Script o copiar y pegar el contenido directamente.

**Opción B — CLI**

```bash
mysql -u root -p < sql/Script_DDL_DML.sql
```

O desde dentro del cliente interactivo:

```bash
SOURCE sql/Script_DDL_DML.sql;
```

> ✅ `SOURCE` sí funciona en el cliente de línea de comandos, pero la ruta debe ser relativa al directorio desde donde lanzaste `mysql`.

---

## 🖼️ Diagramas del Proyecto

La carpeta `Docs/` incluye las representaciones gráficas del diseño conceptual, físico y del proceso de normalización del sistema.

### Modelo Entidad-Relación (Conceptual)

![ Modelo Entidad-Relación](https://i.ibb.co/rTQr8bq/modelo-entidad-relacion.png)

`Ver completo en Docs`

Representa las entidades principales, atributos clave, relaciones y cardinalidades desde el punto de vista conceptual, antes de su implementación en MySQL.

### Diagrama ER (Modelo Físico)

![Diagrama ER](https://i.ibb.co/hbQ33XD/diagrama-er.png)

`Ver completo en Docs`

Corresponde al modelo físico generado a partir del script SQL. Incluye claves primarias (PK), claves foráneas (FK), tipos de datos y relaciones con integridad referencial. Refleja exactamente la estructura creada en `inmobiliaria_db`.

### Proceso de Normalización (1FN → 3FN)

![Normalización – Parte 1](https://i.ibb.co/j9VjQx7k/normalizacion-1.png)
![Normalización – Parte 2](https://i.ibb.co/bRYvjFTF/normalizacion-2.png)

`Ver completo en Docs`

Muestra el proceso de refinamiento del modelo hasta alcanzar la **3FN**: eliminación de atributos multivaluados, dependencias parciales y transitivas; separación de catálogos y normalización de `direccion` y `pago`.

---

## 🧩 Arquitectura del Modelo de Datos

El modelo se divide en cuatro capas lógicas:

```
┌─────────────────────────────────────────────────────────┐
│  1. Catálogos        → tablas maestras (tipos, estados) │
│  2. Transaccionales  → operación del negocio            │
│  3. Auditoría        → histórico automático de cambios  │
│  4. Reportes         → vistas materializadas            │
└─────────────────────────────────────────────────────────┘
```

---

## 🏗️ Entidades Principales

### Tablas operativas

| Tabla | Función |
|---|---|
| `propiedad` | Inventario de bienes inmobiliarios |
| `direccion` | Ubicación normalizada |
| `tipo_propiedad` | Catálogo de tipos de propiedad |
| `estado_propiedad` | Estados operativos del inmueble |
| `cliente` | Compradores o arrendatarios |
| `empleado` | Agentes y personal interno |
| `contrato` | Formalización de ventas y arriendos |
| `pago` | Cuotas y pagos asociados a contratos |

### Tablas de auditoría y reportes

| Tabla | Propósito |
|---|---|
| `audit_propiedad_estado` | Histórico automático de cambios de estado |
| `audit_contrato` | Registro de creación de contratos |
| `reporte_morosidad_mensual` | Tabla materializada generada por evento programado |

---

## 🔧 Funciones (UDF)

### `fn_calcular_comision_venta(id_contrato)`

Calcula la comisión aplicable a contratos de tipo `VENTA`. Usa el `comision_rate` definido en el contrato; si es `NULL`, toma el valor de la tabla de configuración.

```sql
SELECT fn_calcular_comision_venta(1);
```

### `fn_deuda_pendiente_arriendo(id_contrato)`

Suma las diferencias entre `monto_programado` y `monto_pagado` para todas las cuotas vencidas del contrato.

```sql
SELECT fn_deuda_pendiente_arriendo(2);
```

### `fn_total_disponibles_por_tipo(tipo)`

Devuelve el número de propiedades con estado `DISPONIBLE` filtradas por tipo.

```sql
SELECT fn_total_disponibles_por_tipo('CASA');
```

---

## 🔁 Triggers y Automatización

| Trigger | Evento | Función |
|---|---|---|
| `trg_propiedad_audit_estado` | `BEFORE UPDATE` en `propiedad` | Inserta registro en `audit_propiedad_estado` al cambiar el estado |
| `trg_contrato_audit_insert` | `AFTER INSERT` en `contrato` | Registra la creación del contrato en `audit_contrato` |
| `trg_contrato_actualiza_estado_prop` | `AFTER INSERT` en `contrato` | Actualiza el estado de la propiedad según el tipo de contrato |

El trigger `trg_contrato_actualiza_estado_prop` aplica la siguiente lógica automáticamente:

| Tipo de contrato | Estado resultante de la propiedad |
|---|---|
| `ARRIENDO` | `ARRENDADA` |
| `VENTA` | `VENDIDA` |

---

## 🔐 Roles y Seguridad

El sistema implementa **control de acceso basado en roles (RBAC)** siguiendo el principio de menor privilegio.

| Rol | Alcance |
|---|---|
| `rol_admin` | Acceso total a todas las operaciones |
| `rol_agente` | Gestión operativa de propiedades y contratos |
| `rol_contador` | Gestión financiera: pagos y reportes |

---

## 📆 Evento Programado de Morosidad

**Evento:** `ev_reporte_morosidad_mensual`

| Parámetro | Valor |
|---|---|
| Frecuencia | Mensual |
| Ejecución | Primer día de cada mes |
| Condición | Contratos `ARRIENDO` vigentes con deuda > 0 |
| Duplicados | Prevenidos con `ON DUPLICATE KEY UPDATE` |

El evento genera automáticamente registros en `reporte_morosidad_mensual` sin intervención del administrador.

---

## ⚡ Índices y Optimización

Se incluyen índices estratégicos para mejorar el rendimiento en las operaciones más frecuentes:

- Búsqueda por estado y tipo de propiedad
- Consultas por contrato y cliente
- Gestión de cobranza por fecha de vencimiento

---

## 📋 Notas de Consistencia de Negocio

> Estas reglas son fundamentales para entender el modelo y están reforzadas automáticamente por los triggers.

- **Los contratos de tipo `VENTA` no generan registros de pago.** El precio se registra directamente en el contrato; la tabla `pago` no aplica para este flujo.
- **La tabla `pago` es exclusiva de contratos `ARRIENDO`.** Cada cuota mensual genera un registro independiente que permite calcular deuda y morosidad.
- **Los triggers actualizan el estado de la propiedad automáticamente.** Al insertar un contrato, `trg_contrato_actualiza_estado_prop` cambia el estado del inmueble a `ARRENDADA` o `VENDIDA` según corresponda.

---

## 🧪 Pruebas Rápidas

Ejecuta estas queries después de correr el script para verificar que los triggers y la auditoría funcionan correctamente.

**Auditoría de contratos** (debe mostrar un registro por cada `INSERT` en `contrato`):

```sql
SELECT * FROM audit_contrato;
```

**Auditoría de cambios de estado** (debe reflejar los cambios generados por los triggers):

```sql
SELECT * FROM audit_propiedad_estado;
```

**Estados actualizados automáticamente:**

```sql
SELECT id_propiedad, estado
FROM propiedad
WHERE estado IN ('ARRENDADA', 'VENDIDA');
```

**Reporte de morosidad materializado:**

```sql
SELECT * FROM reporte_morosidad_mensual;
```

**Event scheduler activo:**

```sql
SHOW EVENTS;
```

---

## 📊 Consultas de Ejemplo

**Propiedades disponibles por tipo:**

```sql
SELECT fn_total_disponibles_por_tipo('APARTAMENTO');
```

**Deuda pendiente de un contrato:**

```sql
SELECT fn_deuda_pendiente_arriendo(2);
```

**Comisión de una venta:**

```sql
SELECT fn_calcular_comision_venta(1);
```

**Reporte de arrendatarios morosos:**

```sql
SELECT
    c.id_contrato,
    cl.nombres,
    cl.apellidos,
    fn_deuda_pendiente_arriendo(c.id_contrato) AS deuda
FROM contrato c
JOIN cliente cl ON cl.id_cliente = c.id_cliente
WHERE c.tipo   = 'ARRIENDO'
  AND c.estado = 'VIGENTE'
  AND fn_deuda_pendiente_arriendo(c.id_contrato) > 0
ORDER BY deuda DESC;
```

---

## 📐 Decisiones de Diseño y Normalización (3FN)

| Forma Normal | Cumplimiento |
|---|---|
| **1FN** | Atributos atómicos, sin grupos repetitivos |
| **2FN** | PKs simples en todas las tablas, sin dependencias parciales |
| **3FN** | Sin dependencias transitivas; cada atributo depende únicamente de su clave primaria |

**Decisiones de diseño destacadas:**

- `tipo_propiedad` como catálogo separado → evita repetir strings en cada fila
- `estado_propiedad` como catálogo separado → elimina inconsistencias de estado
- `direccion` normalizada → evita duplicación de datos de ubicación
- `pago` como entidad independiente → permite múltiples cuotas por contrato

---

## 🏁 Conclusión

Este proyecto demuestra la implementación de una base de datos relacional robusta y extensible que integra modelado relacional normalizado hasta 3FN, automatización mediante triggers y eventos programados, funciones de negocio personalizadas (UDF), seguridad basada en roles con menor privilegio, y optimización mediante índices estratégicos.

---

*Desarrollado para MySQL 8.0+*