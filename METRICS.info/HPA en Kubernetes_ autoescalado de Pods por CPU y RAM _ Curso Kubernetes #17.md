---
title: "HPA en Kubernetes: autoescalado de Pods por CPU y RAM | Curso Kubernetes #17"
source: "https://www.youtube.com/watch?v=QhHzygBoN_8&t=105s"
author:
  - "[[Pabpereza]]"
published: 2026-02-05
created: 2026-11-24
description: "¿Cómo hace Kubernetes para escalar automáticamente tus aplicaciones cuando hay pico de carga? En este vídeo aprenderás a configurar el Horizontal Pod Autoscaler (HPA) para escalar pods según métricas"
tags:
  - "clippings"
---
![](https://www.youtube.com/watch?v=QhHzygBoN_8)

¿Cómo hace Kubernetes para escalar automáticamente tus aplicaciones cuando hay pico de carga? En este vídeo aprenderás a configurar el Horizontal Pod Autoscaler (HPA) para escalar pods según métricas de CPU y RAM — sin intervención manual.  
  
Repositorio código de ejemplo: https://github.com/pabpereza/quotes  
Entrada por escrito: https://pabpereza.dev/docs/cursos/kubernetes/autoscaling\_en\_kubernetes\_hpa\_vpa\_y\_cluster\_autoscaler  
  
\---  
COMUNIDAD  
💬 Sudoers by pabpereza, la comunidad gratuita del canal en Discord - https://pabpereza.dev/discord  
  
HAZTE MIEMBRO  
🧑‍🧑‍🧒 Conviértete en miembro de este canal: https://www.youtube.com/channel/UCGfKISiN7usAdxvcGivm\_OA/join  
💻 Mi equipo - https://www.amazon.es/shop/pabpereza  
  
DONDE ENCONTRARME  
🧑‍💻 Sitio Web, blog, cursos y documentación - https://pabpereza.dev  
🔗 Todos mis links y redes - https://linktr.ee/pabpereza  
  
VIDEO RELACIONADOS ---  
https://www.youtube.com/playlist?list=PLQhxXeq1oc2k9MFcKxqXy5GV4yy7wqSma  
https://youtu.be/U87QO6VxReA  
https://youtu.be/PCzsfwL0z-Q  
  
CAPÍTULOS  
00:00 Introducción  
01:11 Requisitos e instalación del metric server  
02:32 Requisitos e instalación del metric server  
08:59 Explicación del flujo de HPA con el metric server  
  
#kubernetes #k8s #autoscaling #hpa #devops #metrics-server #cloudnative #pabpereza #tutorial #sre #docker #fastapi #escalado

## Transcript

### Introducción

**0:00** · ¿Te ha pasado que tienes un servicio frito que está al 100% de carga, mientras que tienes otro que parece que está de vacaciones? Y lo peor de todo es que tienes recurso de sobra en tu clúster. El problema no es siempre que falten recursos, sino que muchas veces no se reparten como se deben. Y una herramienta que tiene Cubernetes para esto es el horizontal post Autoscaler o HPA. Esta herramienta no confundir con el escalado del propio clúster con el vertical pod autocaler, sino esta herramienta lo que nos permite es escalar el número de pods que dan servicio en un deployment o en una carga de trabajo concreta.

**0:31** · Y aquí viene lo más importante, porque si quieres que tu factura de la cloud se ajuste, o se automáticamente, aquí estaríamos hablando de cluster autocaler, que este concretamente es el que permitiría escalar el número de nodos que tiene el cluster.

**0:46** · VPA, que es el vertical pod autocaler, que es que el pod en vez de crecer en réplicas aumente en recursos, que se haga más grande, más gordete y la que vamos a ver hoy, aunque estas las dejaremos para más adelante y junto con herramientas como queda para hacer autoescalados más avanzados, pero hoy queremos ver el HPA, que es uno de los más esenciales para empezar y es el que mejor permite repartir la carga de un cluster o de una infraestructura ya predefinida. Vamos al laboratorio.

### Requisitos e instalación del metric server

**1:13** · Bueno, vamos a comenzar este laboratorio primero enseñando los requisitos básicos y es que para que el cluster autoescale o estos recursos de HPA puedan escalar, necesitan el metric Server. Este metric Server básicamente es el servidor de Metric para que cuando hagamos un CCTL top que nos permite mostrar los recursos de CPU o memoria de un nodo o de un poz.

**1:33** · Por ejemplo, de este de aquí me dice, "Oye, me está gastando 5 micores y 71 meg de RAM." o o que quiero saber el gasto de memoria que está haciendo una Raspberry, en mi caso un nodo del clúster, pues básicamente eh hago top node pappet. Entonces, si usáis K3S sí que viene preinstalado. Si estáis usando como en este curso Kis o el cubernetes, como vimos instalado con Cube Admin, podéis instalarlo buscando el repositorio de Matrix Server Cubernetes H, que se llama se llama tal cual.

**2:01** · Ya vemos que nos dice que vale tanto para el horizontal autoscalling como para el vertical y su instalación sería tan simple como aplicar este yamel de aquí, ¿vale? Entonces, si no tenéis el matrix server, pues podéis copiar este comando tal cual y lanzarlo, ¿vale? Igualmente podéis ver si tenéis corriendo el metric server tan fácilmente como en el namespace de C system hacer un getp y debería haber este pod de metric server.

**2:25** · Entonces, esos son los requisitos. Vamos a ver el ejemplo que he preparado y cómo autoescala el cluster. Autoescalado en cubernetes. Para esta práctica voy a usar un repositorio que se llama quotes, que ya lo usé en algunas partes de este curso, si no recuerdo mal. Y básicamente tengo un deployment que es eh esta aplicación en sí misma que simplemente es un backend de Python que muestra citas célebres, una aplicación muy tonta que uso de ejemplo. En la sección de proofs le estuvimos poniendo los readiness proof y los healthcks para funcionar, además de unos cuantos resources.

### Requisitos e instalación del metric server

**2:57** · Yo ya lo tengo ejecutado en este clúster. Recordad, os dejo el link de este repositorio de coach en mi repositorio y en la carpeta deploy tenéis los llames de deployment en el HPA y todos los ejemplos que vamos a ver en la práctica de hoy. Y además os he dejado preparados el ingres para engines si usáis que admin como hemos hecho en la instalación del curso, otraic si optasteis por K3S. En cualquiera de los casos, simplemente la raíz del clúster la redigir así. Aquí tendríais que cambiar por el host name o el nombre de dominio que queráis.

**3:27** · Recordad el capítulo del curso en el que vimos la parte de Ingres. Y bueno, aquí a mi derecha he abierto la parte del autoescalado, que si veis es un objeto tipo autoescaling que se llama horizontal post autocaler. Lo primero que podemos ver en este tipo de objeto es la referencia, es decir, al objeto que va a controlar este HPA para decir,

**3:47** · "Oye, mira este deployment, que es quot deployment, que si veis que coincide con el nombre del deployment como tal, que tiene puesto aquí un número de réplicas, pues yo le voy a decir, mira, según este HPA va a tener mínimo tres réplicas y máximo 10.

**4:01** · Entonces va va a garantizar que siempre haya tres réplicas como tal. Y si se cumplen estos criterios de aquí abajo en azul, tanto en este caso he puesto CPU y memoria para que veáis los ejemplos más básicos, si superan un 50% de la utilización de CPU o de memoria RAM, pues el HPA lo que manda la orden al deployment para que estas réplicas pasen a ser las que el HPA diga.

**4:24** · Y además algunos parámetros más que os he dejado aquí de ejemplo, que básicamente es cuando va a desescalar el tiempo que quieres que pase hasta que vuelva a bajar la réplica. Entonces, simplemente podéis hacer un QCTL apply. Yo ya lo tenía aplicado como tal y si hacéis un QCTL get HPA como tal, es un objeto en sí mismo como cualquier auto de cubernetes. Y ya veis que os sale la referencia al que está marcada el gasto de CPU actual que está haciendo mi objetivo, ¿vale? Y el y el gasto de memoria que está haciendo. ¿Cómo calcula los porcentajes?

**4:54** · Pues es importante también saber que lo hace en base a los requests y los límits porque si no marcamos al menos los límites no sabe el grado porcentual de memoria o de CPU que está gastando en base a esos límites. Es decir, si no tiene un límite, ¿cómo vas a ver cuándo llega ese umbral? Entonces, en este caso podemos ver que está gastando solo esta parte de memoria.

**5:16** · Entonces, me voy a dejar con el comando watch la salida de QCTL get HPA, es decir, para que se lance cada dos segundos esta salida como tal. Eso sí, voy a hacer un temus. Entonces, me voy a dejar aquí arriba la salida HPA y luego para que veáis en otra sección tengo un stress test JavaScript. Os lo voy a enseñar aquí mejor. Y esto es una prueba de carga que yo he lanzado contra uno de los nodos, en este en este caso el maestro, aunque cualquiera, recordemos que cualquiera de los nodos respondería.

**5:45** · Y básicamente lo que hago es probar diferentes URLs de mi aplicación. Esto está usando la tecnología K6 que es de las de la ecosistema de Estelegrafana, Promicius y demás, pues los mismos la misma comunidad desarrolla esta aplicación que está pensada para hacer pruebas de estrés o pruebas de carga. Si queréis, os interesa el tema de K6, ya haré un vídeo más adelante dedicado. Y simplemente lanzando K6 Ran estrés test JS se me ha colado más al final.

**6:10** · Vale, ya veis que lanza grafana K6, empieza a hacer pruebas de carga y empieza a ver que hace generar más intensidad. Luego esto nos da un reporte, incluso tiene una interfaz con PDFs y cosas más chulas que que ya te digo, ya os digo, si os interesa ya lo veremos más adelante, pero bueno, nos permite ver en tiempo real, si os fijáis aquí cada cada 2 segundos que está el watch, vamos a ver cómo actualiza. Vemos como ha empezado a subir la CPU un poco. Ya vemos que la CPU ha subido un montonazo ya.

**6:37** · Entonces, depende del servicio, tenéis que estudiar cómo escala vuestra aplicación o qué consume más en función del número de peticiones, porque igual algunas de Java con sesión muy larga están más RAM u otras, como es este caso de Python que está respondiendo muy rápido, pero tiene muchos hilos abiertos, pues gasta más CPU. Entonces ya veis que ha superado por demasiado el umbral y ya vemos que ha pasado a generar cinc réplicas y si hacemos un kitl depts aquí las tenemos.

**7:03** · Ya van seis réplicas, siete réplicas.

**7:05** · Bueno, se me se me cuesta hasta hacerlo en tiempo real. Vale, esto sigue haciendo la prueba de estrés, siete réplicas. Bueno, ya vemos que como sigue llegando a un nivel de siete réplicas, ya vemos que baja el estrés de la CPU porque se están repartiendo las peticiones y considera que no es necesario poner más y vemos que la memoria solo ha llegado al 31%, así que ya veis que esto gasta poca RAM. El target de CPU se ha estabilizado ya en un 40 45, por eso ha dejado de generar réplicas y hemos sido capaces de contener ese pico de carga en nuestros servicios. Me parece una maravilla, la verdad, el tema del HPA.

**7:35** · Tema de HPA que combinado con una infraestructura de nube que pudiera desplegar más y más pots infinitamente, entre comillas, pues sí que nos permitirá tolerar prácticamente cualquier tipo de carga. Y es realmente, aunque tú uses un servicio gestionado de nube, es eh casi todas las nubes por debajo usan este estos tipos de tecnologías para ser capaces de absorber todo el tráfico elásticamente.

**7:58** · Ya habéis visto la primera prueba de carga y cómo ha hecho las replicados. Lo voy a dejar aquí en vivo para que veáis que en unos minutitos el tiempo tarda en bajar las réplicas. Y esto se debe también a que dentro de la HPA tenemos eh estas etiquetas que no son obligatorias, las he puesto para ejemplificarlo y el estabilization Windows Echo, es decir, es la ventana de estabilización. Es decir, si lleva 3 minutos estable en mi caso, pues ya empieza a bajar. ¿Y baja, ¿cuánto el porcentaje?

**8:25** · Pues yo lo he puesto un 100%, es decir, volvería al nivel de carga mínima que estaba puesto, que era tres réplicas. Esto es muy configurable.

**8:34** · Por defecto vienen 5 minutos, que a mí se me hace un poco largo, por lo menos para la demo, ¿vale? En un entorno de producción es otra cosa. Y son muy configurables este tipo de objetos y lo dicho, estos son más sencillitos a pedir y memoria, pero pueden hacer cualquier virguería, ¿vale? Y si no hay servicios, como hablábamos de queda, nos permite hacer muchas más cosas, ¿vale?

**8:51** · Lo voy a dejar aquí en en segundo plano, luego lo vemos. para que veáis que no os miento, pero para que entendáis el funcionamiento, esto funciona sobre todo por lo que hablábamos de esta pieza, el metric Server y por eso es tan importante, porque al final lo que va haciendo el el HPA, el horizontal post autoescaler, es hacerle pull con constantemente de dame las métricas de estos pods, dame las métricas de estos pods ve que se cumplen estos baremos de

### Explicación del flujo de HPA con el metric server

**9:19** · uso de CPU y RAM, ¿vale?, Pues el propio el propio HPA va al deployment, le dice, "Oye, mira, escala a tantas réplicas." Y a su vez pues el deployment, recordemos que tiene el réplica set, que levanta todos los pots pertinentes y y la verdad que no hay mucho más que decir del HPA.

**9:36** · Ya veis qué herramienta más simple, qué bien funciona. Eso sí, hay que afinarla y por eso siempre recomiendo hacer eh pruebas de estrés para ver cómo se comporta vuestra aplicación. Mira, ya vemos que empiezan a bajar las réplicas a seis, ¿vale? y lo va a hacer gradualmente ese desescalado. Entonces, es muy importante hacer pruebas de carga en vuestras aplicaciones para eh encontrar cuellos de botella, entender cómo escala y cómo gasta recursos en función de el número de peticiones.

**10:03** · Y también importante porque los cuellos de botas suelen ser la base de datos, pues est esta aplicación es muy sencillita, pues cuál no es mejor ejemplo, así que testead vuestras aplicaciones y ajustar los baremos más concretamente a lo que necesitáis vosotros, pero el uso es super básico, lo importante es refinarlo en el día. Y bueno, no me enrollo mucho más porque no tengo mucho más que aportar a este tema. Francamente, si tenéis ejemplos más complejos, dejádmelos, pero lo dicho, para las certificaciones es más que suficiente saber esto.

**10:32** · Es más, ni siquiera a mí el examen no recuerdo me pidieran nada de esto, pero es bueno que sepáis cómo funciona y ya haré un vídeo más más específico con queda para hacerlo en base al número de elementos que quede una cola, latencias y demás. Se pueden usar métricas superclejas también para escalar. Y esto combinado con autoescala, escalamiento nube es una herramienta que te permite o te puede garantizar soportar cualquier carga de forma elástica, sin ningún tipo de dudas. Si os ha gustado este vídeo, está gustando el curso, recordad darle un like.

**11:01** · Tenéis los links a la descripción, el repositorio de coach o al de mi página web paspereza.devangli Tang también por apoyar y nos vemos en el siguiente.