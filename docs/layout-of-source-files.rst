********************************
Composición de un archivo fuente en Solidity
********************************

Los archivos fuente pueden contener un número arbitrario de
:ref:`definiciones de contratos<contract_structure>`, sentencias import_,
:ref:`pragma<pragma>` y directrices :ref:`using for<using-for>` y
:ref:`struct<structs>`, :ref:`enum<enums>`, :ref:`function<functions>`, :ref:`error<errors>`
y definiciones de :ref:`constant variable<constants>`.

.. index:: ! license, spdx

Identificador de licencia SPDX
=======================

La confianza en los contratos inteligentes se puede establecer mejor si sus código fuente está disponible. Debido a que disponer del código fuente disponible siempre roza problemas legales con respecto a derechos de autor, el compilador de Solidity fomenta el uso de `identificadores de licencia SPDX <https://spdx.org>`_ legibles por máquinas.
Cada archivo fuente debería comenzar con un comentario que indique su licencia:

``// SPDX-License-Identifier: MIT``

El compilador no valida que la licencia sea parte de la `lista permitida por SPDX <https://spdx.org/licenses/>`_ pero sí incluye el string provisto en los :ref:`metadatos bytecode <metada>`.  

Si no quiere especificar una licencia o si el código fuente no es de código abierto, por favor use el valor especial ``UNLICENSED``.
Note que ``UNLICENSED`` (uso no permitido, no presente en la lista de licencias de SPDX) es diferente de ``UNLICENSE`` (concede todos los derechos). Solidity sigue la `recomendación de npm <https://docs.npmjs.com/cli/v7/configuring-npm/package-json#license>`_.

Proporcionar este comentario, por supuesto, no lo exime de otras obligaciones relacionadas con licencias como tener que mencionar un encabezado específico de licencias en cada archivo fuente o el titular de los derechos originales.

El comentario es reconocido por el compilador en cualquier parte del archivo al nivel de archivos, pero se recomienda ponerlo en la parte superior del archivo.

<<<<<<< HEAD
Más información sobre cómo usar los identificadores de licencias SPDX puede ser encontrado en el `sitio web de SPDX <https://spdx.org/ids-how>`_.
=======
More information about how to use SPDX license identifiers
can be found at the `SPDX website <https://spdx.dev/learn/handling-license-info/#how>`_.
>>>>>>> english/develop


.. index:: ! pragma

.. _pragma:

Pragmas
=======

La palabra reservada ``pragma`` se usa para permitir ciertas características del compilador o verificaciones. Una directriz pragma siempre es local a un archivo fuente, de modo que tiene que agregar la directriz pragma a todos sus archivos si quiere habilitarlo en el proyecto entero. Si usted :ref:`import<import>` otro archivo, la directriz pragma desde ese archivo *no* se aplica automáticamente al archivo de importación.  

.. index:: ! pragma;version

.. _version_pragma:

Version Pragma
--------------

Los archivos fuente pueden (y deberían) ser anotados con una versión del pragma para rechazar la compilación con versiones futuras del compilador que podrían introducir cambios incompatibles. Nosotros intentamos mantenerlos al mínimo estrictamente necesario e introducirlos de una manera que los cambios en la semántica también requieran cambios en la sintaxis, pero esto no es siempre posible. Debido a ello, siempre es una buena idea leer el registro de modificaciones al menos para los lanzamientos que contengan cambios de ruptura. Estos lanzamientos siempre tienen versiones de la forma ``0.x.0`` o ``x.0.0``.

La versión del pragma se usa de la siguiente manera: ``pragma solidity ^0.5.2;``

Un archivo fuente con la línea de arriba no compila con un compilador anterior a la versión 0.5.2 y tampoco funciona en un compilador que inicie con la versión 0.6.0 (esta segunda condición se agrega al usar ``^``). Debido a que no habrá cambios de ruptura hasta la versión ``0.6.0``, puede estar seguro que su código compila de la forma que esperaba. La versión exacta del compilador no es fija, por lo tanto, las versiones de corrección aun son posibles. 

Es posible especificar reglas más complejas para la versión del compilador, estas siguen la misma sintaxis usaba por `npm <https://docs.npmjs.com/cli/v6/using-npm/semver>`_. 


.. note::
  El uso de la versión del pragma *no* cambia la versión del compilador *ni* habilita o deshabilita características del compilador.
  Simplemente indica al compilador que verifique si su versión corresponde a la requerida por el pragma. Si no corresponde, el compilador emite un error.


