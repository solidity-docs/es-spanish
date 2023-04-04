.. _security_considerations:

#######################
Consideraciones de Seguridad
#######################

Aunque normalmente es bastante fácil construir software que funcione como se espera,
es mucho más difícil controlar que nadie pueda usarlo de un manera **no** anticipada.

En Solidity, esto es incluso más importante porque puede usar contratos inteligentes para manejar tokens o, posiblemente, incluso cosas más valiosas. Además, cada ejecución de un contrato inteligente sucede en público y, además de ello, a menudo el código fuente está disponible. 

Por supuesto siempre tiene que considerar cuánto está en riesgo:
Puede comparar un contrato inteligente con un servicio web que está abierto al público (y por eso, también a actores maliciosos) y quizá incluso de código abierto.
Si solo almacena su lista de compras en ese servicio web, es posible que no tenga mucho cuidado, pero si administra su cuenta bancaria usando ese servicio web, debería ser más cuidadoso.

Esta sección listará algunos peligros y recomendaciones de seguridad generales pero,
por supuesto, nunca puede estar completo. También, tenga presente que incluso si su
contrato inteligente está libre de bugs, el compilador o la plataforma misma pudiera tener un bug. Una lista de algunos bugs públicamente conocidos relevantes para la seguridad del compilador se pueden encontrar en la :ref:`lista de bugs conocidos<known_bugs>`, la cual también es legible por máquina. Note que hay un programa de bug bounty que cubre el generador de código del compilador de Solidity.

Como siempre. con documentación de código abierto, por favor ayúdenos a extender esta sección (especialmente, algunos ejemplos no harían daño)!

NOTA: Además de la lista de abajo, puede encontrar más recomendaciones de seguridad y buenas prácticas `en la lista de Guy Lando <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_ y `the Consensys GitHub repo <https://consensys.github.io/smart-contract-best-practices/>`_.

********
Peligros
********

Información privada y Aleatoriedad
==================================

Todo lo que use en un contrato inteligente es públicamente visible, incluso
variables locales y variables de estado marcados como ``private``.

El uso de números aleatorios en contratos inteligentes es bastante complicado si no quiere
que los mineros sean capaces de hacer trampa.

Reentrancy
===========

Cualquier interacción de un contrato (A) con otro contrato (B) y cualquier transferencia
de Ether pasa el control a ese contrato (B). Esto permite que (B) vuelva a A antes de que 
esta interacción finalice. Para dar un ejemplo, el siguiente código contiene un bug (es solo un fragmento
y no un contrato completo):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // ESTE CONTRATO CONTIENE UN BUG - NO USAR
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

El problema aquí no es demasiado serio debido al gas limitado como parte
de ``send``, pero aun así expone una debilidad: La transferencia de Ether siempre
puede incluir ejecución de código, así que el destinatario podría ser un contrato que
vuelve a ``withdraw``. Esto le permitiría obtener múltiples reembolsos y básicamente
recuperar todo el Ether del contrato. En particular, el siguiente contrato permitiría
a un atacante recuperar múltiples veces al usar ``call`` el cual envía todo el gas sobrante
por defecto:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    // ESTE CONTRATO CONTIENE UN BUG - NO USAR
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            (bool success,) = msg.sender.call{value: shares[msg.sender]}("");
            if (success)
                shares[msg.sender] = 0;
        }
    }

<<<<<<< HEAD
Para evitar un ataque de re-entrancy, puede usar el patrón Verificaciónes-Efectos-Interacción
como se esboza más abajo:
=======
To avoid reentrancy, you can use the Checks-Effects-Interactions pattern as
demonstrated below:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            payable(msg.sender).transfer(share);
        }
    }

<<<<<<< HEAD
El patrón Verificaciónes-Efectos-Interaccion garantiza que todas las rutas de código a través de un contrato completen todas las comprobaciones necesarias de los parámetros suministrados antes de modificar el estado del contrato (Verificación); solo entonces realiza cambios en el estado (Efectos); puede hacer llamadas a funciones en otros contratos *después* de que todos los cambios de estado planificados se hayan escrito en
almacenamiento (interacciones). Esta es una forma común e infalible de prevenir *ataques de reingreso*, donde una llamada externa
contrato malicioso es capaz de gastar dos veces una asignación, retirar dos veces un saldo, entre otras cosas, mediante el uso de la lógica que vuelve a llamar a la contrato original antes de que haya finalizado su transacción.

