---
title: "Chatbot App - AI Chatbot"
source: "https://chatbot.app/chats/bu5qUro0bwVu7UoH7Kcp?model=auto"
author:
published: 2026-11-27
created: 2026-11-27
description: "Chatbot App - AI Chatbot"
tags:
  - "clippings"
---
## Práctica paso a paso

La demo de la charla **"Supply chain security en vivo"**, comando a comando. Sigue el mismo orden que la charla: primero el inventario y el escaneo, y después el camino hasta el clúster, cerrándolo paso a paso.

Todo se hace a mano, desde un solo terminal. En el paso 5 haces tú de atacante: alguien con un token del registry filtrado que puede subir imágenes y hacer commits, pero no tiene la clave privada de Cosign.

> Cambia `docker.io/pabpereza/supply-chain-demo` por un repositorio tuyo de Docker Hub (o el registry que uses) y apunta `argocd/application.yaml` a tu fork.

## 0\. Preparar el laboratorio

### Herramientas

Versiones probadas: kind 0.33 (Kubernetes 1.37), Kyverno 1.20, Argo CD 3.x, Cosign 3.1.4, Syft 1.57.2 y Grype 0.122.0.

```bash
brew install kind kubectl helm argocd cosign syft grype jq
```

### Dónde corre cada cosa

| Dónde | Qué |
| --- | --- |
| Tu Mac, con Docker Desktop | `docker build`, `syft`, `grype`, `docker push` y `cosign`: todo lo de la imagen |
| Una VM de Lima | Solo el clúster kind, con su propio Docker dentro |
| Tu Mac, contra el clúster de la VM | `kubectl`, `helm` y `argocd` (contexto `kind-supply`) |

La imagen viaja del Mac al clúster a través de Docker Hub: el Mac la sube y el nodo de kind la descarga.

**No exportes `DOCKER_HOST` en el terminal de la práctica.** Si lo haces, `docker` y `syft` dejan de usar Docker Desktop y no encuentran tu imagen. El Docker de la VM solo se usa para crear y borrar el clúster, en ese mismo comando.

### El clúster, Kyverno y Argo CD

La VM, una vez (plantilla `docker` de Lima):

```bash
limactl start --name supply-lab --cpus 4 --memory 8 template://docker
```

El clúster, dentro de la VM. `kind` escribe en tu `~/.kube/config` el contexto `kind-supply`, así que `kubectl` en el Mac ya apunta a él:

```bash
DOCKER_HOST=unix://$HOME/.lima/supply-lab/sock/docker.sock kind create cluster --name supply
```

Comprobar que cada cosa apunta donde toca:

