##################################
Expresiones y Estructuras de Control
##################################

.. index:: ! parameter, parameter;input, parameter;output, function parameter, parameter;function, return variable, variable;return, return


.. index:: if, else, while, do/while, for, break, continue, return, switch, goto

Estructuras de Control
===================

La mayoría de estructuras de control conocidas de los lenguages que usan corchetes está disponsible en Solidity:

Existen: ``if``, ``else``, ``while``, ``do``, ``for``, ``break``, ``continue``, ``return``, con
la semántica habitual conocida de C o JavaScript.

Solidity tambien admite control de excepciones en la forma de instrucciones ``try``/``catch``,
pero solo para :ref:`llamadas a funciones externas <external-function-calls>` y
las llamadas de la creación de contratos.  Errores se pueden crear usando la :ref:`sentencia revert <revert-statement>`.

Los paréntesis no se pueden omitir para condicionales, pero sí los corchetes
alrededor de los cuerpos de las declaraciones sencillas.

Hay que tener en cuenta que no hay conversión de tipos no boolean a boolean como 
hay en C y JavaScript, por lo que ``if (1) { ... }`` *no* es válido 
en Solidity.

.. index:: ! function;call, function;internal, function;external

.. _function-calls:

Llamadas a funciones
==============

.. _internal-function-calls:

Llamadas a funciones internas
-----------------------

Las funciones del contrato actual pueden ser llamadas directamente ("internamente") y, 
también, recursivamente como se puede ver en este ejemplo sin sentido funcional::

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    // Esto reportará un aviso
    contract C {
        function g(uint a) public pure returns (uint ret) { return a + f(); }
        function f() internal pure returns (uint ret) { return g(7) + f(); }
    }

Estas llamadas a funciones son traducidas en simples saltos dentro de la máquina virtual de Ethereum (EVM). Esto tiene 
como consecuencia que la memoria actual no se limpia, así que pasar referencias 
de memoria a las funciones llamadas internamente es muy eficiente. Solo las funciones del mismo 
contrato pueden ser llamadas internamente.

Todavía hay que evitar recursion excesiva, como todos las llamadas de funciones internas
usan al menos una ranura de pila y solo hay 1024 ranuras disponible.

.. _external-function-calls:

Llamadas a funciones externas
-----------------------

Las funciones también pueden llamadas usando la notación this.g(8); and c.g(2); donde c es la instancia de un contrato y g
es la funcion que pertenece c. Llamando la funcion ``g`` de cualquier
manera resulta en una llamada externa, usando una llamada de mensaje y no por saltos directamente.
Hay que tener cuenta que las llamadas de funciones en ``this`` no se puede usar en el constructor,
ya que el contrato actual aún no se ha creado todavía.

Funciones de otros contratos tienen que ser llamado externamente. Para una llamada externa,
todos los arguments de función deben copiarse a la memoria.

.. note::
    Una llamada de la función de un contrato a otro no crea su propia transacción,
    es una llamada de mensaje como parte de la transacción completa.

Cuando se llama a funciones de otros contratos, la cantidad de Wei enviada 
con la llamada y el gas pueden especificarse con las opciones especiales ``{value: 10, gas: 10000}``.
Hay que tener cuenta que se desaconseja especifar valores de gas explícitamente, 
ya que los costos de gas de opcodes pueden cambiar en el futuro. Cualquier Wei que envíe se agrega
al saldo total de ese contrato.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract InfoFeed {
        function info() public payable returns (uint ret) { return 42; }
    }

    contract Consumer {
        InfoFeed feed;
        function setFeed(InfoFeed addr) public { feed = addr; }
        function callFeed() public { feed.info{value: 10, gas: 800}(); }
    }

Debe utilizar el modificador ``payable`` con la función ``info`` porque
de lo contrario la opción ``valor`` no estaría disponible.

.. warning::
  Hay que tener cuidado que ``feed.info{value: 10, gas: 800}`` solo establezca 
  localmente el ``value`` y la cantidad de ``gas`` enviado con la llamada de la función, y 
  los paréntesis al final realizan la llamda actual. Por lo tanto,
  ``feed.info{value: 10, gas: 800}`` no ejecuta la función y se pierden los ajustes del
  ``value`` y ``gas``, solo  ``feed.info{value: 10, gas: 800}()`` realiza la llamada de la función.