Note que el ataque por re-entrancy no solo es un efecto de la transferencia de Ether
sino de cualquier llamada de función sobre otro contrato. Además, también tiene que
tener en cuenta situaciones de contratos múltiples. Una llamada a un contrato podría modificar el estado de otro contrato del cual depende.
=======
The Checks-Effects-Interactions pattern ensures that all code paths through a contract complete all required checks
of the supplied parameters before modifying the contract's state (Checks); only then it makes any changes to the state (Effects);
it may make calls to functions in other contracts *after* all planned state changes have been written to
storage (Interactions). This is a common foolproof way to prevent *reentrancy attacks*, where an externally called
malicious contract is able to double-spend an allowance, double-withdraw a balance, among other things, by using logic that calls back into the
original contract before it has finalized its transaction.

Note that reentrancy is not only an effect of Ether transfer but of any
function call on another contract. Furthermore, you also have to take
multi-contract situations into account. A called contract could modify the
state of another contract you depend on.
>>>>>>> english/develop

Límite de Gas y Bucles
===================

Los bucles que no tienen un número fijo de iteraciones, por ejemplo, bucles que dependen de valores almacenados, tienen que ser usados cuidadosamente:
Debido al límite de gas de bloque, las transacciones solo pueden consumir una cierta cantidad de gas. O explícitamente o solo debido a una operación
normal, el número de iteraciones en un bucle puede crecer más allá del límite de gas de bloque, el cual puede causar que el contrato completo se pare
en cierto punto. Esto no puede aplicar a las funciones ``view`` que solo son ejecutadas para leer datos de la cadena de bloques. Aun así, tales funciones
podrían ser invocadas por otros contratos como parte de operaciones en cadena y parar aquellas. Por favor, sea explícito sobre tales casos en la
documentación de sus contratos.

Envío y Recepción de Ether
===========================

- Ni los contratos ni "cuentas externas" son actualmente capaces de prevenir que alguien les envía Ether.
  Los contratos pueden reaccionar y rechazar una transferencia regular, pero hay maneras de mover Ether
  sin crear un message call. Una manera es simplemente minar a la dirección de contrato y la segunda manera
  es usar ``selfdestruct(x)``.

- Si un contrato recibe Ether (sin una función siendo llamada), o la función
  :ref:`receive Ether <receive-ether-function>` o la función :ref:`fallback <fallback-function>`
  se jecutan.
  Si no tiene una función receive ni fallback, el Ether será rechazado (al lanzar una excepción).
  Durante la ejecución de una de estas funciones, el contrato solo puede depender del "estipendio de gas"
  que se le pase (2300 gas) estando disponible en ese momento. Este estipendio no es suficiente para
  modificar el almacenamiento (aunque no dé por sentado esto, el estipendio podría cambiar con futuros hard forks).
  Para asegurarse de que su contrato puede recibir Ether de esa manera, compruebe los requerimientos de gas de las
  funciones receive y fallback (por ejemplo, en la sección de "details" de Remix).

- Hay una manera de enviar más gas al contrato receptor usando ``addr.call{value: x}("")``.
  Esto es esencialmente lo mismo como ``addr.transfer(x)``, solo que envía todo el gas restante
  y facilita al receptor realizar acciones más caras (y retorna un código de fallo en lugar de propagar
  automáticamente el error). Esto podría incluir el llamado de vuelta al contrato de envío u otros
  cambios de estado los cuales usted no podría pensar. Así que permite gran flexibilidad para los
  usuarios honestos pero también para actores maliciosos.

- Use las unidades más precisas como sea posible para representar la cantidad de wei,
  puesto que pierde todo lo que esté redondeado debido a una falta de precisión.