.. index:: ! ABI coder, ! pragma; abicoder, pragma; ABIEncoderV2
.. _abi_coder:

ABI Coder Pragma
----------------

Al usar ``pragma abicoder v1`` o ``pragma abicoder v2`` puedes seleccionar entre las dos implementaciones del codificador y decodificador ABI.

El nuevo codificador ABI (v2) es capaz de codificar y decodificar arrays y structs anidadas arbitrariamente. Además de admitir más tipos, implica una validación y comprobaciones de seguridad más amplias, lo que puede dar como resultado mayores costes de gas, pero también una mayor seguridad. Se considera no experimental a partir de Solidity 0.6.0 y está habilitado de forma predeterminada iniciando con Solidity 0.8.0. El antiguo codificador ABI todavía puede ser seleccionado usando ``pragma abicoder v1;``.

El conjunto de tipos soportados por el nuevo codificador es un superset de aquellos soportados por el viejo. Los contratos que lo usan pueden interactuar con aquellos que no lo usan sin limitaciones. Lo opuesto es posible solo siempre y cuando el contrato no-``abicoder v2`` no intente hacer llamadas que requerirían decodificador tipos solamente soportados por el nuevo codificador. El compilador puede detectar esto y emitirá un error. Simplemente con activar ``abicoder v2`` para su contrato es suficiente para hacer que estos errores desaparezcan.     

.. note::

  Este pragma aplica a todo el código definido en el archivo donde está activado, sin reparar en donde ese código termina finalmente. Esto significa que un contrato cuyo archivo fuente está seleccionado para compilar con ABI coder v1 aun puede contener código que usa el nuevo codificador al heredarlo de otro contrato. Esto se permite si los nuevos tipos son solamente usados internamente y no en signaturas de funciones externas.

.. note::

  Hasta Solidity 0.7.4 fue posible seleccionar el ABI coder v2 al usar ``pragma experimental ABIEncoderV2``, pero no era posible seleccionar el codificador v1 explícitamente porque estaba por defecto. 

.. index:: ! pragma; experimental
.. _experimental_pragma:

Pragma Experimental
-------------------

El segundo pragma es el pragma experimental. Puede ser usado para habilitar características del compilador o lenguaje que todavía no están activadas por defecto. Los siguientes pragmas experimentales están actualmente soportados:

.. index:: ! pragma; ABIEncoderV2

ABIEncoderV2
~~~~~~~~~~~~

Debido a que el codificador ABI v2 ya no es considerado experimental, puede ser seleccionado por medio de ``pragma abicoder v2`` desde Solidity 0.7.4 (véase más arriba).  

.. index:: ! pragma; SMTChecker
.. _smt_checker:

SMTChecker
~~~~~~~~~~

Este componente tiene que ser habilitado cuando el compilador de Solidity es construido y, por lo tanto, no está disponible en todos los binarios Solidity. Las :ref:`instrucciones de construcción<smt_solvers_build>` explican cómo activar esta opción. Está activado para todas los lanzamientos PPA de Ubuntu en la mayoría de las versiones, pero no para las imágenes de Docker, los binarios de Windows o los binarios de Linux construidos estáticamente. Se puede activar para solc-js a través de `smtCallback <https://github.com/ethereum/solc-js#example-usage-with-smtsolver-callback>`_ si tiene un SMT solver instalado localmente y ejecute solc-js por medio de node (no a través del navegador). 

Si usa ``pragma experimental SMTChecker;``, entonces obtiene :ref:`avisos de seguridad<formal_verification>` adicionales los cuales se obtienen al consultar un SMT solver.
El componente todavía no soporta todas las características del lenguaje Solidity y probablemente genera muchas advertencias. En caso de que señale características no soportadas, el análisis pudiese no ser enteramente sólido.

.. index:: source file, ! import, module, source unit

.. _import:

Importación de Otros Archivos Fuente
============================

Sintaxis y Semántica
--------------------

Solidity soporta sentencias import para ayudar a modularizar su código, 
similar a aquellas disponibles en JavaScript 
(a partir de ES6). Sin embargo, Solidity no soporta el concepto 
`default export <https://developer.mozilla.org/en-US/docs/web/javascript/reference/statements/export#description>`_.

A un nivel global, puede usar sentencias import de la siguiente forma:

.. code-block:: solidity

    import "filename";

