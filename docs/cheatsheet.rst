**********
Apuntes para repaso
**********

.. index:: operator; precedence

Orden de Precedencia de Operadores
================================
.. include:: types/operator-precedence-table.rst

.. index:: assert, block, coinbase, difficulty, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin, revert, require, keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography, this, super, selfdestruct, balance, codehash, send

Variables Globales
================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-decodifica la data provista. Los tipos son dados en paréntesis como segundo argumento. 
  Ejemplo: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-codifica los argumentos dados
- ``abi.encodePacked(...) returns (bytes memory)``: Realiza :ref:`la codificación empaquetada <abi_packed_mode>` de
  los argumentos dados. ¡Note que esta codificación puede ser ambigua!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-codifica los argumentos dados comenzando desde el segundo y antepone el selector dado de cuatro bytes
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI-codifica a llamada a ``functionPointer`` con los argumentos encontrados en la tupla. Realiza un completa verificación de tipos asegurándose que los tipos coincidan con la signatura de la función. El resultado equivale a
   ``abi.encodeWithSelector(functionPointer.selector, (...))``
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Equivalente
  a ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature)), ...)``
- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatena un número variable de argumentos a un array de un byte<bytes-concat>`
- ``string.concat(...) returns (string memory)``: :ref:`Concatena un número variable de argumentos a un array de un string<string-concat>`
- ``block.basefee`` (``uint``): pago base del bloque actual (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ y `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): id de la cadena actual
- ``block.coinbase`` (``address payable``): dirección del minero del bloque actual
- ``block.difficulty`` (``uint``): dificultad del bloque actual
- ``block.gaslimit`` (``uint``): límite de gas del bloque actual
- ``block.number`` (``uint``): número del bloque actual
- ``block.timestamp`` (``uint``): marca de fecha del bloque actual en segundos desde el tiempo Unix
- ``gasleft() returns (uint256)``: gas restante
- ``msg.data`` (``bytes``): datos de llamada completos
- ``msg.sender`` (``address``): remitente del mensaje (llamada actual)
- ``msg.sig`` (``bytes4``): primeros cuatro bytes de los datos de llamada (i.e. identificador de función)
- ``msg.value`` (``uint``): cantidad de wei enviados con el mensaje
- ``tx.gasprice`` (``uint``): precio de gas de la transacción
- ``tx.origin`` (``address``): remitente de la transacción (cadena de la llamada completa)
- ``assert(bool condition)``: aborta la ejecución y revierte los cambios de estado si la condición es ``false`` (usar para error interno)
- ``require(bool condition)``: aborta la ejecución y revierte los cambios de estado si la condición es ``false`` (usar para entradas mal construidas o error en componente externo)
- ``require(bool condition, string memory message)``: aborta la ejecución y revierte los cambios de estado si la condición es ``false`` (usar para entradas mal construidas o error en componente externo). También provee mensaje de error.
- ``revert()``: aborta la ejecución y revierte los cambios de estado
- ``revert(string memory message)``: aborta la ejecución y revierte los cambios de estado proveyendo una cadena de caracteres explicativa
- ``blockhash(uint blockNumber) returns (bytes32)``: hash del bloque dado - solo funciona para los 256 bloques más recientes 
- ``keccak256(bytes memory) returns (bytes32)``: computa el hash Keccak-256 de la entrada
- ``sha256(bytes memory) returns (bytes32)``: computa el hash SHA-256 de la entrada
- ``ripemd160(bytes memory) returns (bytes20)``: computa el hash RIPEMD-160 de la entrada
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: recupera la dirección asociada con la clave pública desde la signatura de curva elíptica, devuelve cero en error. 
- ``addmod(uint x, uint y, uint k) returns (uint)``: computa ``(x + y) % k`` donde la adición se lleva a cabo con precisión arbitraria y no se detiene en ``2**256``. Impone que ``k != 0`` a partir de la versión 0.5.0
- ``mulmod(uint x, uint y, uint k) returns (uint)``: computa ``(x * y) % k`` donde la multiplicación se lleva a cabo con precisión arbitraria y no se detiene en ``2**256``. Impone que ``k != 0`` a partir de la versión 0.5.0.
- ``this`` (tipo del contrato actual): el contrato actual, explícitamente convertible a ``address`` o ``address payable``
- ``super``: un nivel más alto del contrato en la jerarquía de herencia
- ``selfdestruct(address payable recipient)``: destruye el contrato actual enviando sus fondos a la dirección dada
- ``<address>.balance`` (``uint256``): balance de la :ref:`dirección` en Wei
- ``<address>.code`` (``bytes memory``): código en la :ref:`dirección` (puede estar vacío)
- ``<address>.codehash`` (``bytes32``): el código hash de la :ref:`dirección`
- ``<address payable>.send(uint256 amount) returns (bool)``: envía la cantidad dada de Wei a la :ref:`dirección`, regresa ``false`` al fallar
- ``<address payable>.transfer(uint256 amount)``: envía la cantidad dada de Wei a la :ref:`dirección`, lanza una excepción al fallar
- ``type(C).name`` (``string``): el nombre del contrato
- ``type(C).creationCode`` (``bytes memory``): creación en bytecode del contrato dado, véase :ref:`Información de Tipos<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): bytecode en tiempo de ejecución del contrato dado, véase :ref:`Información de Tipos<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): valor que contiene el identificador de la interface EIP-165 de la intergace dada, véase :ref:`Información de Tipos<meta-type>`. 
- ``type(T).min`` (``T``): el valor mínimo representable por el tipo entero ``T``, véase :ref:`Información de Tipos<meta-type>`.
- ``type(T).max`` (``T``): el valor máximo representable por el tipo entero ``T``, véase :ref:`Información de Tipos<meta-type>`.


.. index:: visibility, public, private, external, internal

Especificadores de la Visibilidad de Funciones
==============================

.. code-block:: solidity
    :force:

    function myFunction() <visibility specifier> returns (bool) {
        return true;
    }

- ``public``: visible externamente e internamente (crea una :ref:`función getter<getter-functions>` para variables de estado/almacenamiento)
- ``private``: solamente visible en el contrato actual
- ``external``: solamente visible externamente (solo para funciones) - i.e. solo se puede llamar por mensaje (a través de ``this.func``) 
- ``internal``: solamente visible internamente


.. index:: modifiers, pure, view, payable, constant, anonymous, indexed

Modificadores
=========

- ``pure`` para funciones: No acepta la modificación o acceso al estado.
- ``view`` para funciones: No acepta la modificación del estado.
- ``payable`` para funciones: Permite recibir Ether junto con una llamada.  
- ``constant`` para variables de estado: No permite la asignación (excepto la inicialización), no ocupa lugar de almacenamiento.
- ``immutable`` para variables de estado: Permite exactamente una asignación en el tiempo de construcción y es constante después. Se almacena en el código.
- ``anonymous`` para eventos: No almacena la signatura del evento como tema.
- ``indexed`` para parámetros de eventos: Almacena el parámetro como tema. 
- ``virtual`` para funciones y modificadores: Permite que el comportamiento de las funciones y modificadores se modifique en contratos derivados.
- ``override``: Establece que esta función, modificador o variable de estado pública cambia el comportamiento de una función o modificador en un contrato de base.

<<<<<<< HEAD
<<<<<<< HEAD
Palabras Claves Reservadas
=================

Estas palabras están reservadas en Solidity. Podrían llegar a ser partes de la sintaxis en el futuro:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
=======
>>>>>>> 454603e17051cc9f7e2351d3dd7e79133f7ed6ba
=======
>>>>>>> 9f34322f394fc939fac0bf8b683fd61c45173674