- Si usted quiere enviar Ether usando ``address.transfer``, hay ciertos detalles de los cuales debe estar al tanto:

  1. Si el receptor es un contrato, causa que la función receive o fallback sea ejecutada
     lo cual puede, después, llamar de vuelta al contrato emisor.
  2. El envío de Ether puede fallar debido a la profundidad de la llamada al superar 1024.
     Ya que el que llama está en total control de la profundidad de la llamada, ellos pueden
     forzar que la transferencia falle; tome esta posibilidad en cuenta o use ``send`` y
     asegúrese de siempre corroborar el valor de retorno. Mejor aún, escriba su contrato
     usando un patrón en donde el receptor pueda retirar Ether.
  3. El envío de Ether también puede fallar debido a que la ejecución del contrato receptor
     requiere más de la cantidad de gas asignada (explícitamente al usar :ref:`require <assert-and-require>`, 
     :ref:`assert <assert-and-require>`, :ref:`revert <assert-and-require>` o porque la operación es demasiado costosa) - 
     it "runs out of gas" (OOG) se consumió todo el gas. Si usa ``transfer`` o ``send`` con una comprobación del valor de
     retorno, esto podría proveer un medio para que el receptor bloquee el progreso en el contrato remitente.
     Una vez más, la mejor práctica aquí es usar un patrón :ref:`"withdraw" en lugar de un patrón "send" <withdrawal_pattern>`.
     

Profundidad de la Pila de Llamadas
================

Las llamadas a funciones externas pueden fallar en cualquier momento debido a
que exceden el límite de tamaño máximo de la pila de llamadas de 1024. En tales
situaciones, Solidity lanza una excepción. Actores maliciosos podrían ser capaces
de forzar la pila de llamadas a un valor alto antes de que ellos interactúen con
su contrato. Note que, desde el hardfork `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_,
la `regla 63/64 <https://eips.ethereum.org/EIPS/eip-150>`_ hace impráctico el ataque a la profundidad
de la pila de llamadas. También note que la pila de llamadas y la pila de expresiones no están relacionadas,
a pesar de que ambas tienen un límite de tamaño de 1024 ranuras de pilas.

Note que ``.send()`` **no** lanza una excepción si la pila de llamadas está agotada sino que
retorna ``false`` en ese caso. Las funciones de bajo nivel ``.call()``, ``.delegatecall()`` y ``.staticcall()``
se comportan de la misma manera.

Proxies Autorizados
==================

Si su contrato puede actuar como un proxy, i. e. si puede llamar contratos arbitrarios con datos suministrados por el usuario, entonces el usuario puede esencialmente asumir la identidad del contrato proxy. Incluso si tiene otras medidas protectivas en lugar, es mejor construir su sistema de contratos de tal manera que el proxy no tenga cualquier permiso (ni siquiera para sí mismo). De ser necesario, puede lograr eso usando un segundo proxy:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract ProxyWithMoreFunctionality {
        PermissionlessProxy proxy;

        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return proxy.callOther(addr, payload);
        }
        // Otras funciones y otra funcionalidad
    }

    // Este es el contrato entero, no tiene otra funcionalidad y
    // no requiere privilegios para funcionar.
    contract PermissionlessProxy {
        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return addr.call(payload);
        }
    }

tx.origin
=========

Nunca use tx.origin para autorización. Digamos que tiene un contrato de una billetera como este:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // ESTE CONTRATO CONTIENE UN BUG - NO USAR
    contract TxUserWallet {
        address owner;

        constructor() {
            owner = msg.sender;
        }

        function transferTo(address payable dest, uint amount) public {
            // EL BUS ESTA JUSTO AQUÍ, usted debe usar msg.sender en lugar de tx.origin
            require(tx.origin == owner);
            dest.transfer(amount);
        }
    }

Ahora alguien puede engañarlo al enviar Ether a la dirección de esta billetera de ataque:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    interface TxUserWallet {
        function transferTo(address payable dest, uint amount) external;
    }

    contract TxAttackWallet {
        address payable owner;

        constructor() {
            owner = payable(msg.sender);
        }

        receive() external payable {
            TxUserWallet(msg.sender).transferTo(owner, msg.sender.balance);
        }
    }

