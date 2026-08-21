---
description: Convierte una solucion aprobada en un plan tecnico ejecutable. No implementa.
argument-hint: [solucion aprobada, link al analisis o notas]
---

Solucion aprobada: `$ARGUMENTS`.

## Regla critica

**NO escribas codigo.** El entregable es un plan apto para `/dev-pipeline`.

Si el cambio es `small` segun `WORKFLOW.md`, no generes un plan largo. Decí que el plan seria mas largo que la implementacion y recomendá resolver por chat.

## Proceso

1. Leer el analisis aprobado o reconstruirlo desde el contexto disponible.
2. Leer codigo relevante para ubicar patrones y reutilizables.
3. Definir pasos incrementales verificables.
4. Separar decisiones no negociables de detalles de implementacion.
5. Declarar riesgos residuales y tests esperados.
6. Guardar el plan en `plans/<slug>.md` en la raiz del repo del proyecto (crear la carpeta si no existe). `<slug>` es kebab-case del ticket/feature; si ya existe, sufijo numerico.
7. Parar y pedir aprobacion.

## Output

Usar el menor formato que preserve correctness.

### Plan corto (`medium` por defecto)

Usar para cambios acotados con solucion clara:

### Decision aprobada
[Que opcion se eligio]

### Plan incremental

1. [ ] Paso — archivos — verificacion concreta
2. [ ] Paso — archivos — verificacion concreta
3. [ ] Paso — archivos — verificacion concreta

### Validacion
- Comandos/checks:
- QA manual:
- Riesgos:

### Plan guardado en
`plans/<slug>.md`

### Proximo paso
Esperar aprobacion explicita antes de ejecutar `/dev-pipeline`, salvo que el usuario haya pedido implementar ahora.

### Plan completo (`large` o `risky`)

Usar solo si hay varias capas, contratos, datos, migracion o riesgo alto.

### Decision aprobada
[Que opcion se eligio y por que]

### Diseño tecnico
- Entrada:
- Salida:
- Capas afectadas:
- Boundaries:
- Datos / contratos:

### Reutilizables
- `path` — como se usa o adapta

### Archivos afectados

| Archivo | Accion | Responsabilidad |
|---|---|---|
| `path` | crear / modificar | ... |

### Plan incremental

1. [ ] Paso — archivos — verificacion concreta
2. [ ] Paso — archivos — verificacion concreta
3. [ ] Paso — archivos — verificacion concreta

Cada paso debe dejar el codigo en un estado entendible y verificable.

### Testing y QA
- Unit:
- Integracion:
- Manual:
- Comandos sugeridos:

### Riesgos residuales
- [Alto/Medio/Bajo] Riesgo — mitigacion

### Input para `/dev-pipeline`

```md
Ticket:
Solucion elegida:
Decisiones no negociables:
Fuera de scope:
Criterios de aceptacion:
Plan aprobado:
Checks esperados:
Riesgos conocidos:
```

### Plan guardado en
`plans/<slug>.md`

### Proximo paso
Esperar aprobacion explicita antes de ejecutar `/dev-pipeline`.
