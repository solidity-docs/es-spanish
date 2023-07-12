.. _inline-assembly:

###############
Ensamblado en línea
###############

.. index:: ! assembly, ! asm, ! evmasm

Puedes intercalar declaraciones de Solidity con ensamblado en línea en un lenguaje cercano al de la Máquina Virtual de Ethereum. Esto te brinda un control más preciso, especialmente útil cuando estás mejorando el lenguaje escribiendo librerías.

El lenguaje utilizado para el ensamblado en línea en Solidity se llama :ref:`Yul <yul>` y está documentado en su propia sección. Esta sección solo cubre cómo el código de ensamblado en línea puede interactuar con el código en Solidity que lo rodea.


.. warning::
    El ensamblado en línea es una forma de acceder a la Máquina Virtual de Ethereum aun nivel bajo. Esto evita varias características y comprobaciones de seguridad importantes de Solidity. Solo debes usarlo para tareas que lo necesiten y solo si tienes confianza en su uso.


Un bloque de ensamblado en línea está marcado con ``assembly { ... }``, donde el código dentro de las llaves es código en el lenguaje :ref:`Yul <yul>`.

El código de ensamblado en línea puede acceder variables locales de Solidity como se explica a continuación.

Los diferentes bloques de ensamblado en línea no comparten ningún espacio de nombres, por ejemplo, no es posible llamar a una función Yul o acceder a una variable Yul definida en un bloque de ensamblado en línea diferente.

Ejemplo
-------

El siguiente ejemplo proporciona código de la librería para acceder al código de otro contrato y cargarlo en una variable ``bytes``. Esto también es posible con "Solidity plano" usando ``<address>.code``. Pero el punto aquí es que las librerías de ensamblado reutilizables pueden mejorar Solidity sin un cambio en el compilador.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library GetCode {
        function at(address addr) public view returns (bytes memory code) {
            assembly {
                // recuperar el tamaño del código, esto necesita ensamblaje
                let size := extcodesize(addr)
                // asignar el arreglo de bytes de salida, esto también podría hacerse sin ensamblaje
                // utilizando code = new bytes(size)
                code := mload(0x40)
                // nuevo "fin de memoria" incluyendo relleno
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // almacenar longitud en memoria
                mstore(code, size)
                // recuperar realmente el código, esto necesita ensamblaje
                extcodecopy(addr, add(code, 0x20), 0, size)
            }
        }
    }

El ensamblado en línea también es beneficioso en casos en los que el optimizador no logra producir código eficiente, por ejemplo:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;


    library VectorSum {
        // Esta función es menos eficiente porque actualmente el optimizador
        // no puede eliminar las comprobaciones de límites en el acceso a arreglo.
        function sumSolidity(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i)
                sum += data[i];
        }

        // Sabemos que solo accedemos al arreglo dentro de los límites, por lo que podemos
        // evitar la comprobación.
        // 0x20 se debe añadir a un arreglo porque el primer espacio contiene la
        // longitud del arreglo.
        function sumAsm(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(data, 0x20), mul(i, 0x20))))
                }
            }
        }

        // Al igual que el anterior, pero realizando todo el código dentro de ensamblado en línea.
        function sumPureAsm(uint[] memory data) public pure returns (uint sum) {
            assembly {
                // Cargar la longitud (los primeros 32 bytes)
                let len := mload(data)

                // Saltar el campo de longitud.
                //
                // Mantener la variable temporal para que pueda ser incrementada en su lugar.
                //
                // NOTA: incrementar los datos resultaría en una variable de datos inutilizable
                //       después de este bloque de ensamblado
                let dataElementLocation := add(data, 0x20)

                // Iterar hasta que no se cumpla el límite.
                for
                    { let end := add(dataElementLocation, mul(len, 0x20)) }
                    lt(dataElementLocation, end)
                    { dataElementLocation := add(dataElementLocation, 0x20) }
                {
                    sum := add(sum, mload(dataElementLocation))
                }
            }
        }
    }

.. index:: selector; of a function

Acceso a variables, funciones y librerías externas
-----------------------------------------------------

Puedes acceder a las variables y otros identificadores de Solidity utilizando su nombre.

