---
title: "pabpereza/devsecops-demo: Aplicacion deliberadamente vulnerable para el curso de DevSecOps de pabpereza.dev"
source: "https://github.com/pabpereza/devsecops-demo"
author:
published:
created: 2026-11-27
description:
tags:
  - "clippings"
---
## devsecops-demo

> ⚠️
> 
> **Esta aplicación es vulnerable a propósito. No la despliegues en internet ni reutilices su código.**

Repositorio de prácticas del [curso de DevSecOps](https://pabpereza.dev/docs/cursos/devsecops) de [pabpereza.dev](https://pabpereza.dev/).

Es una aplicación Express diminuta con **cinco fallos plantados a propósito**. En cada capítulo del curso, una herramienta distinta encuentra el suyo en segundos.

## Los cinco fallos

| # | Fallo | Dónde | Lo encuentra | Capítulo |
| --- | --- | --- | --- | --- |
| 1 | Credenciales en el código | `src/config.js` | gitleaks | 2 |
| 2 | Dependencias con CVE conocido | `package-lock.json` | Trivy / Dependabot | 3 |
| 3 | `eval()` e inyección SQL | `src/routes.js` | Semgrep | 4 |
| 4 | Imagen base obsoleta y usuario root | `Dockerfile` | Trivy | 5 |
| 5 | S3 público, SSH abierto, RDS sin cifrar | `infra/main.tf` | Checkov / tfsec | 7 |

> **Las credenciales son falsas.** Son cadenas aleatorias con el formato correcto. No dan acceso a nada, no han existido nunca y no apuntan a ninguna cuenta real. Están ahí porque las herramientas las detectan igual que detectarían unas de verdad.

Un par de detalles que descubrirás por el camino, y que son parte de la gracia:

- **Ninguna herramienta las encuentra todas.** gitleaks detecta el token de Slack y la clave de base de datos, pero se le escapa el identificador de AWS. Semgrep sí lo pilla. Por eso se combinan.
- **Las reglas gratuitas de Semgrep no detectan la inyección SQL** (el seguimiento de datos contaminados es de la versión de pago). En el capítulo 4 la cazamos con una regla propia de doce líneas, que está en [`.semgrep.yml`](https://github.com/pabpereza/devsecops-demo/blob/main/.semgrep.yml).
- **Trivy necesita el `package-lock.json`**, no le basta con el `package.json`. Sin lockfile no reporta ni una vulnerabilidad.

## Cómo empezar

```
git clone https://github.com/pabpereza/devsecops-demo
cd devsecops-demo
```

No necesitas instalar nada para los laboratorios del curso: todas las herramientas se ejecutan como contenedor.

Si quieres levantar la aplicación para el capítulo de DAST:

```
npm install
npm start
# http://localhost:3000/health
```

## Pruébalo tú mismo

Antes de ver el capítulo correspondiente, lanza la herramienta y mira qué saca:

```
# Secretos (capítulo 2)
docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:latest detect -s /repo -v

# Dependencias vulnerables (capítulo 3)
docker run --rm -v "$PWD:/src" aquasec/trivy fs --scanners vuln /src

# Análisis estático del código (capítulo 4)
docker run --rm -v "$PWD:/src" semgrep/semgrep semgrep --config=auto /src

# ...y la regla propia que caza la inyección SQL (capítulo 4)
docker run --rm -v "$PWD:/src" semgrep/semgrep semgrep --config=/src/.semgrep.yml /src

# Infraestructura como código (capítulo 7)
docker run --rm -v "$PWD/infra:/tf" bridgecrew/checkov -d /tf
```

## Aviso

Este repositorio existe con fines educativos. Los fallos son intencionados y están documentados: **no hace falta reportarlos**. Si encuentras alguno que *no* esté en la tabla de arriba, ese sí me interesa — abre un issue.