```bash
docker context show                 # desktop-linux: las imágenes, en tu Mac
echo "${DOCKER_HOST:-sin DOCKER_HOST}"  # sin DOCKER_HOST
kubectl config current-context      # kind-supply: el clúster de la VM
kubectl get nodes
```
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```
```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
```

Entrar en Argo CD (en otra pestaña, deja el port-forward abierto):

```bash
kubectl -n argocd port-forward svc/argocd-server 8443:443
```
```bash
argocd admin initial-password -n argocd
argocd login localhost:8443 --username admin --insecure
```

La aplicación, que sincroniza `deploy/` con sync manual:

```bash
kubectl apply -f argocd/application.yaml
```

### La clave del pipeline

Se genera al principio del paso 3, antes de cargar las políticas de Kyverno: la clave pública va pegada dentro de ellas.

### Antes de empezar

```bash
docker login
grype db update                      # descarga la base de datos ahora, no en directo
export GRYPE_DB_AUTO_UPDATE=false
kubectl get validatingpolicy,imagevalidatingpolicy   # debe estar vacío
```

Si queda alguna política de un ensayo anterior:

```bash
kubectl delete -f policies/kyverno/ --ignore-not-found
```

## 1\. El inventario: SBOM con Syft

```bash
docker build -t docker.io/pabpereza/supply-chain-demo:dev app/
```
```bash
syft docker.io/pabpereza/supply-chain-demo:dev -o cyclonedx-json=sbom.cdx.json
```

El SBOM lleva los paquetes de la imagen y, además, cada fichero como un componente de tipo `file`.

```bash
jq '.components | length' sbom.cdx.json                                      # unos 1.280 componentes
jq '[.components[] | select(.type != "file")] | length' sbom.cdx.json          # 72: los paquetes y el sistema operativo
jq -r '.components[] | select(.type != "file") | "\(.name) \(.version)"' sbom.cdx.json | head
```

## 2\. El escaneo: Grype sobre el SBOM

Primero analizar la imagen, si usar el SBOM, pero usando imagen local:

```bash
grype docker.io/pabpereza/supply-chain-demo:dev
```

Pero si quieres analizarla sin descargarla, puedes analizarla directamente desde el almacanamiento docker local:

```bash
grype --from docker docker.io/pabpereza/supply-chain-demo:dev
```
```bash
grype sbom:sbom.cdx.json
```

Hacerlo accionable: que falle solo si hay algo crítico que tenga parche.

```bash
grype --fail-on critical --only-fixed sbom:sbom.cdx.json
echo $?                          # 0 si pasa, 2 si salta --fail-on
```

### El fallo, con una imagen base sin actualizar

`attacker/` usa `nginx-unprivileged:alpine` sin `apk upgrade`, así que sirve para ver un pipeline que se para:

```bash
docker build -t vieja attacker/
syft vieja -o cyclonedx-json=vieja.cdx.json
grype --fail-on critical --only-fixed sbom:vieja.cdx.json
```

Fíjate en las columnas **EPSS** (probabilidad de que se explote en los próximos 30 días) y **KEV** (el catálogo de CISA de vulnerabilidades que ya se están explotando). Depende de la base de datos del día, así que puede que no salga nada crítico.

El arreglo está en `app/Dockerfile`: `RUN apk upgrade --no-cache`.

### Las dependencias de tu aplicación

Grype también lee los lockfiles de un directorio (`package-lock.json`, `poetry.lock`, `go.sum`...):

```bash
grype dir:.
```

## 3\. Kyverno: explicar y cargar las políticas

Primero ponemos las reglas en el clúster y comprobamos que **el despliegue de siempre ya no entra**. Después, en el paso 4, iremos cumpliendo una condición tras otra hasta que se acepte.

Son tres políticas, todas para el namespace `demo` y sobre Pods (Kyverno las extiende solo a Deployments, Jobs...):

| Política | Tipo | Qué exige |
| --- | --- | --- |
| `guardarrailes.yaml` | `ValidatingPolicy` | Reglas sobre el YAML en CEL: tag y no `latest`, sin `privileged`, `runAsNonRoot`, límite de memoria y solo imágenes de `docker.io/pabpereza` |
| `require-signed.yaml` | `ImageValidatingPolicy` | Imagen por digest y firmada con la clave del pipeline |
| `require-sbom.yaml` | `ImageValidatingPolicy` | Además, un SBOM CycloneDX firmado con la misma clave |

Las dos últimas llevan dentro la clave pública, así que lo primero es generarla.

### Antes de nada, las claves de Cosign

Un par de claves: la privada firma (solo la tiene el pipeline) y la pública verifica (la tienen Kyverno y cualquiera que quiera comprobar).

La privada se guarda **fuera del repo**:

```bash
mkdir -p ~/.config/supply-chain-demo && cd ~/.config/supply-chain-demo
COSIGN_PASSWORD="" cosign generate-key-pair
chmod 600 cosign.key && ls -l
cd -
```
- `cosign.key`: la clave privada (ECDSA P-256), cifrada con la contraseña. En la demo va vacía para no teclearla en directo; en un pipeline real, contraseña en un secreto o, mejor, un KMS (`cosign generate-key-pair --kms ...`) o el modo keyless.
- `cosign.pub`: la clave pública. Se puede publicar sin problema.

La pública sí va al repo:

```bash
cp ~/.config/supply-chain-demo/cosign.pub .
cat cosign.pub
```

Y dentro de las dos políticas de imágenes, en `attestors[].cosign.key.data` de `policies/kyverno/require-signed.yaml` y `require-sbom.yaml`. Este comando la saca ya con la sangría del YAML para copiarla y pegarla:

```bash
sed 's/^/            /' cosign.pub
```

### Cargar las políticas

```bash
kubectl apply --server-side -f policies/kyverno/guardarrailes.yaml
kubectl apply --server-side -f policies/kyverno/require-signed.yaml
kubectl apply --server-side -f policies/kyverno/require-sbom.yaml
kubectl get validatingpolicy,imagevalidatingpolicy
```

`--server-side` porque el `apply` clásico falla al actualizar una `ImageValidatingPolicy`.

### Una función para probar sin desplegar

Pide al API server que cree un Pod con la imagen que le pases en modo `--dry-run=server`: pasa por toda la admisión (Kyverno incluido) pero no se guarda nada. El Pod ya cumple el resto de guardarraíles, así que solo se juzga la imagen.

```bash
probar() {
kubectl apply --dry-run=server -f - <<EOF
apiVersion: v1
kind: Pod
metadata: {name: prueba, namespace: demo}
spec:
  securityContext: {runAsNonRoot: true}
  containers:
    - name: web
      image: $1
      resources: {limits: {memory: 64Mi}}
EOF
}
```
```bash
probar nginx:latest
```

Rechazado: `imagen sin tag o con latest`. Es la primera regla de los guardarraíles que falla.

### El despliegue de siempre, rechazado

Lo que hace casi todo el mundo: apuntar el Deployment a un tag.

```bash
sed -i '' -E "s#image: .*supply-chain-demo.*#image: docker.io/pabpereza/supply-chain-demo:dev#" deploy/deployment.yaml
git commit -am "deploy: imagen por tag" && git push
argocd app sync web
```

Resultado: `SyncFailed` con `does not have a digest` (y `argocd app sync` sale con código 1). Lo que ya estaba corriendo sigue: Kyverno decide en la admisión, no echa nada. El siguiente sync entra sin hacer nada más.

## 4\. Dar las condiciones, una a una

Con la imagen `:dev` del paso 1 y su `sbom.cdx.json`. Después de cada condición, `probar` dice qué falta.

### Condición 1: publicada y por digest

```bash
docker push docker.io/pabpereza/supply-chain-demo:dev
DIGEST=$(docker buildx imagetools inspect docker.io/pabpereza/supply-chain-demo:dev --format '{{json .Manifest.Digest}}' | tr -d '"')
IMG=docker.io/pabpereza/supply-chain-demo@$DIGEST
echo $IMG
```

El tag `:dev` se puede mover a otra imagen; el digest (`sha256:...`) es el hash del manifiesto y no cambia. A partir de aquí todo va contra `$IMG`, nunca contra el tag.

```bash
probar $IMG
```

Rechazado. Ya tiene digest, pero nadie la ha firmado ni le ha adjuntado el SBOM, así que fallan las dos políticas de imagen a la vez. Sale el mensaje de la que conteste antes, y puede variar de un intento a otro: `imagen no firmada por el pipeline` o `imagen sin SBOM firmado por el pipeline`.

### Condición 2: firmada por el pipeline y con su SBOM firmado

Las dos políticas de imagen se cumplen a la vez: la firma de la imagen y el SBOM firmado, los dos con la clave del pipeline.

Firmar la imagen:

```bash
export COSIGN_KEY=~/.config/supply-chain-demo/cosign.key
export COSIGN_PASSWORD=""          # la clave de la demo no tiene contraseña; así Cosign no la pregunta
cosign sign --yes --key $COSIGN_KEY \
  --signing-config signing-config.json $IMG