Debido al hecho que el EVM considera una llamada a un contrato inexistente
siempre tenga éxito, Solitiy utiliza el ``extcodesize`` opcode para comprobar 
que el contrato que está a punto de ser llamado existe realmente (contiene codigo) 
y causa excepción si no lo hace. Esta comprobación se omite si los datos devueltos se descodifican 
después de la llamada y, por tanto, el descodificador ABI detectará el caso de un contrato no existente.

Hay que tener cuenta que esta comprobación no se realiza en caso de :ref:`llamadas de bajo nivel <address_related>`
que operan en las direcciones en lugar de instancias de contrato.

.. note::
    Hay que tener cuidado al utilizar llamadas de alto nivel para 
    :ref:`contratos precompilados <precompiledContracts>`, 
    dado que el compilador los considera no existentes según 
    la lógica de arriba aunque ejecuten código y puedan devolver datos.

Las llamadas a funciones también causan excepciones si el propio contrato llamado 
arroja una excepción o se queda sin gas.

.. warning::
    Cualquier interacción con otro contrato supone un peligro potencial, especialmente
    si el código fuente del contrato no se conoce por adelantado. El contrato actual 
    entrega el control al contrato llamado y eso puede potencialmente hacer casi cualquier cosa. 
    Incluso si el contrato llamado hereda de un contrato principal conocido, el contrato de herencia 
    solo es necesario para tener una interfaz correcta. Sin embargo, la ejecución del contrato puede 
    ser completamente arbitraria y, por lo tanto, plantea un peligro. Además, esté preparado en caso de que 
    convoque otros contratos de su sistema o incluso volver al contrato de llamada antes de que retorne la primera llamada.
    Esto significa que el contrato llamado puede cambiar las variables de estado del contrato de llamada a través de sus funciones. 
    Escriba sus funciones de forma que, por ejemplo, las llamadas a las funciones externas se produzcan después de cualquier cambio 
    en las variables de estado en su contrato, por lo tanto, su contrato no es vulnerable a una explotación de reentrada.

.. note::
    Antes de Solidity 0.6.2, la forma recomendada de especificar el valor y el gas era 
    use ``f.value(x).gas(g)()``. Esto se volvió obsoleto en Solidity 0.6.2 y ya no es 
    posible desde Solidity 0.7.0.

Llamadas a funciones con parámetros con nombre
---------------------------------------------

Los argumentos de llamada a funciones pueden darse por nombre, en cualquier orden, 
si están encerrados entre ``{ }``, como se puede ver en el siguiente ejemplo. La lista 
de argumentos tiene que coincidir por nombre con la lista de parámetros de la declaración de función, 
pero puede estar en orden arbitrario.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        mapping(uint => uint) data;

        function f() public {
            set({value: 2, key: 3});
        }

        function set(uint key, uint value) public {
            data[key] = value;
        }
    }

Nombres omitidos en definiciones de funciones
--------------------------------