La parte ``filename`` se llama *ruta de importación*. 
Esta sentencia importa todos los símbolos globales desde "filename" (y símbolos importados allí) a el scope global actual (diferente de ES6 pero retrocompatible para Solidity). No se recomienda usar esta forma porque corrompe de modo impredecible el espacio de nombres. Si agregas nuevos elementos de alto nivel dentro de "filename", aparece autoáticamente en todos los archivos que importan de esta manera desde "filename". Es mejor importar símbolos específicos explícitamente. 

El siguiente ejemplo crea un nuevo símbolo global ``symbolName`` cuyos miembros son todos los símbolos globañes desde "filename":

.. code-block:: solidity

    import * as symbolName from "filename";

lo cual resulta en todos los símbolos globales disponibles en el formato ``symbolName.symbol``.

Una variante de esta sintaxis que no es parte de ES6, pero posiblemente útil es:

.. code-block:: solidity

  import "filename" as symbolName;

lo cual es equivalente a ``import * as symbolName from "filename";``.

Si hay una colisión de nombres, puede renombrar símbolos durante la importación. Por ejemplo, el código debajo crea símbolos globales nuevos ``alias`` y ``symbol2`` los cuales referencian ``symbol1`` y ``symbol2`` desde dentro de "filename" respectivamente. 

.. code-block:: solidity

    import {symbol1 as alias, symbol2} from "filename";

.. index:: virtual filesystem, source unit name, import; path, filesystem path, import callback, Remix IDE

Rutas de Importación
------------

A fin de ser capaz de soportar construcciones reproducibles en todas las plataformas, el compilador de Solidity tiene que abstraer los detalles del sistema de archivos en donde los archivos fuente están almacenados. Por esta razón las rutas de importación no hacen referencia directamente a los archivos en el sistema de archivos host. En lugar de ello, el compilador mantiene una base de datos interna (*sistema de archivos virtual* o *VFS* de forma resumida) donde cada unidad fuente se asigna a un único *nombre de unidad fuente* el cual es un identificador opaco y desestructurado. La ruta de importación especificada en una sentencia import se traduce a un nombre de unidad fuente y usada para encontrar la unidad de fuente correspondiente en esta base de datos.  

Al usar la API :ref:`Standard JSON <compiler-api>` es posible proveer directamente los nombres y contenido de todos los archivos fuentes como parte de la entrada del compilador. En este caso, los nombres de unidad fuente son verdaderamente arbitrarios. Si, de todas maneras, quiere que el compilador encuentre y cargue el código fuente en el VFS automáticamente, sus nombres de unidad fuente necesitan estar estructurados de una manera que permita a un :ref:`import callback
<import-callback>` localizarlos.
Cuando se usa el compilador en la línea de comandos el import callback por defecto soporta solamente el código fuente que se carga desde el sistema de archivos host, lo cual significa que sus nombres de unidad fuente deben ser rutas.
Algunos ambientes proveen custom callbacks que son más versátiles.
Por ejemplo, el `Remix IDE <https://remix.ethereum.org/>`_ provee una que te permite `importar archivos desde HTTP, IPFS y Swarm URLs o referir directamente a paquetes el el registro de NPM <https://remix-ide.readthedocs.io/en/latest/import.html>`_.

Para una descripción completa del sistema de archivos virtuales y la lógica de resolución de rutas usadas por el compilador véase :ref:`Resolución de Rutas <path-resolution>`. 

.. index:: ! comment, natspec

Comentarios
========

Comentarios de una sola línea (``//``) y comentarios de múltiples líneas (``/*...*/``) son posibles.

.. code-block:: solidity

    // Esto es un comentario de una sola línea.

    /*
    Esto es un
    comentario de múltiples líneas.
    */

.. note::
  Un comentario de una sola línea finaliza por cualquier terminador de línea unicode (LF, VF, FF, CR, NEL, LS, o PS) en codificación UTF-8. El terminador es aún parte del código fuente luego del comentario, así que si no es un símbolo ASCII (se trata de NEL, LS y PS), conducirá a un parser error. 

Adicionalmente, hay otro tipo de comentario llamado comentario NatSpec, el cual se detalla en la :ref:`guía de estilo<style_guide_natspec>`. Son escritos con una triple barra diagonal (``///``) o un bloque de asteriscos dobles (``/** ... */``) y deberían ser usados directamente sobre las declaraciones de funciones o sentencias.