```
- `--key`: firma con la clave privada del pipeline. Sin ella, Cosign intenta el modo keyless (identidad OIDC).
- `--signing-config signing-config.json`: la configuración de firma del repo, sin Rekor (el registro público de transparencia) ni autoridad de certificados. La firma solo va al registry. Sustituye a los antiguos `--use-signing-config=false --tlog-upload=false`, que Cosign 3 marca como deprecados.

Y adjuntar el `sbom.cdx.json` del paso 1, firmado y colgado del digest como atestación in-toto:

```bash
cosign attest --yes --key $COSIGN_KEY --type cyclonedx \
  --predicate sbom.cdx.json --signing-config signing-config.json $IMG
```

Comprobar la firma: en la salida, `critical.image.docker-manifest-digest` tiene que ser el mismo `$DIGEST`. Con una imagen que no ha firmado el pipeline, falla.

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog --insecure-ignore-sct $IMG | jq
cosign verify --key cosign.pub --insecure-ignore-tlog --insecure-ignore-sct docker.io/pabpereza/supply-chain-demo:evil   # no signatures found
```

### Desplegar y comprobar

Se fija en Git la imagen por su digest, que es lo que se ha firmado: el tag se puede mover (el paso 5 lo demuestra) y Kyverno rechaza cualquier imagen sin digest.