Se pueden omitir los nombres de los parámetros y los valores retornos en la declaración de la función. 
Los elementos con nombres omitidos seguirán presentes en la pila, pero 
no se puede acceder a ellos por su nombre. Un nombre de valor retorno omitido 
todavía puede devolver un valor al llamador mediante la instrucción `return'.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        // nombre omitido para parámetro
        function func(uint k, uint) public pure returns(uint) {
            return k;
        }
    }


.. index:: ! new, contracts;creating

.. _creating-contracts:

Creando contratos mediante ``new``
==============================

Un contrato puede crear otros contratos usando la palabra reservada ``new``. 
El código completo del contrato que se está creando tiene que ser conocido de antemano, 
por lo que no son posibles las dependencias de creación recursivas.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) payable {
            x = a;
        }
    }

    contract C {
        D d = new D(4); // Se ejecutará como parte del constructor de C

        function createD(uint arg) public {
            D newD = new D(arg);
            newD.x();
        }

        function createAndEndowD(uint arg, uint amount) public payable {
             // Envía Ether junto con la creación
            D newD = new D{value: amount}(arg);
            newD.x();
        }
    }

Como se ve en el ejemplo, es posible traspasar Ether a la creación usando la opción ``.value()``,
pero no es posible limitar la cantidad de gas. Si la creación falla
(debido al desbordamiento de la pila, falta de balance o cualquier otro problema), se dispara una excepción.

Creaciones de contratos salted / create2
-----------------------------------

Al crear un contrato, la dirección del contrato se calcula a partir de 
la dirección del contrato de creación y un contador que se incrementa con 
cada creación de contrato.

Si especifica la opción ``salt`` (un valor bytes32), la creación 
de contratos utilizará un mecanismo diferente para encontrar la dirección del nuevo contrato:

Calculará la dirección a partir de la dirección del contrato de 
creación, el valor de salt dado, el código de bytes (de creación) del contrato creado y los 
argumentos del constructor.

En particular, no se utiliza el contador (“nonce”). Esto permite una mayor flexibilidad 
en la creación de contratos: Puede derivar la dirección del nuevo contrato antes de crearlo. 
Además, puede confiar en esta dirección también en caso de que la creación de contratos cree 
otros contratos mientras tanto.

El principal caso de uso aquí son los contratos que actúan como jueces para las interacciones 
fuera de la cadena, que solo deben crearse si hay una disputa.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) {
            x = a;
        }
    }

    contract C {
        function createDSalted(bytes32 salt, uint arg) public {
            // Esta complicada expresión solo te dice cómo la dirección
            // se puede precalcular. Solo está ahí para ilustrar.
            // En realidad, solo necesita ``new D{salt: salt}(arg)``.
            address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(D).creationCode,
                    abi.encode(arg)
                ))
            )))));

            D d = new D{salt: salt}(arg);
            require(address(d) == predictedAddress);
        }
    }

.. warning::
    Hay algunas peculiaridades en relación con la creación salted. Un contrato puede ser recreado
    en la misma dirección después de haber sido destruido. Sin embargo, es posible 
    que ese contrato recién creado tuviera un código de bytes diferente incluso aunque el código 
    de byte de creación ha sido el mismo (lo que es un requisito porque de lo contrario, la dirección cambiaría). 
    Esto se debe al hecho de que el constructor puede consultar el estado externo que podría haber cambiado entre 
    las dos creaciones e incorporarlo al código de bytes implementado antes de que se almacene.

Orden de la evaluación de expresiones
==================================
El orden de evaluación de expresiones no se especifica (más formalmente, el orden 
en el que los hijos de un nodo en el árbol de la expresión son evaluados no es especificado. 
Eso sí, son evaluados antes que el propio nodo). Solo se garantiza que las sentencias se ejecutan 
en orden y que se hace un cortocircuito para las expresiones booleanas. Ver :ref:`order` para más información.

.. index:: ! assignment

Asignación
==========

.. index:: ! assignment;destructuring

Asignaciones para desestructurar y retornar múltiples valores
-------------------------------------------------------

Solidity internamente permite tipos tupla, i.e.: una lista de objetos de, 
potencialmente, diferentes tipos cuyo tamaño es constante en tiempo de compilación. 
Esas tuplas pueden ser usadas para retornar múltiples valores al mismo tiempo.
Pueden asignarse a variables recién declaradas o variables preexistentes ( o LValues en general).

Las tuplas no son tipos propios en Solidity, Se pueden usar para formar 
agrupaciones sintácticas de expresiones.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        uint index;

        function f() public pure returns (uint, bool, uint) {
            return (7, true, 2);
        }

        function g() public {
            // Variables declaradas con tipo y asignadas desde la tupla devuelta,
            // no es necesario especificar todos los elementos (pero el número debe coincidir).
            (uint x, , uint y) = f();
            // Truco común para intercambiar valores: no funciona para tipos de almacenamiento que no son de valor.
            (x, y) = (y, x);
            // Los componentes se pueden omitir (también para declaraciones de variables).
            (index, , ) = f(); // Sets the index to 7
        }
    }

No es posible mezclar declaraciones de variables y asignaciones sin declaración, 
i.e., lo siguiente no es válido: ``(x, uint y) = (1, 2);``

.. note::
    Antes de la versión 0.5.0 era posible asignar a tuplas de menor tamaño, ya sea
    llenando a la izquierda o en el lado derecho (que alguna vez estaba vacío). 
    Esto ahora no está permitido, por lo que ambas partes tienen que tener el mismo número de componentes.

.. warning::
<<<<<<< HEAD
    Hay que tener cuidado al asignar a varias variables al mismo tiempo cuando 
    se involucran tipos de referencia, ya que podría provocar un 
    comportamiento de copia inesperado.
=======
    Be careful when assigning to multiple variables at the same time when
    reference types are involved, because it could lead to unexpected
    copying behavior.
>>>>>>> english/develop

Complicaciones en Arrays y Structs
------------------------------------

<<<<<<< HEAD
La sintaxis de asignación es algo más complicada para tipos sin valor como arrays y structs,
incluyendo ``bytes`` y ``string``, mira :ref:`localización de datos y comportamiento de asignaciones <data-location-assignment>` para detalles.
=======
The semantics of assignments are more complicated for non-value types like arrays and structs,
including ``bytes`` and ``string``, see :ref:`Data location and assignment behavior <data-location-assignment>` for details.
>>>>>>> english/develop

En el siguiente ejemplo la llamada a ``g(x)`` no tiene ningún efecto en ``x`` porque crea 
una copia independiente del valor de almacenamiento en la memoria. Sin embargo, ``h(x)`` 
modifica con éxito ``x`` porque solo se pasa una referencia y no una copia.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        uint[20] x;

        function f() public {
            g(x);
            h(x);
        }

        function g(uint[20] memory y) internal pure {
            y[2] = 3;
        }

        function h(uint[20] storage y) internal {
            y[3] = 4;
        }
    }

.. index:: ! scoping, declarations, default value

.. _default-value:

Scoping y declaraciones
========================

Una variable cuando se declara tendrá un valor inicial por defecto que, 
representado en bytes, será todo ceros. Los valores por defecto de las 
variables son los típicos "estado-cero" cualquiera que sea el tipo. Por ejemplo, 
el valor por defecto para un ``bool`` es ``false``. El valor por defecto para un 
``uint`` o ``int`` es ``0``. Para arrays de tamaño estático y ``bytes1`` hasta 
``bytes32``, cada elemento individual será inicializado a un valor por defecto según sea su tipo.
Para arrays de tamaño dinámico, ``bytes``y ``string``, el valor por defecto es un array o string vacío.
Para el tipo ``enum``, el valor por defecto es su primer miembro.

El alcance en Solidity sigue las reglas de alcance generalizadas de C99 
(y muchos otros lenguajes): Las variables son visibles desde el punto justo 
después de su declaración hasta el final del bloque más pequeño ``{ }`` que contiene la declaración. 
Como excepción a esta regla, las variables declaradas en la parte de inicialización de un for-loop 
solo son visibles hasta el final del for-loop.

Las variables que son similares a los parámetros (parámetros de función, parámetros modificadores,
parámetros de captura, ...) son visibles dentro del bloque de código que sigue - 
el cuerpo de la función/modificador para una función y parámetro modificador y el bloque 
de captura para un parámetro de captura.

Las variables y otros elementos declarados fuera de un bloque de código, por ejemplo, funciones, 
contratos, tipos definidos por el usuario, etc., son visibles incluso antes de que se declararan. 
Esto significa que puede usar variables de estado antes de que se declaren y llamar a funciones de forma recursiva.

Como consecuencia, los siguientes ejemplos se compilarán sin advertencias, ya que 
las dos variables tienen el mismo nombre pero ámbitos disjuntos.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function minimalScoping() pure public {
            {
                uint same;
                same = 1;
            }

            {
                uint same;
                same = 3;
            }
        }
    }

Como ejemplo especial de las reglas de alcance de C99, tenga en cuenta que en lo siguiente, 
la primera asignación a ``x`` en realidad asignará la variable externa y no la interna. 
En cualquier caso, recibirá una advertencia sobre la variable externa que se sombrea.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Esto informará de una advertencia
    contract C {
        function f() pure public returns (uint) {
            uint x = 1;
            {
                x = 2; // esto se asignará a la variable externa
                uint x;
            }
            return x; // x tiene valor 2
        }
    }

.. warning::
    Antes de la versión 0.5.0, Solidity seguía las mismas reglas de ámbito que JavaScript, 
    es decir, una variable declarada en cualquier lugar dentro de una función estaría en el ámbito 
    para toda la función, independientemente de dónde se haya declarado. En el ejemplo siguiente se muestra 
    un fragmento de código que solía compilar pero conduce a un error a partir de la versión 0.5.0.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Esto no se compilará
    contract C {
        function f() pure public returns (uint) {
            x = 2;
            uint x;
            return x;
        }
    }


.. index:: ! safe math, safemath, checked, unchecked
.. _unchecked:

Aritmética comprobada o no comprobada
===============================

Un desbordamiento o subflujo es la situación en la que el valor resultante de una operación aritmética, 
cuando se ejecuta en un entero sin restricciones, cae fuera del rango del tipo de resultado. 

Antes de Solidity 0.8.0, las operaciones aritméticas siempre se envolvían en caso de 
desbordamiento o desbordamiento, lo que llevaría a un uso generalizado de bibliotecas 
que introducen comprobaciones adicionales.

Desde Solidity 0.8.0, todas las operaciones aritméticas se revierten por defecto en el 
subdesbordamiento o desbordamiento, lo que hace innecesario el uso de estas bibliotecas.

<<<<<<< HEAD
Para obtener el comportamiento anterior, se puede utilizar un bloque ``unchecked``:
=======
To obtain the previous behavior, an ``unchecked`` block can be used:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract C {
        function f(uint a, uint b) pure public returns (uint) {
            // Esta resta se envolverá en el desbordamiento.
            unchecked { return a - b; }
        }
        function g(uint a, uint b) pure public returns (uint) {
            // Esta resta se revertirá en caso de subdesbordamiento.
            return a - b;
        }
    }

La llamada a ``f(2, 3)`` devolverá  ``2**256-1``, mientras que ``g(2, 3)`` 
causará una aserción fallida.

El bloque ``unchecked`` se puede usar en todas partes dentro de un bloque, pero no como reemplazo de un bloque. 
Tampoco se puede anidar.

La configuración solo afecta a las instrucciones que se encuentran sintácticamente dentro del bloque. 
Las funciones llamadas desde un bloque ``unchecked`` no heredan la propiedad.

.. note::
    Para evitar la ambigüedad, no puede usar ``_;`` dentro de un bloque ``unchecked``.

Los siguientes operadores provocarán un error de aserción en el desbordamiento o subdesbordamiento 
y se ajustarán sin error si se utilizan dentro de un bloque descomprobada:

``++``, ``--``, ``+``, binario ``-``, unario ``-``, ``*``, ``/``, ``%``, ``**``

``+=``, ``-=``, ``*=``, ``/=``, ``%=``

.. warning::
    No es posible desactivar la comprobación de división por cero 
    o módulo por cero utilizando el bloque ``unchecked``.

.. note::
   Los operadores Bitwise no realizan comprobaciones de desbordamiento o subdesbordamiento. 
   Esto es particularmente visible cuando se usan desplazamientos bitwise (``<<``, ``>>``, ``<<=``, ``>>=``) 
   en lugar de la división entera y la multiplicación por una potencia de 2. 
   Por ejemplo, ``type(uint256).max << 3`` no se revierte aunque ``type(uint256).max * 8`` lo haría.

.. note::
    La segunda instrucción en ``int x = type(int).min; -x;`` dará lugar a un desbordamiento 
    porque el rango negativo puede contener un valor más que el rango positivo.

Las conversiones de tipos explícitos siempre se truncarán y nunca causarán una aserción errónea 
con la excepción de una conversión de un entero a un tipo enum.

.. index:: ! exception, ! throw, ! assert, ! require, ! revert, ! errors

.. _assert-and-require:

Manejo de errores: Afirmar, Requerir, Revertir y Excepciones
======================================================

Solidity utiliza excepciones de reversión de estado para controlar los errores. 
Tal excepción deshace todos los cambios realizados en el estado de la llamada actual (y todas sus subllamadas)
y marca un error al autor de la llamada.

Cuando las excepciones ocurren en una subllamada, "burbujean" (i.e., 
las excepciones se vuelven a lanzar) automáticamente a menos que se 
detecten en una instrucción ``try/catch``. Las excepciones a esta regla 
son ``send`` y las funciones de bajo nivel ``call``, ``delegatecall`` 
y ``staticcall``: devuelven ``false`` como su primer valor devuelto 
en caso de una excepción en lugar de "burbujear".

.. warning::
    Las funciones de bajo nivel ``call``, ``delegatecall`` y ``staticcall`` 
    devuelve ``true`` como su primer valor de retorno si la cuenta llamada no existe, 
    como parte del diseño del EVM. Debe comprobarse la existencia de la cuenta antes de llamar.

Las excepciones pueden contener datos de error que se devuelven al autor 
de la llamada en forma de :ref:`error instances <errors>`. Los errores incorporados 
``Error(string)`` y ``Panic(uint256)`` son utilizados por funciones especiales, como se 
explica a continuación. ``Error`` se usa para condiciones de error "regular", 
mientras que ``Panic`` se usa para errores que no deberían estar presentes en el código libre de errores.

Panic a través de ``assert`` y Error a través de ``require``
----------------------------------------------

Las funciones de conveniencia ``assert`` y ``require`` se pueden usar para verificar las condiciones y lanzar una excepción 
si no se cumple la condición.

La función ``assert`` crea un error del tipo ``Panic(uint256)``. 
El compilador crea el mismo error en ciertas situaciones que se enumeran a continuación.

Assert solo debe usarse para detectar errores internos y para verificar invariantes. 
El correcto funcionamiento del código nunca debe crear un pánico, ni siquiera en una entrada externa no válida. 
Si esto sucede, entonces hay un error en su contrato que debe corregir. Las herramientas de análisis de lenguaje 
pueden evaluar su contrato para identificar las condiciones y las llamadas a funciones que causarán pánico.

Se genera una excepción de pánico en las siguientes situaciones. 
El código de error proporcionado con los datos de error indica el tipo de pánico.

#. 0x00: Se utiliza para pánicos insertados en el compilador genérico.
#. 0x01: Si llama a ``assert`` con un argumento que se evalúa como false.
#. 0x11: Si una operación aritmética resulta en subdesbordamiento o desbordamiento fuera de un bloque ``unchecked { ... }``.
#. 0x12; Si divide o modulo por cero (por ejemplo ``5 / 0`` o ``23 % 0``).
#. 0x21: Si convierte un valor demasiado grande o negativo en un tipo de enumeración.
#. 0x22: Si accede a una matriz de bytes de almacenamiento que está codificada incorrectamente.
#. 0x31: Si llama a ``.pop()`` en un array vacío.
#. 0x32: Si accede a una matriz, ``bytesN``` o a un segmento de matriz en un índice negativo o fuera de los límites (i.e. ``x[i]`` donde ``i >= x.length`` o ``i < 0``).
#. 0x41: Si asigna demasiada memoria o crea una matriz que es demasiado grande.
#. 0x51: Si llama a una variable inicializada en cero de tipo de función interna.

