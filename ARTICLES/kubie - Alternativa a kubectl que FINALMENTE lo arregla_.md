---
title: "kubie - Alternativa a kubectl que FINALMENTE lo arregla?"
source: "https://www.youtube.com/watch?v=kiRTQVUzkh8"
author:
  - "[[Pelado Nerd]]"
published: 2021-02-26
created: 2026-11-20
description: "Hoy hablamos de kubie, una pequeña herramienta para manejar contextos de kubectl, y resuelve algo que hace rato me vengo quejando.https://github.com/sbstp/kubie--Repo con todos los archivos que u"
tags:
  - "clippings"
---
![](https://www.youtube.com/watch?v=kiRTQVUzkh8)

Hoy hablamos de kubie, una pequeña herramienta para manejar contextos de kubectl, y resuelve algo que hace rato me vengo quejando.  
  
https://github.com/sbstp/kubie  
  
\--  
Repo con todos los archivos que uso: https://github.com/pablokbs/peladonerd  
Merchandising Pelado Nerd: https://merch.peladonerd.com  
  
Micrófono: Rode VideoMicro + Zoom H1N  
Cámara: Sony A7 Mark III  
Lente: Sony 28-70mm 3.5  
Laptop: Macbook Pro 16'' 2019  
  
Puedes encontrar todos mis links en https://peladonerd.com

## Transcript

**0:00** · el reciente viernes dos minutos un poco perdido ese camino ese ese objetivo que tenemos de estar dentro de los dos minutos que por suerte nunca lo hemos pasado hemos estado siempre muy cerca pero nunca lo hemos pasado así que vamos a ver una pequeña herramienta es que obviamente no va a dejar dentro de esos dos minutos sin ningún problema me tengo fe vamos a hablar de club \[Música\] \[Aplausos\] \[Música\]

**0:29** · en un vídeo anteriores sobre cómo manejar club con fix y con textos en cuadrantes como un pro que hable de una de las cosas que más me molesta de la forma en que esquivel trabaja que es que si o si todos tus clusters y todos tus contextos tienen que estar en un solo archivo no me acuerdo si en este vídeo tuve unos comentarios sobre una herramienta que nos ayudaron a poner acá gracias cacho el editor por supuesto como nunca la movilidad y nunca no molida vamos a poner el contador en los dos minutos

**0:58** · mucha gente lo que hace que cuando quiere trabajar con contextos es cambiar ese contexto para eso hay varias herramientas yo mostré un axioma cute select de ejecutar select que muestra todos los contextos que tienes y simplemente los seleccionadas de agente de ahora en adelante si hacéis get loud' automáticamente ya está seleccionado ese contexto en el caso que quieres seleccionar otro pues de nuevo corral club selecto y seleccionarlo o puedes pasarlo como la línea comando puede ser que si tiene menos menos context mini que get loud' generalmente eso lo que

**1:28** · hago yo tengo varios clusters que estoy constantemente trabajando en ellos por lo que a mí no me sirve cambiarme de contexto y dejar ese terminal abierta con ese contexto generalmente yo siempre le paso - con text y el contexto que quiero obviamente eso es medio engorroso porque tenés que estar escribiendo mucho para hacer algo en un clúster pero para mí me

**1:46** · sirve porque eso generalmente me ayuda a no equivocarme al estar viendo el clúster siempre me aseguro de no estar corriendo al comando correcto incorrecto en el clúster incorrecto pero obviamente hay gente que le gusta pasarte de contexto y estar siempre trabajando en un mismo clúster pero estaría bueno que te muestre de alguna forma tu terminal en qué contexto estás momentos y concluí lo que puedes hacer es exactamente esto cambiarte un contexto y que te muestre en la terminal en qué contexto estás entonces puede hacer que ubi city ex mini r

**2:15** · y fíjate que a la izquierda me agregó en la terminal la que estoy bien y en lines page en el que estoy o sea que dar juego para el club si tira del inquieto potts por ejemplo y me va a mostrar todos los posts que están en es de nsn space y en ese cluster está bueno porque eso en realidad te crea una terminal nueva dentro al determinar en la que estabas porque te puede tocar control de para salir de ahí no solamente puedes seleccionar el contexto sino que también puedes seleccionar el name space entonces puede hacer n subsisten por ejemplo eso te va a

**2:40** · crear una terminal ahí adentro y fíjate que ya está seleccionado mini club y el line space subsisten y ahora puede ser que visite el get potts y no tengo que especificar el nine space porque me va a usar el que estaba seleccionado antes hasta ahí ya creo que es bastante superior a las otras alternativas ya que en para mí está re bueno tener esa información ahí nomás al lado la terminal y el hecho de que sea una terminal nueva y puede ser control de para salir está buenísimo también otra cosa que está buena como un eje racing es que puedes pasarles diferentes directorios donde puede ir y

**3:07** · buscar archivo de club con fit como dije recién por defecto si tienen solamente el archivo barra que barra config y baleares van a estar ahí todos tus contextos esto es bastante engorroso porque a veces te pasa en un club config y no te queda otra que agarrar el archivo y meter tu club confía adentro seleccionar el contexto asegurarte que no esté seleccionado dos veces es como re complicado crear ese

**3:28** · super archivo con todos los clusters entonces es que wii te salva de esta forma tiene un archivo configuración que lo puedes editar haciendo aquí edith con fit o si no puedes editar el mismo archivo que está en barra koubbi punto llamen y por defecto tiene estos valores fíjate que ya de una te busca llamen en estos directorios o sea que yo podría crear un directorio barrapunto que va con fix y meter archivos separados de clusters ahí y que lo va a reconocer por ejemplo acá yo tengo mi archivo de mezclas térmicas casero es x el vídeo el otro día acá y

**3:57** · como dije la única forma de meter esto en el contexto actual es toque abrir este archivo copiar el contenido meterlo en el confín y seleccionar el contexto correctamente eso no rinde y no escala entonces vamos a hacer lo siguiente vamos a ir con fix vamos a mover ese archivo ahí y ahora puedo hacer que un city ex y fíjate que automáticamente me detectó ese nuevo clúster por ser club y city ex

**4:26** · casero este homenaje y ya estoy dentro de ese clásico y puede ser que el get loud' y estoy hay otra pequeña herramienta que tiene también club y es club y edit que te permite editar un contexto directamente pero fíjate en realidad lo que hace es abrir el archivo o sea que ese archivo también tiene otros contextos que hay que tener cuidado finalmente también tiene un comando para chequear la sintaxis de tu club con fit con club y link y finalmente también se

**4:49** · puede actualizar automáticamente con kubica update así que bueno por supuesto nos mantuvimos entre dos minutos nunca hemos pasado y nunca nos va a pasar lupe cómo andás tanto tiene más o menos depende la cámara ciega está ciega nuevamente pero bueno como andas tanto tiempo bien cansada de que cansada que

**5:05** · extraño mucho las compren inscribir una conferencia yo también quería una conferencia ya que vamos a ir vamos a ir dentro de poco hay una conferencia te voy a llevar te prometo que te voy a llevar a la próxima conferencia del club que por cierto la club con va a ser virtual esto no está sponsoreado por ella ni nada de eso aquellos que puedan ir y pedir el permiso de trabajo aprovechan que es virtual y que todo mundo puede ir prácticamente gratis si van a visa me voy a estar ahí

**5:34** · bueno así que eso foto colores propias aprendido 17 para mañana daremos 7 gustos ándale no me buscas no me buscas empezamos si no vas al club y usas sphere y que es

**5:51** · la versión esférica del club y que para manejar esos contextos en realidad da vueltas te pide que de vuelta a girar la computadora encuentra los contextos después cuando corran como no se ejecutan todos lados y por rast el de led y si tandil y tns que existen por hace todo

**6:13** · una dependencia circular para psoe porque es una esfera esférica ah sí