```bash
sed -i '' -E "s#image: .*supply-chain-demo.*#image: docker.io/pabpereza/supply-chain-demo:dev@$DIGEST#" deploy/deployment.yaml # Hacer a mano

git diff deploy/
git commit -am "deploy: imagen firmada y con SBOM" && git push
argocd app sync web
```

Argo CD ha sincronizado y la aplicación está sana:

```bash
argocd app wait web --sync --health --timeout 120
argocd app get web                            # Sync Status: Synced · Health Status: Healthy
```

Kubernetes ha terminado el rollout y el pod está listo:

```bash
kubectl -n demo rollout status deploy/web --timeout=60s
kubectl -n demo get pods -l app=web -o wide
```

Lo que pide el Deployment y lo que pide el pod que está corriendo, que es lo que ha admitido Kyverno:

```bash
kubectl -n demo get deploy web -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## 5\. Inventario vivo: sale una CVE nueva, ¿me afecta?

El SBOM se recupera del registry y se escanea sin descargar ni reconstruir la imagen:

```bash
IMG=$(grep -o 'docker.io/pabpereza/supply-chain-demo[^ ]*' deploy/deployment.yaml)
cosign verify-attestation --key cosign.pub --type cyclonedx \
  --insecure-ignore-tlog --insecure-ignore-sct "$IMG" \
  | head -1 | jq -r .payload | base64 -d | jq .predicate > desplegado.cdx.json
```
```bash
jq -r '.components[] | select(.name | test("xz")) | "\(.name) \(.version)"' desplegado.cdx.json
grype sbom:desplegado.cdx.json
```

Los `--insecure-ignore-*` son porque en la demo firmamos sin Rekor (el registro de transparencia de Sigstore).

## 6\. Limpiar

```bash
kubectl delete -f policies/kyverno/ --ignore-not-found
DOCKER_HOST=unix://$HOME/.lima/supply-lab/sock/docker.sock kind delete cluster --name supply
rm -f sbom.cdx.json vieja.cdx.json desplegado.cdx.json
```

## Si algo falla

| Síntoma | Qué hacer |
| --- | --- |
| Un sync se queda en marcha (`Running`) y el siguiente no entra | `argocd app terminate-op web` y volver a sincronizar. Tras un sync `Failed` no hace falta |
| `kubectl apply` de una política falla con `resourceVersion ... must be specified` | Usar `kubectl apply --server-side` |
| Grype tarda al arrancar | No se ha precargado la base: `grype db update` y `GRYPE_DB_AUTO_UPDATE=false` |
| `cosign verify` dice `no signatures found` justo después de firmar | Caché de referrers de Docker Hub: espera unos minutos (ver la nota de la condición 2) |
| `cosign verify-attestation` falla por Rekor | Añadir `--insecure-ignore-tlog --insecure-ignore-sct` |
| Kyverno tarda en responder o rechaza por timeout | Comprobar que los pods de `kyverno` están listos; con rate limit de Docker Hub, darle credenciales |
| `syft` o `grype` no encuentran la imagen, o analizan otra | Hay un `DOCKER_HOST` exportado y miran el Docker de la VM: `unset DOCKER_HOST` |
| `syft` tarda un par de minutos la primera vez | Antes de analizar pide la imagen a Docker Desktop y comprueba Docker Hub. Con `syft -v` se ve en qué está; las siguientes veces tarda segundos |

explica paso a paso, indica de que se trata cada herramienta, que objetivos tiene y detalla el uso en cada paso

Nov 27, 7:19 AM

Inspecting uploaded artifact

I need to check the uploaded document and clarify the user's request in Spanish, explaining step by step each tool's objective and usage. It sounds like they want to understand how to generate a document or analyze the artifact. First, I'll load the artifact to see its content. Then, I’ll break down the process of using each tool effectively. Let's ensure I cover everything clearly!

La práctica demuestra cómo proteger una imagen de contenedor desde su construcción hasta su despliegue en Kubernetes. El recorrido es: **inventariar la imagen, buscar vulnerabilidades, exigir controles de seguridad y comprobar que el clúster solo admite una imagen identificada, firmada y acompañada de su inventario**.

## Dónde se ejecuta cada cosa

- **En el Mac:** Docker Desktop construye y analiza la imagen, y la publica en el registry. También se ejecutan `syft`, `grype`, `cosign`, `kubectl`, `helm` y `argocd`.
- **En la VM de Lima:** corre el clúster `kind`. La práctica usa el Docker de la VM solo para crear o eliminar ese clúster.
- **En Docker Hub u otro registry:** se publica la imagen y se guardan su firma y su SBOM.
- **En Kubernetes:** Kyverno aplica las reglas de admisión; Argo CD sincroniza lo que está declarado en Git.

Es importante **no dejar `DOCKER_HOST` exportado** en el terminal de la práctica. Si se apunta Docker al de la VM, herramientas como Syft podrían no encontrar la imagen que construiste en Docker Desktop.

## Qué hace cada herramienta

| Herramienta | Para qué sirve en la práctica |
| --- | --- |
| **Docker** | Construye la imagen, la etiqueta y la publica en el registry. |
| **Syft** | Inspecciona la imagen y genera un SBOM: un inventario de paquetes y archivos. |
| **Grype** | Busca vulnerabilidades conocidas en una imagen, un SBOM o un directorio con dependencias. |
| **Cosign** | Firma la imagen y el SBOM para que otros puedan verificar su origen e integridad. |
| **kind** | Crea un clúster Kubernetes local dentro de la VM. |
| **Lima** | Proporciona la VM donde corre el clúster. |
| **kubectl** | Administra Kubernetes: instala componentes, aplica configuraciones y consulta recursos. |
| **Helm** | Instala Kyverno en el clúster usando su paquete Helm. |
| **Kyverno** | Rechaza despliegues que incumplen las políticas de seguridad. |
| **Argo CD** | Sincroniza con el clúster los manifiestos definidos en Git. |
| **Git** | Guarda los cambios de despliegue y permite que Argo CD los detecte. |
| **jq** | Consulta y transforma datos JSON, como los componentes del SBOM. |

## Preparación del laboratorio

### 0\. Instalar y levantar el entorno

Se instalan las herramientas con Homebrew:

```bash
brew install kind kubectl helm argocd cosign syft grype jq
```

Lima arranca la VM y `kind` crea dentro de ella el clúster llamado `supply`:

```bash
limactl start --name supply-lab --cpus 4 --memory 8 template://docker
DOCKER_HOST=unix://$HOME/.lima/supply-lab/sock/docker.sock kind create cluster --name supply
```

El `DOCKER_HOST=...` se aplica **solo a ese comando**: así `kind` usa el Docker de la VM. Luego se comprueban las conexiones:

```bash
docker context show
echo "${DOCKER_HOST:-sin DOCKER_HOST}"
kubectl config current-context
kubectl get nodes
```

Se instala **Kyverno** con Helm:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Después se instala **Argo CD** y se espera a que su servidor esté listo:

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
```