Las variables locales de tipo valor son directamente utilizables en el ensamblado en línea.
Ambas se pueden leer y asignar.

Las variables locales que hacen referencia a memoria evalúan la dirección de la variable en memoria, no el valor en sí.
Tales variables también se pueden asignar, pero ten en cuenta que una asignación solo cambiará hacia donde apunta y no los datos, también que es tu responsabilidad respetar la gestión de memoria de Solidity. Ver :ref:`Convenciones en Solidity <conventions-in-solidity>`.

Del mismo modo, las variables locales que hacen referencia a arreglos de calldata de tamaño estático o estructuras calldata evalúan la dirección de la variable en calldata, no el valor en sí. También se le puede asignar un nuevo offset a la variable, pero ten en cuenta que no se realiza ninguna validación para asegurar que la variable no apunte más allá de ``calldatasize()``.

Para los punteros de función externos, la dirección y el selector de función pueden accederse usando ``x.address`` y ``x.selector``. El selector consiste de cuatro bytes alineados a la derecha. Ambos valores se pueden asignar. Por ejemplo:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.10 <0.9.0;

    contract C {
        // Asigna un nuevo selector y dirección a la variable de retorno @fun
        function combineToFunctionPointer(address newAddress, uint newSelector) public pure returns (function() external fun) {
            assembly {
                fun.selector := newSelector
                fun.address  := newAddress
            }
        }
    }

Para los arreglos dinámicos de calldata, puedes acceder a su offset de calldata (en bytes) y longitud (número de elementos) utilizando ``x.offset`` y ``x.length``. Ambas expresiones también pueden ser asignadas, pero como en el caso estático, no se realizará ninguna validación para asegurarse que el área de datos resultante esté dentro de los límites de ``calldatasize()``.

Para las variables de almacenamiento local, o variables de estado, un identificador único Yul no es suficiente ya que no necesariamente ocupan un solo espacio de almacenamiento completo. Por lo tanto, su "dirección" está compuesta por un espacio y un offset de bytes dentro del espacio. Para recuperar el espacio apuntado por la variable `x`, utiliza `x.slot` y para recuperar el offset de bytes utiliza `x.offset`. El uso de `x` en sí mismo resultará en un error.

También puedes asignar a la parte ``.slot`` de un puntero de variable de almacenamiento local. Para estos (estructuras, arreglos o mapeos), la parte ``.offset`` siempre es cero. Sin embargo, no es posible asignar a la parte ``.slot`` o ``.offset`` de una variable de estado.

Las variables locales en Solidity están disponibles para asignaciones, por ejemplo:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract C {
        uint b;
        function f(uint x) public view returns (uint r) {
            assembly {
                // Ignoramos el desplazamiento de la ranura de almacenamiento,
                // sabemos que es cero en este caso especial.
                r := mul(x, sload(b.slot))
            }
        }
    }

.. warning::
    Si accedes a variables de un tipo que abarque menos de 256 bits (por ejemplo, ``uint64``, ``address``, o ``bytes16``), no puedes hacer ninguna suposición acerca de bits que no son parte de la codificación del tipo. Especialmente, no debes suponer que son cero. Para estar seguro, siempre limpia de forma adecuada los datos antes de utilizarlos en un contexto en el que esto sea importante: ``uint32 x = f(); assembly { x := and(x, 0xffffffff) /* now use x */ }`` Para limpiar tipos firmados, puedes usar el código de operación: ``assembly { signextend(<num_bytes_of_x_minus_one>, x) }``


Desde Solidity 0.6.0, puede que el nombre de una variable de ensamblado en línea no oculte ninguna declaración visible en el ámbito del bloque de ensamblado en línea (incluyendo declaraciones de variables, contratos y funciones).

Desde Solidity 0.7.0, puede que las variables y funciones declaradas dentro del bloque de ensamblado en línea no contengan ``.``, pero usar ``.`` es válido para acceder a las variables de Solidity desde fuera del bloque de ensamblado en línea.

Cosas a evitar
---------------