Si su billetera ha corroborado ``msg.sender`` para autorización, tendría la dirección de la billetera de ataque, en lugar de la dirección del propietario. Pero al validar ``tx.origin``, obtiene la dirección original que empezó la transacción, el cual es aún la dirección del propietario. La billetera de ataque instantáneamente vacía todos sus fondos. 

.. _underflow-overflow:

Complemento a Dos / Underflows / Overflows
=========================================

Como en muchos lenguajes de programación, los tipo enteros de Solidity no son de hecho enteros. 
Ellos se parecen a enteros cuando los valores son pequeños, pero no pueden representar arbitrariamente números grandes.

El siguiente código causa overflow porque el resultado de la adición es demasiado grande para ser almacenado en el tipo ``uint8``:

.. code-block:: solidity

  uint8 x = 255;
  uint8 y = 1;
  return x + y;

Solidity tiene dos modos por medio de los cuales trata overflows: modo verificado y no verificado o "envolvente".

El modo por defecto verificado detectará overflows y causará una aserción que falla.
Usted pude deshabilitar esta verificación usando ``unchecked { ... }``, lo que causa que el overflow sea ignorado silenciosamente. El código de arriba retornaría ``0`` si estuviese envuelto con ``unchecked { ... }``.

Incluso en modo verificado, no asuma que está protegido de bugs de overflow.
En este modo, overflows siempre revertirán. Si no es posible evitar el overflow, esto puede llevar a que un contrato inteligente se quede atascado en cierto estado.

En general, lea sobre los límites de la representación del complemento a dos, la cual tiene otros casos especiales para números con signos.

Trate de usar ``require`` para limitar el tamaño de entradas a un rango rasonable y use :ref:`SMT checker<smt_checker>` para encontrar potenciales overflows.

.. _clearing-mappings:

Limpieza de Mappings
=================

El tipo ``mapping`` (véase :ref:`mapping-types`) de Solidity es una estructura de datos clave-valor de solo almacenamiento que no mantiene un registro de las claves que fueron asignadas un valor no nulo. Debido a ello, limpiar un mapping sin información extra sobre las claves escritas no es posible.
Si ``mapping`` se usa como el tipo base de un array de almacenamiento dinámico, borrar o quitar el último elemento del array no tendrá efecto sobre los elemetos del
``mapping``. Lo mismo sucede, por ejemplo, si un ``mapping`` se usa como el tipo de un campo miembro de un ``struct`` que es el tipo base de un array de almacenamiento dinámico. ``mapping`` también es ignorado in asignaciones de structs o arrays que contienen un ``mapping``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Map {
        mapping(uint => uint)[] array;

        function allocate(uint newMaps) public {
            for (uint i = 0; i < newMaps; i++)
                array.push();
        }

        function writeMap(uint map, uint key, uint value) public {
            array[map][key] = value;
        }

        function readMap(uint map, uint key) public view returns (uint) {
            return array[map][key];
        }

        function eraseMaps() public {
            delete array;
        }
    }

Considere el ejemplo de arriba y la siguiente secuencia de llamadas: ``allocate(10)``,
``writeMap(4, 128, 256)``.
En este punto, llamar ``readMap(4, 128)`` retorna 256.
Si llamamos ``eraseMaps``, la longitud de la variable de estado ``array`` es reestablecida a cero, pero ya que los elementos de ``mapping`` no pueden ser ceros, su información permanece viva en el almacenamiento del contrato. 
Luego de borrar ``array``, invocar ``allocate(5)`` nos permite acceder a ``array[4]`` otra vez, y llamar ``readMap(4, 128)`` retorna 256 incluso sin llarmar a ``writeMap``. 