El `port-forward` crea una conexión local para entrar a Argo CD:

```bash
kubectl -n argocd port-forward svc/argocd-server 8443:443
```

En otra terminal se obtiene la contraseña inicial y se inicia sesión:

```bash
argocd admin initial-password -n argocd
argocd login localhost:8443 --username admin --insecure
```

Por último, se registra la aplicación que Argo CD administrará:

```bash
kubectl apply -f argocd/application.yaml
```

**Objetivo de esta etapa:** tener un clúster listo, con Kyverno para hacer cumplir reglas y Argo CD para desplegar la aplicación desde Git.

## 1\. Crear el inventario de la imagen con Syft

Primero Docker construye la imagen:

```bash
docker build -t docker.io/pabpereza/supply-chain-demo:dev app/
```

Hay que cambiar ese nombre por el repositorio propio. Syft inspecciona la imagen y escribe un SBOM CycloneDX en formato JSON:

```bash
syft docker.io/pabpereza/supply-chain-demo:dev -o cyclonedx-json=sbom.cdx.json
```

El SBOM describe qué contiene la imagen. En la práctica incluye tanto paquetes —por ejemplo, dependencias y componentes del sistema operativo— como archivos. `jq` sirve para contar y consultar esos datos:

```bash
jq '.components | length' sbom.cdx.json
jq '[.components[] | select(.type != "file")] | length' sbom.cdx.json
jq -r '.components[] | select(.type != "file") | "\(.name) \(.version)"' sbom.cdx.json | head
```

**Objetivo:** disponer de un inventario que luego se pueda analizar y adjuntar a la imagen como evidencia de lo que contiene.

## 2\. Buscar vulnerabilidades con Grype

Grype puede analizar la imagen o el SBOM. En estos ejemplos:

