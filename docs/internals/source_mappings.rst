.. index:: source mappings

**********************
Asignaciones de origen
**********************

Como parte de la salida de AST, el compilador proporciona el rango del código
fuente que está representado por el nodo respectivo en el AST. Esto se puede usar
para varios propósitos, desde herramientas de análisis estático que informan errores
en función del AST hasta herramientas de depuración que resaltan las variables
locales y sus usos.

Además, el compilador también puede generar una asignación desde el código de
bytes hasta el rango en el código fuente que generó la instrucción. Esto es de nuevo
importante para las herramientas de análisis estático que operan a nivel de
bytecode y para mostrar la posición actual en el código fuente dentro de un
depurador o para el manejo de puntos de interrupción. Este mapeo también
contiene otra información, como el tipo de salto y la profundidad del modificador (ver
más abajo).

Ambos tipos de asignaciones de origen utilizan identificadores integer para referirse
a los archivos de origen. El identificador de un archivo de origen se almacena en
``output['sources'][sourceName]['id']`` donde ``output`` es la salida del
compilador standard-json analizada como JSON.
Para algunas rutinas de utilidad, el compilador genera archivos de origen "internos"
que no forman parte de la entrada original, pero a los que se hace referencia desde las
asignaciones de origen. Estos archivos de origen junto con sus identificadores pueden
obtenerse a través de ``output['contracts'][sourceName][contractName]['evm']['bytecode']['generatedSources']``.

<<<<<<< HEAD
.. nota ::
    En el caso de instrucciones que no están asociadas a ningún archivo fuente en particular,
    la asignación de origen asigna un identificador integer de ``-1``. Esto puede ocurrir
    para secciones de código de bytes que provienen de sentencias de ensamblaje en línea generadas por el compilador.
=======
.. note::
    In the case of instructions that are not associated with any particular source file,
    the source mapping assigns an integer identifier of ``-1``. This may happen for
    bytecode sections stemming from compiler-generated inline assembly statements.
>>>>>>> english/develop

Las asignaciones de origen dentro del AST utilizan la siguiente
notación:

``s:l:f``

Donde ``s`` es el byte-offset al inicio del rango en el archivo de origen,
``l`` es la longitud del rango de origen en bytes y ``f`` es el índice de
origen mencionado anteriormente.

La codificación en la asignación de origen para el código de bytes es más
complicada: Es una lista de ``s:l:f:j:m`` separados por ``;``. Cada uno de estos
elementos corresponde a una instrucción, es decir, no se puede utilizar el offset de
bytes, sino que hay que utilizar el offset de instrucciones (las instrucciones push son
más largas que un solo byte). Los campos ``s``, ``l`` y ``f`` son como los anteriores. ``j`` puede ser
``i``, ``o`` o ``-`` lo que significa que una instrucción de salto entra en una
función, vuelve de una función o es un salto normal como parte de, por ejemplo, un loop.
El último campo, ``m``, es un integer que denota la "profundidad del modificador". Esta profundidad
se incrementa cada vez que se introduce el marcador de posición (``_``)
y disminuye cuando se vuelve a dejar. Esto permite a los debuggers rastrear casos complicados
como el mismo modificador siendo utilizado dos o múltiples veces en marcadores de posición
siendo usadas en un solo modificador.

Para comprimir estas asignaciones de origen, especialmente para bytecode, se
utilizan las siguientes reglas:

- Si un campo está vacío, se utiliza el valor del elemento precedente.
- Si falta un ``:``, todos los campos siguientes se consideran vacíos.

Esto significa que las siguientes asignaciones de origen representan la misma información:

``1:2:1;1:9:1;2:1:2;2:1:2;2:1:2``

``1:2:1;:9;2:1:2;;``

Es importante tener en cuenta que cuando se utiliza :ref:`verbatim <yul-verbatim>`,
las asignaciones de origen no serán válidas: El builtin se considera una única
instrucción en lugar de potencialmente múltiples.
