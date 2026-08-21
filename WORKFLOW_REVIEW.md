# AI Config Workflow Review

Objetivo: convertir `ai-config` en una configuracion multi-tool clara, liviana y facil de mantener para Claude Code, OpenCode y Codex.

## Problema Actual

- `CLAUDE.md` quedo como centro historico, pero ahora el flujo usa varias herramientas.
- Hay riesgo de cargar demasiadas instrucciones siempre y gastar tokens sin necesidad.
- Algunas reglas empujan a analisis/planes largos incluso cuando el cambio es chico.
- Falta una matriz clara para decidir cuando usar chat directo, skill, comando, plan o review.
- Falta documentar que hace cada archivo y que NO deberia ir ahi.

## Objetivo Del Sistema

- Tener un source of truth neutral, no atado a Claude.
- Mantener instrucciones globales cortas por defecto.
- Cargar detalle solo bajo demanda: por skill, comando, repo o tarea.
- Separar reglas personales, reglas de herramienta y reglas de proyecto.
- Reducir verbosity accidental sin perder calidad tecnica.
- Saber rapidamente que usar segun tipo, riesgo e incertidumbre de la tarea.

## Arquitectura Deseada

- `CORE.md`: criterio base global, corto y portable. Creado como source of truth neutral inicial.
- `WORKFLOW.md`: matriz de decision para saber cuando usar que. Creado como guia operativa inicial.
- `CLAUDE.md`: adapter especifico de Claude Code, no source of truth principal. Convertido a adapter liviano.
- `opencode/opencode.jsonc`: adapter/config especifica de OpenCode. Carga `CORE.md` y `WORKFLOW.md`, no el adapter de Claude.
- `codex/AGENTS.md`: adapter global de Codex. Carga criterio neutral de forma liviana.
- `codex/rules/default.rules`: permisos/reglas operativas de Codex.
- `commands/`: flujos accionables, con output controlado.
- `skills/`: conocimiento especializado bajo demanda.
- `README.md`: explicacion publica/operativa del repo.
- `install.ps1`, `install.sh`, `ai.sh`: instalacion/sync, sin reglas de comportamiento.

## Principios De Verbosidad

- Default: breve.
- Expandir solo si hay riesgo, ambiguedad o decision importante.
- No hacer plan largo para cambios chicos.
- No hacer analysis completo si la tarea es clara y reversible.
- Si el plan supera unas pocas lineas, empezar con resumen ejecutivo.
- Si falta una decision del usuario, preguntar una cosa concreta.

## Clasificacion De Tareas

- `trivial`: copy, typo, clase visual minima, rename local. Resolver directo.
- `small`: cambio acotado de bajo riesgo. Explicar en 3-6 bullets maximo.
- `medium`: toca varios archivos o comportamiento. Analisis compacto + plan corto.
- `large`: feature/refactor con varias decisiones. Analisis completo + aprobacion.
- `risky`: auth, pagos, datos, multi-tenant, seguridad, migraciones, contratos externos. Parar y pedir decision antes de implementar.
- `investigation`: entender flujo/codigo sin tocar. Usar modo investigacion.
- `review`: codigo ya escrito. Priorizar hallazgos, no resumen largo.

## Matriz Inicial De Uso

| Situacion                      | Usar                                                   | Output Esperado                                      |
| ------------------------------ | ------------------------------------------------------ | ---------------------------------------------------- |
| Cambio chico y claro           | Chat directo                                           | Cambio aplicado + verificacion breve                 |
| Bug o error                    | `debug-root-cause`                                     | causa raiz, fix minimo, verificacion                 |
| No entiendo un flujo           | `code-investigator`                                    | explicacion tecnica del flujo, sin tocar codigo      |
| Feature mediana/grande         | `/analyze-feature`                                     | opciones, recomendacion, riesgos, decision necesaria |
| Ya hay solucion elegida        | `/create-plan`                                         | pasos ejecutables, validacion, checkpoints           |
| Ya hay plan aprobado           | `/dev-pipeline`                                        | implementacion acotada + verificacion                |
| Refactor                       | `refactor-plan` / `safe-refactor` si existe en el repo | preservar comportamiento, cambios incrementales      |
| UI                             | `impeccable` + stack skill si aplica                   | responsive, visual consistente, sin AI slop          |
| Codigo sucio o generado por IA | `deslop`                                               | limpieza minima sin cambiar comportamiento           |
| Antes de cerrar cambios        | `/review-work`                                         | findings primero, riesgos y gaps                     |