```bash
grype docker.io/pabpereza/supply-chain-demo:dev
```

analiza la imagen indicada, mientras que:

```bash
grype --from docker docker.io/pabpereza/supply-chain-demo:dev
```

la analiza desde el almacenamiento local de Docker. Para analizar el inventario generado por Syft:

```bash
grype sbom:sbom.cdx.json
```

La opción `--fail-on critical` hace que el comando señale un fallo si encuentra vulnerabilidades críticas. `--only-fixed` limita el resultado a las que tienen una corrección disponible:

```bash
grype --fail-on critical --only-fixed sbom:sbom.cdx.json
echo $?
```

En este ejemplo, `0` indica que el análisis pasó ese criterio; `2` indica que se activó el umbral configurado. La práctica también construye una imagen de ejemplo antigua para observar un posible fallo:

```bash
docker build -t vieja attacker/
syft vieja -o cyclonedx-json=vieja.cdx.json
grype --fail-on critical --only-fixed sbom:vieja.cdx.json
```

Grype puede revisar también las dependencias descritas en archivos de bloqueo de un directorio:

```bash
grype dir:.
```

**Objetivo:** detectar vulnerabilidades antes del despliegue y, si se desea, hacer que un análisis con hallazgos críticos corregibles detenga el proceso.

## 3\. Crear claves y activar las reglas de Kyverno

Cosign usa dos claves:

- La **privada** firma y debe mantenerse protegida.
- La **pública** permite verificar las firmas y se incorpora a las políticas de Kyverno.

La práctica genera las claves fuera del repositorio:

```bash
mkdir -p ~/.config/supply-chain-demo && cd ~/.config/supply-chain-demo
COSIGN_PASSWORD="" cosign generate-key-pair
chmod 600 cosign.key
cd -
```

En esta demo la clave no tiene contraseña para evitar introducirla durante la charla. No es una recomendación para producción: allí conviene proteger la clave con un secreto seguro, un KMS o un método keyless, y no guardar nunca la clave privada en el repositorio.

La clave pública se copia para incluirla en las políticas:

```bash
cp ~/.config/supply-chain-demo/cosign.pub .
```

Kyverno aplica tres políticas en el namespace `demo`:

1. **`guardarrailes.yaml` — `ValidatingPolicy`:** comprueba condiciones del manifiesto, como usar una imagen con una referencia válida, no ejecutar el contenedor con privilegios, ejecutarlo como usuario no root, establecer límite de memoria y restringir el registry.
2. **`require-signed.yaml` — `ImageValidatingPolicy`:** exige que la imagen esté fijada por digest y firmada con la clave del pipeline.
3. **`require-sbom.yaml` — `ImageValidatingPolicy`:** exige que la imagen incluya un SBOM CycloneDX firmado con esa misma clave.

Se cargan con `--server-side`:

```bash
kubectl apply --server-side -f policies/kyverno/guardarrailes.yaml
kubectl apply --server-side -f policies/kyverno/require-signed.yaml
kubectl apply --server-side -f policies/kyverno/require-sbom.yaml
```

La práctica define la función `probar` para enviar un Pod de prueba al API server sin guardarlo:

```bash
kubectl apply --dry-run=server -f - <<EOF
...
EOF
```

Con `--dry-run=server`, el objeto pasa por la admisión —incluidas las reglas de Kyverno— pero no queda creado en el clúster. Por ejemplo:

```bash
probar nginx:latest
```

debe ser rechazado por usar `latest`. La función permite probar qué condición falla sin desplegar realmente el Pod.

**Objetivo:** activar controles que el clúster hace cumplir por sí mismo, en lugar de confiar únicamente en que cada persona recuerde aplicarlos.

## 4\. Publicar, fijar por digest, firmar y desplegar

### Publicar y obtener el digest

La imagen se sube al registry:

```bash
docker push docker.io/pabpereza/supply-chain-demo:dev
```

Luego se obtiene el digest del manifiesto y se construye una referencia inmutable:

```bash
DIGEST=$(docker buildx imagetools inspect docker.io/pabpereza/supply-chain-demo:dev --format '{{json .Manifest.Digest}}' | tr -d '"')
IMG=docker.io/pabpereza/supply-chain-demo@$DIGEST
```

Un tag como `:dev` puede apuntar a distintas imágenes con el tiempo; el digest identifica una imagen concreta. Por eso las políticas exigen el digest.