SI su información de ``mapping`` debe ser eliminada, considere usar una biblioteca similar a `iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_, que le permite atravesar las claves y eliminar sus valores en el ``mapping`` apropiado.

Detalles Menores
=============

- Tipos que no ocupan los 32 bytes completos podrían contener "bits sucios de orden mayor".
  Esto es especialmente importante si usted accede a ``msg.data`` - representa un riesgo de maleabilidad:   
  Usted puede hacer transacciones que invoquen una función ``f(uint8 x)`` con un argumento de ``0xff000001`` y con ``0x00000001``. Ambos se suministran al contrato y ambos parecerán iguales al número ``1`` en lo que respecta a ``x``, pero ``msg.data`` será diferente, así que si usa  ``keccak256(msg.data)`` para algo , obtendrá resultados diferentes.

***************
Recomendaciones
***************

Tome las advertencias seriamente
=======================

Si el compilador le advierte sobre algo, usted debería cambiarlo.
Incluso si usted no cree que esta advertencia particular tiene implicaciones
de seguridad, podría haber otro asunto escondido debajo de ello.
Cualquiera advertencia del compilador que emitimos puede ser silenciada por cambios ligeros al código.

Siempre use la última versión del compilador para ser notificado sobre todas las advertencias introducidas recientemente.

Mensajes de tipo ``info`` emitidos por el compilador no son peligrosos y simplemente representan sugerencias extras e información opcional que el compilador cree que podría ser útil al usuario.

Limite la cantidad de Ether 
============================

Limite la cantidad de Ether (u otros tokens) que pueden ser almacenados en un contrato inteligente. Si su código fuente, el compilador o la plataforma tienen un bug, estos fondos podrían perderse. Si quiere limitar su perdida, limite la cantidad de Ether.

Manténgalo modular y pequeño
=========================

Mantenga sus contratos pequeños y fácilmente entendibles. Eliga funcionalidad no relacionada de otros contratos o bibliotecas. Recomendaciones generales sobre la calidad del código fuente por supuesto aplican: Limite la cantidad de variables locales, la longitud de funciones, etcétera. Documente sus funciones, de modo que otros puedan ver cuál era su intención y si es diferente de lo que hace el código.   

Use el patrón Checks-Effects-Interactions
===========================================

La mayoría de las funciones llevarán a cabo primero algunas verificaciones (quién llamó la función, están los argumentos en rango, se envió suficiente Ether, la persona tiene tokens, etc.). Estas verificaciones deberían ser hechas primero.

Como segundo paso, si todas las verificaciones pasaron, los efectos a las variables de estado del contrato actual deberían tener lugar. La interacción con otros contratos deberían ser el último paso en cualquier función.

<<<<<<< HEAD
Los primeros contratos retrasaban algunos efectos y esperaban por invocaciones a funciones externas para retornar un estado de no error. A menudo esto es un error serio debido a el problema de re-entrancy explicado arriba. 
=======
Early contracts delayed some effects and waited for external function
calls to return in a non-error state. This is often a serious mistake
because of the reentrancy problem explained above.
>>>>>>> english/develop

Note que, también, llamadas a contratos conocidos podrían, después, causar llamadas a contratos desconocidos, así que es probablemente mejor aplicar siempre este patrón. 

Incluye un modo de fallo seguro
========================

Aunque al hacer su sistema completamente descentralizado removerá cualquier intermediario, podría ser una buena idea, especialmente para código nuevo, incluir algún tipo de mecanismo de fallo seguro: 

Puede agregar una función en su contrato inetligente que lleve a cabo algunas auto-verificaciones como "¿Se ha perdido Ether?", "¿La suma de los tokens es igual al balance del contrato?" o cosas similares. No olvide que no puede usar demasiado gas para eso, así que ayuda por medio de computación fuera de la cadena podría ser necesario.   

Si la auto-verificación falla, el contrato automáticamente cambia a un modo de tipo "fallo seguro", el cual, por ejemplo, deshabilita la mayoría de las características, pasa control a un tercero fijo y confiable o solo convierte el contrato a un simple contrato de tipo "devuélvame mi dinero". 

Solicite revisión por pares
===================

Mientras más personas examinan una pieza de código, más problemas se encuentran.
Pedir a las personas que revisen su código también ayuda como un verificación para averiguar si su código es fácil de entender - un criterio muy importante para buenos contratos inteligentes.