La función``'require`` crea un error sin ningún dato o un error del tipo ``Error(string)``. 
Debe utilizarse para garantizar condiciones válidas que no se puedan detectar hasta el momento 
de la ejecución. Esto incluye condiciones sobre entradas o valores devueltos de llamadas a contratos externos.

.. note::

    Actualmente no es posible utilizar errores personalizados en combinación con `require``. 
    Utilice ``if (!condition) revert CustomError();`` en su lugar.

El compilador genera una excepción ``Error(string)`` (o una excepción sin datos) en las siguientes situaciones:

#. Llamar a ``require(x)`` donde ``x`` se evalúa como ``false``.
#. Si se utiliza ``revert()`` o ``revert("description")``.
#. Si se realiza una llamada de función externa apuntando a un contrato que no contiene código.
#. Si un contrato recibe Ether mediante una función sin el modificador ``payable`` 
   (incluyendo el constructor y la función de fallback).
#. Si un contrato recibe Ether mediante una función getter pública.

<<<<<<< HEAD
Para los siguientes casos, se reenvían los datos de error de la llamada externa 
(si se proporcionan). Esto significa que puede causar un `Error` o un `Pánico` 
(o cualquier otra cosa que se haya dado):
=======
For the following cases, the error data from the external call
(if provided) is forwarded. This means that it can either cause
an ``Error`` or a ``Panic`` (or whatever else was given):
>>>>>>> english/develop

#. Si un ``.transfer()`` falla.
#. Si llama a una función a través de una llamada de mensaje pero no termina 
   correctamente (i.e., se queda sin gas, no tiene una función coincidente, o 
   lanza una excepción en sí misma), excepto cuando se utiliza una operación de bajo nivel
   ``call``, ``send``, ``delegatecall``, ``callcode`` or ``staticcall``. Las operaciones 
   de bajo nivel nunca arrojan excepciones, sino que indican errores devolviendo ``false``.
#. Si crea un contrato utilizando la palabra clave ``new`` pero la creación del contrato 
   :ref:`no finaliza propiamente<creating-contracts>`.

Opcionalmente, puede proporcionar una cadena de mensaje para ``require``, pero no para ``assert``.

.. note::
    Si no proporciona un argumento de cadena a ``require``, se revertirá 
    con datos de error vacíos, sin siquiera incluir el selector de errores.

En el ejemplo siguiente se muestra cómo puede utilizar ``require`` para comprobar las condiciones de las entradas 
y ``assert`` para la comprobación interna de errores.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract Sharer {
        function sendHalf(address payable addr) public payable returns (uint balance) {
            require(msg.value % 2 == 0, "Even value required.");
            uint balanceBeforeTransfer = address(this).balance;
            addr.transfer(msg.value / 2);
<<<<<<< HEAD
            // Dado que la transferencia arroja una excepción en caso de fallo y
            // no puedo volver a llamar aquí, no debería haber forma de que lo hagamos
            // todavía tienen la mitad del dinero.
=======
            // Since transfer throws an exception on failure and
            // cannot call back here, there should be no way for us to
            // still have half of the Ether.
>>>>>>> english/develop
            assert(address(this).balance == balanceBeforeTransfer - msg.value / 2);
            return address(this).balance;
        }
    }

Internamente, Solidity realiza una operación de reversión (instrucción ``0xfd``). 
Esto hace que el EVM revierta todos los cambios realizados en el estado. 
La razón para revertir es que no hay una forma segura de continuar la ejecución, porque 
no se produjo un efecto esperado. Debido a que queremos mantener la atomicidad de las transacciones, 
la acción más segura es revertir todos los cambios y dejar (o al menos llamar) sin efecto toda la transacción.

En ambos casos, quien llama puede reaccionar ante tales fallos usando ``try``/``catch``, 
pero los cambios en quien está siendo llamado siempre se revertirán.

.. note::

    Las excepciones de pánico solían usar el código de operación ``invalid`` antes de Solidity 0.8.0, 
    que consumía todo el gas disponible para la llamada. Las excepciones que usan ``require`` solían 
    consumir todo el gas hasta antes del lanzamiento de Metropolis.

.. _revert-statement:

``revert``
----------

Se puede activar una reversión directa utilizando la instrucción ``revert`` y la función ``revert``.

La instrucción ``revert`` accepta un error personalizado como argumento directo sin paréntesis:

    revert CustomError(arg1, arg2);

<<<<<<< HEAD
Por razones de compatibilidad con versiones anteriores, también existe la función ``revert()``, que utiliza paréntesis 
y acepta una cadena:
=======
For backward-compatibility reasons, there is also the ``revert()`` function, which uses parentheses
and accepts a string:
>>>>>>> english/develop

    revert();
    revert("description");

Los datos de error se devolverán a la persona que llama y se pueden capturar allí.
El uso de ``revert()`` causa una reversión sin ningún dato de error, mientras que ``revert("description")``
creará un error ``Error(string)``.

El uso de una instancia de error personalizada generalmente será mucho más barato que una descripción de cadena, 
por que puede usar el nombre del error para describirlo, que está codificado en solo cuatro bytes. Se puede 
proporcionar una descripción más larga a través de NatSpec que no incurre en ningún costo.

En el ejemplo siguiente se muestra cómo utilizar una cadena de error y una instancia de error personalizada
junto con ``revert`` y el equivalente ``require``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract VendingMachine {
        address owner;
        error Unauthorized();
        function buy(uint amount) public payable {
            if (amount > msg.value / 2 ether)
                revert("Not enough Ether provided.");
            // Forma alternativa de hacerlo:
            require(
                amount <= msg.value / 2 ether,
                "Not enough Ether provided."
            );
            // Realice la compra.
        }
        function withdraw() public {
            if (msg.sender != owner)
                revert Unauthorized();

            payable(msg.sender).transfer(address(this).balance);
        }
    }

Las dos formas ``if (!condition) revert(...);`` y ``require(condition, ...);`` son 
equivalentes siempre y cuando los argumentos para ``revert`` y ``require`` no tengan 
efectos secundarios, por ejemplo, si son solo cadenas.

.. note::
    La función ``require`` se evalúa como cualquier otra función. Esto significa que todos los 
    argumentos se evalúan antes de ejecutar la función en sí.  En particular, en ``require(condition, f())``
    la función ``f`` se ejecuta incluso si ``condition`` es true.

La cadena proporcionada es :ref:`abi-encoded <ABI>` como si fuera una llamada a una función ``Error(string)``.
En el ejemplo anterior, ``revertir("No se proporciona suficiente éter."); `` devuelve el siguiente hexadecimal como datos de retorno de error:

.. code::

    0x08c379a0                                                         // Selector de funciones para Error(string)
    0x0000000000000000000000000000000000000000000000000000000000000020 // Desplazamiento de datos
    0x000000000000000000000000000000000000000000000000000000000000001a // Longitud de la cadena
    0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // Dato de cadena

El mensaje proporcionado puede ser recuperado por la persona que llama usando ``try``/``catch`` como se muestra a continuación.

.. note::
    Solía haber una palabra clave llamada ``throw`` con la misma semántica que ``revert()`` que 
    estaba en desuso en la versión 0.4.13 y eliminada en la versión 0.5.0.


.. _try-catch:

``try``/``catch``
-----------------

Un error en una llamada externa se puede detectar mediante una instrucción try/catch, de la siguiente manera:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;

    interface DataFeed { function getData(address token) external returns (uint value); }

    contract FeedConsumer {
        DataFeed feed;
        uint errorCount;
        function rate(address token) public returns (uint value, bool success) {
            // Desactivar permanentemente el mecanismo si hay
            // mas de 10 errores.
            require(errorCount < 10);
            try feed.getData(token) returns (uint v) {
                return (v, true);
            } catch Error(string memory /*reason*/) {
                // Esto se ejecuta en caso de que
                // se llamó un revert dentro de getData
                // y se proporcionó una cuerda de razón.
                errorCount++;
                return (0, false);
            } catch Panic(uint /*errorCode*/) {
                // Esto se ejecuta en caso de pánico,
                // i.e. un error grave como la división por cero
                // o desbordamiento. Se puede utilizar el código de error
                // para determinar el tipo de error.
                errorCount++;
                return (0, false);
            } catch (bytes memory /*lowLevelData*/) {
                // Esto se ejecuta en caso de que se haya utilizado revert().
                errorCount++;
                return (0, false);
            }
        }
    }

La palabra clave ``try``tiene que ser seguida de una expresión que represente una llamada a una función externa 
o una creación de contrato (``new ContractName()``). 
Los errores dentro de la expresión no se detectan (por ejemplo, si se trata de una expresión compleja 
que también implica llamadas a funciones internas), solo una reversión dentro de la 
propia llamada externa. La parte ``returns`` (que es opcional) que sigue declara variables de retorno que 
coinciden con los tipos devueltos por la llamada externa. En caso de que no hubiera error, 
se asignan estas variables y la ejecución del contrato continúa dentro del primer bloque de éxito. 
Si se llega al final del bloque de éxito, la ejecución continúa después de los bloques de "captura". 

Solidity admite diferentes tipos de bloques de captura dependiendo del 
tipo de error:

- ``catch Error(string memory reason) { ... }``: Esta cláusula catch se ejecuta si el error fue causado por ``revert("reasonString")`` o 
    ``require(false, "reasonString")`` (o un error interno que causa tal 
    excepción).

- ``catch Panic(uint errorCode) { ... }``: Si el error fue causado por un pánico, i.e, por un error ``assert``, división por cero,
    acceso a matriz no válido, desbordamiento aritmético y otros, se ejecutará esta cláusula catch.

- ``catch (bytes memory lowLevelData) { ... }``: Esta cláusula se ejecuta si la firma de error 
    no coincide con ninguna otra cláusula, si hubo un error al decodificar el mensaje de error,
    o si ningunos datos de error se proveyeran de la excepción. La variable declarada proporciona 
    acceso a los datos de error de bajo nivel en ese caso.

- ``catch { ... }``: Si no está interesado en los datos de error, puede usar
  ``catch { ... }`` (incluso como la única cláusula de captura) en lugar de la cláusula anterior.

Está planeado para soportar otros tipos de datos de error en el futuro. 
Las cadenas ``Error`` y ``Pánico`` se analizan actualmente tal cual y no se tratan como identificadores.

Para detectar todos los casos de errores, debe tener al menos las cláusas
``catch { ...}`` o ``catch (bytes memory lowLevelData) { ... }``.

Los variables declarado en en la cláusula ``returns`` y ``catch`` solo están 
en el ámbito en el bloque que sigue.

.. note::

    Si se produce un error durante la decodificación de los datos devueltos 
    dentro de una sentencia try/catch, esto provoca una excepción en el actual ejecución de contrato y por eso, 
    no se captura en la cláusula catch. Si hay un error durante la decodificación de ``catch Error(string memory reason)`` 
    y hay una cláusula catch de bajo nivel, este error se detecta allí.

.. note::

    Si la ejecución alcanza un bloque catch, entonces los efectos de cambio de estado de la llamada externa
    han sido revertidos. Si la ejecución alcanza el bloque de éxito, los efectos 
    no se revertieron. Si los efectos se han revertido, la ejecución continuará en un bloque 
    catch o la ejecución de la propia sentencia try/catch se revierte (por ejemplo, 
    debido a errores de descodificación como se ha indicado anteriormente o debido a 
    que no se proporciona una cláusula catch de bajo nivel).

.. note::

    El motivo de una llamada fallida puede ser múltiple. No asuma que 
    el mensaje de error procede directamente del contrato llamado: 
    El error podría haberse producido en una fase más profunda de la cadena de llamadas y 
    el contrato llamado acaba de reenviarlo. Además, podría deberse a un 
    situación de falta de gas y no una condición de error deliberada: 
    La persona que llama siempre retiene al menos 1/64th del gas en una llamada y, por lo tanto, 
    incluso si el contrato llamado se queda sin gas, la persona que llama aún 
    le queda algo de gas.