Al probar esa referencia con `probar`, Kyverno debería rechazarla todavía: aún no está firmada ni tiene el SBOM firmado.

### Firmar la imagen y adjuntar el SBOM

Se configura la clave privada de la demo y Cosign firma la imagen:

```bash
export COSIGN_KEY=~/.config/supply-chain-demo/cosign.key
export COSIGN_PASSWORD=""
cosign sign --yes --key $COSIGN_KEY \
  --signing-config signing-config.json $IMG
```

Después se adjunta el SBOM como una atestación CycloneDX firmada:

```bash
cosign attest --yes --key $COSIGN_KEY --type cyclonedx \
  --predicate sbom.cdx.json --signing-config signing-config.json $IMG
```

La firma demuestra que quien posee la clave privada aprobó esa imagen. La atestación vincula el SBOM con el digest de esa imagen. El archivo `signing-config.json` configura esta demo para no usar el registro público de transparencia de Sigstore.

Cosign verifica la firma con la clave pública:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog --insecure-ignore-sct $IMG | jq
```

Si se prueba una imagen que no firmó el pipeline, se espera que falle la verificación:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog --insecure-ignore-sct docker.io/pabpereza/supply-chain-demo:evil
```

Los parámetros `--insecure-ignore-*` se usan aquí porque la demo firma sin Rekor ni su registro de transparencia; no deben interpretarse como una configuración ideal para producción.

### Cambiar Git y sincronizar con Argo CD

En el manifiesto del Deployment se reemplaza la imagen por la referencia con digest. Luego se revisa el cambio y se envía a Git:

```bash
git diff deploy/
git commit -am "deploy: imagen firmada y con SBOM"
git push
```

Argo CD sincroniza el manifiesto con Kubernetes:

```bash
argocd app sync web
argocd app wait web --sync --health --timeout 120
```

Finalmente se comprueba el rollout y el Pod en ejecución:

```bash
kubectl -n demo rollout status deploy/web --timeout=60s
kubectl -n demo get pods -l app=web -o wide
```

**Objetivo:** verificar que el despliegue real use exactamente la imagen aprobada y que Kyverno la acepte solo después de cumplir las reglas.

La práctica también muestra que un Deployment que usa un tag puede fallar durante la sincronización. Kyverno actúa al admitir cambios nuevos: por tanto, un rechazo no elimina automáticamente lo que ya estaba funcionando.

## 5\. Recuperar y volver a analizar el SBOM publicado

En este paso no se reconstruye la imagen. Se recupera del registry la atestación firmada y se extrae su SBOM:

```bash
cosign verify-attestation --key cosign.pub --type cyclonedx \
  --insecure-ignore-tlog --insecure-ignore-sct "$IMG" \
  | head -1 | jq -r .payload | base64 -d | jq .predicate > desplegado.cdx.json
```

Aquí:

- `cosign verify-attestation` verifica y obtiene la atestación.
- `jq` selecciona el campo `payload` y después la propiedad `predicate`.
- `base64 -d` decodifica el contenido.
- La salida se guarda como `desplegado.cdx.json`.

Después `jq` consulta componentes cuyo nombre contiene `xz`, y Grype analiza el SBOM recuperado:

```bash
jq -r '.components[] | select(.name | test("xz")) | "\(.name) \(.version)"' desplegado.cdx.json
grype sbom:desplegado.cdx.json
```

**Objetivo:** mostrar que el inventario puede recuperarse de la imagen desplegada y analizarse más adelante, por ejemplo, si aparece una vulnerabilidad nueva.

## 6\. Limpiar

Al terminar, se eliminan las políticas, el clúster y los SBOM generados:

```bash
kubectl delete -f policies/kyverno/ --ignore-not-found
DOCKER_HOST=unix://$HOME/.lima/supply-lab/sock/docker.sock kind delete cluster --name supply
rm -f sbom.cdx.json vieja.cdx.json desplegado.cdx.json
```

**Objetivo:** dejar el laboratorio limpio y evitar que sus políticas o recursos afecten a otros ensayos.

**En resumen:** Syft inventaría; Grype busca vulnerabilidades; Cosign firma y verifica; Kyverno hace cumplir las reglas al desplegar; y Argo CD aplica desde Git los manifiestos aprobados.

Chatbot App is AI and can make mistakes. Check important information.

Add Anything

Drop your files here