## Revision Archivo Por Archivo

1. `README.md`: confirmar que explica el repo sin volverse una fuente de reglas pesada. Sacar referencias obsoletas. Documentar Claude/OpenCode/Codex como targets.

2. `CLAUDE.md`: reducirlo a adapter Claude + punteros a `CORE.md` y `WORKFLOW.md` si conviene. Sacar duplicacion con reglas neutrales. Ajustar verbosity y decision rules.

3. Crear/revisar `CORE.md`: definir reglas globales minimas. Mantenerlo corto para ahorrar tokens. Evitar ejemplos largos y listas extensas.

4. Crear/revisar `WORKFLOW.md`: definir matriz final de decision. Aclarar cuando NO usar comandos pesados. Definir niveles de output: brief, standard, deep.

5. Omitir `TOOLING.md` por ahora: la configuracion debe mejorar respuestas en cualquier CLI/modelo sin recomendar cambios de herramienta que corten contexto.

6. `opencode/opencode.jsonc`: validar schema. Decidir que instrucciones carga siempre. Evitar duplicar docs largas si no hace falta.

7. `codex/AGENTS.md` y `codex/rules/default.rules`: mantener comportamiento en `AGENTS.md` y permisos en `default.rules`. Revisar comandos permitidos y peligrosos.

8. `commands/`: revisar cada comando. Agregar clasificacion por tamano/riesgo antes de generar outputs largos. Definir limite de longitud por defecto. - DONE initial

9. `skills/`: auditar una por una. Eliminar skills personales/laborales que ya no aplican. Asegurar que cada skill tenga trigger claro y no se active de mas. - DONE initial

10. `install.ps1`, `install.sh`, `ai.sh`: mantenerlos solo para instalacion/sync. Validar idempotencia. Evitar que contengan decisiones de comportamiento.

## Decisiones Pendientes

- Nombre final del source of truth neutral: `CORE.md`, `SYSTEM.md` u otro.
- Si `CLAUDE.md` debe contener todo el core o solo apuntar a `CORE.md`.
- Que instrucciones debe cargar OpenCode siempre.
- Que parte del workflow puede vivir en Codex sin gastar tokens innecesarios. - DONE initial
- Si conviene tener presets de respuesta: `brief`, `standard`, `deep`.
- Si los slash commands deben ser compatibles conceptualmente con OpenCode/Codex o solo Claude.

## Criterios De Exito

- Se entiende que hace cada archivo.
- No hay reglas obsoletas de trabajo anterior.
- No hay instrucciones duplicadas entre global y proyecto.
- Los cambios chicos no disparan planes largos.
- Los cambios riesgosos siguen teniendo analisis y aprobacion.
- Claude Code, OpenCode y Codex comparten criterio sin requerir cambiar de herramienta durante una sesion.
- El setup se puede reinstalar con un comando y queda consistente.

## Orden Propuesto Para Seguir

1. Revisar este documento y ajustar objetivos. - DONE
2. Revisar `CORE.md` corto en uso real. - DONE
3. Revisar `WORKFLOW.md` en uso real y ajustar budgets/matriz. - DONE initial
4. Convertir `CLAUDE.md` en adapter liviano que no duplique `CORE.md` innecesariamente. - DONE
5. Ajustar OpenCode para apuntar a los archivos correctos. - DONE
6. Revisar Codex adapter/rules. - DONE initial
7. Auditar commands. - DONE initial
8. Auditar skills. - DONE initial
9. Revisar archivos y ficheros locales, para que no queden configuraciones basuras. - DONE
10. Actualizar README. - DONE
11. Reejecutar instaladores y validar symlinks. - DONE