El ensamblado en línea puede tener un aspecto de alto nivel, pero en realidad es bastante de bajo nivel. Las llamadas a funciones, bucles, condiciones y conmutadores se convierten mediante reglas de reescritura simples, después de eso lo único que hace el ensamblador por ti es reorganizar las instrucciones de estilo funcional de los códigos de operación, contar la altura de la pila para acceder a las variables y eliminar los espacios de la pila de las variables locales al ensamblado cuando se alcanza el final de su bloque.

.. _conventions-in-solidity:

Convenciones en Solidity
-----------------------

.. _assembly-typed-variables:

Valores de variables con tipo
=========================

En contraste con el ensamblado EVM, Solidity tiene tipos más estrechos que 256 bits, como ``uint24``. Por eficiencia, la mayoría de operaciones aritméticas ignoran el hecho de que los tipos pueden ser más cortos que 256 bits y se limpian los bits de mayor orden cuando es necesario, es decir, poco antes de que sean escritas en la memoria o antes de realizar comparaciones. Esto significa que si accedes a una variable de este tipo desde el ensamblado en línea, es posible que primero tengas que limpiar manualmente los bits de mayor orden.

.. _assembly-memory-management:

Gestión de memoria
=================

Solidity maneja la memoria de la siguiente forma. Hay un "puntero de memoria libre" en la posición ``0x40`` de la memoria. Si quieres asignar memoria, usa la memoria a partir de donde apunta ese puntero y actualiza el mismo. No hay garantía de que la memoria no haya sido utilizada anteriormente y por lo tanto no puedes asumir que sean bytes en cero. No hay un mecanismo incorporado para soltar o liberar memoria asignada. Aquí tienes un fragmento de ensamblado que puedes usar para asignar memoria siguiendo el proceso descrito anteriormente:

.. code-block:: yul

    function allocate(length) -> pos {
      pos := mload(0x40)
      mstore(0x40, add(pos, length))
    }

Los primeros 64 bytes de memoria pueden usarse como "espacio temporal" para asignaciones a corto plazo. Los siguientes 32 bytes tras el puntero de memoria libre (es decir, a partir de ``0x60``) están destinados a ser cero permanentemente y se usan como valor inicial para los arreglos de memoria dinámica vacíos. Esto significa que la memoria asignable comienza en ``0x80``, que es el valor inicial del puntero de memoria libre.

Los elementos en los arreglos de memoria de Solidity siempre ocupan múltiplos de 32 bytes (esto es cierto también para ``bytes1[]``, pero no para ``bytes`` y ``string``). Los arreglos de memoria multidimensionales son punteros a arreglos de memoria. La longitud de un arreglo dinámico se almacena en el primer espacio del arreglo que le sigue, seguido por los elementos del arreglo.

.. warning::
    Los arreglos de memoria de tamaño estático no tienen un campo de longitud, pero puede ser que se añada más adelante para permitir una mejor conversión entre arreglos de tamaño estático y dinámico; así que no dependas de esto.

Seguridad de la memoria
=============

Sin el uso del ensamblado en línea, el compilador puede confiar en que la memoria permanezca en un estado bien definido en todo momento. Esto es especialmente relevante para :ref:`la nueva ruta de generación de código a través de Yul IR <ir-breaking-changes>`: esta vía de generación de código puede mover variables locales de la pila a la memoria para evitar errores de pila demasiado profundos y realizar optimizaciones de memoria adicionales, si puede confiar en ciertas suposiciones sobre el uso de la memoria.

Aunque recomendamos siempre respetar el modelo de memoria de Solidity, el ensamblado en línea te permite usar la memoria de una manera incompatible. Por lo tanto, el traslado de variables de la pila a la memoria y las optimizaciones adicionales están deshabilitadas globalmente por defecto en la presencia de cualquier bloque de ensamblado en línea que contenga una operación de memoria o asigne variables de Solidity en la memoria.

Sin embargo, puede anotar específicamente un bloque de ensamblado para indicar que, de hecho, respeta el modelo de memoria de Solidity de la siguiente manera:

.. code-block:: solidity

    assembly ("memory-safe") {
        ...
    }

En particular, un bloque de ensamblado seguro en cuanto a la memoria solo puede acceder a los siguientes intervalos de memoria:

- Memoria asignada por ti mismo usando un mecanismo como la función ``allocate`` descrita anteriormente.
- Memoria asignada por Solidity, por ejemplo, memoria dentro de los límites de un arreglo de memoria a la que haces referencia.
- El espacio de memoria virtual entre el offset de memoria 0 y 64 mencionados anteriormente.
- Memoria temporal que se encuentra *después* del valor del puntero de memoria libre al comienzo del bloque de ensamblado, es decir, memoria que se "asigna" al puntero de memoria libre sin actualizar el puntero de memoria libre.

Además, si el bloque de ensamblado asigna variables de Solidity en la memoria, debes asegurarte de que los accesos a las variables de Solidity solo accedan a estos intervalos de memoria.

Dado que esto se trata principalmente del optimizador, estas restricciones todavía deben seguirse, incluso si el bloque de ensamblado se revierte o termina. Como ejemplo, el siguiente fragmento de ensamblado no es seguro en cuanto a la memoria, ya que el valor de ``returndatasize()`` puede exceder el espacio temporal de 64 bytes:

.. code-block:: solidity

    assembly {
      returndatacopy(0, 0, returndatasize())
      revert(0, returndatasize())
    }

Por el otro lado, el siguiente código *es* seguro en cuanto a la memoria, porque la memoria más allá de la ubicación apuntada por el puntero de memoria libre se puede usar con seguridad como espacio temporal de memoria virtual:

.. code-block:: solidity

    assembly ("memory-safe") {
      let p := mload(0x40)
      returndatacopy(p, 0, returndatasize())
      revert(p, returndatasize())
    }

Ten en cuenta que no necesitas actualizar el puntero de memoria libre si no hay una asignación posterior, pero solo puedes usar la memoria a partir de la dirección actual dad por el puntero de memoria libre.

Si las operaciones de memoria usan una longitud cero, también es aceptable usar cualquier offset (no solo si cae en el espacio temporal):

.. code-block:: solidity

    assembly ("memory-safe") {
      revert(0, 0)
    }

Ten en cuenta que no solo las operaciones de memoria en ensamblado en línea en sí pueden ser inseguras en cuanto a la memoria, pero también las asignaciones a variables de Solidity de tipo referencia en memoria. Por ejemplo, esto no es seguro para la memoria:

.. code-block:: solidity

    bytes memory x;
    assembly {
      x := 0x40
    }
    x[0x20] = 0x42;

El ensamblado en línea que no involucra ninguna operación que acceda a la memoria ni asigna ninguna variable de Solidity en la memoria se considera automáticamente seguro para la memoria y no necesita ser anotado.

.. warning::
<<<<<<< HEAD
    Es tu responsabilidad asegurarte de que el ensamblado realmente cumpla el modelo de memoria. Si anotas un bloque de ensamblado como seguro en cuanto a la memoria, pero viola una de las suposiciones de la memoria, esto *provocará* a un comportamiento incorrecto e indeterminado que no puede descubrirse con facilidad mediante pruebas.
    
En caso de que estes desarrollando una biblioteca que esté destinada a ser compatible con varias versiones de Solidity, puedes usar un comentario especial para anotar un bloque de ensamblado como seguro en cuanto a la memoria:
=======
    It is your responsibility to make sure that the assembly actually satisfies the memory model. If you annotate
    an assembly block as memory-safe, but violate one of the memory assumptions, this **will** lead to incorrect and
    undefined behavior that cannot easily be discovered by testing.

In case you are developing a library that is meant to be compatible across multiple versions
of Solidity, you can use a special comment to annotate an assembly block as memory-safe:
>>>>>>> english/develop

.. code-block:: solidity

    /// @solidity memory-safe-assembly
    assembly {
        ...
    }

<<<<<<< HEAD
Ten en cuenta que en una futura versión deshabilitaremos la anotación mediante comentarios. Si no te preocupa la compatibilidad con versiones anteriores del compilador, preferiblemente usa la secuencia de dialecto.
=======
Note that we will disallow the annotation via comment in a future breaking release; so, if you are not concerned with
backward-compatibility with older compiler versions, prefer using the dialect string.
>>>>>>> english/develop
