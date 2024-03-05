**********
Apuntes para repaso
**********

.. index:: operator;precedence

Orden de Precedencia de Operadores
================================

.. include:: types/operator-precedence-table.rst

.. index:: abi;decode, abi;encode, abi;encodePacked, abi;encodeWithSelector, abi;encodeCall, abi;encodeWithSignature

<<<<<<< HEAD
Variables Globales
================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-decodifica la data provista. Los tipos son dados en paréntesis como segundo argumento. 
  Ejemplo: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-codifica los argumentos dados
- ``abi.encodePacked(...) returns (bytes memory)``: Realiza :ref:`la codificación empaquetada <abi_packed_mode>` de
  los argumentos dados. ¡Note que esta codificación puede ser ambigua!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-codifica los argumentos dados comenzando desde el segundo y antepone el selector dado de cuatro bytes
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI-codifica a llamada a ``functionPointer`` con los argumentos encontrados en la tupla. Realiza un completa verificación de tipos asegurándose que los tipos coincidan con la signatura de la función. El resultado equivale a ``abi.encodeWithSelector(functionPointer.selector, (...))``
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
=======
ABI Encoding and Decoding Functions
===================================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-decodes
  the provided data. The types are given in parentheses as second argument.
  Example: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-encodes the given arguments
- ``abi.encodePacked(...) returns (bytes memory)``: Performs :ref:`packed encoding <abi_packed_mode>` of
  the given arguments. Note that this encoding can be ambiguous!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-encodes
  the given arguments starting from the second and prepends the given four-byte selector
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI-encodes a call to ``functionPointer`` with the arguments found in the
  tuple. Performs a full type-check, ensuring the types match the function signature. Result equals ``abi.encodeWithSelector(functionPointer.selector, (...))``
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Equivalent
  to ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``

.. index:: bytes;concat, string;concat

Members of ``bytes`` and  ``string``
====================================

- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatenates variable number of
  arguments to one byte array<bytes-concat>`

- ``string.concat(...) returns (string memory)``: :ref:`Concatenates variable number of
  arguments to one string array<string-concat>`

.. index:: address;balance, address;codehash, address;send, address;code, address;transfer

Members of ``address``
======================

- ``<address>.balance`` (``uint256``): balance of the :ref:`address` in Wei
- ``<address>.code`` (``bytes memory``): code at the :ref:`address` (can be empty)
- ``<address>.codehash`` (``bytes32``): the codehash of the :ref:`address`
- ``<address>.call(bytes memory) returns (bool, bytes memory)``: issue low-level ``CALL`` with the given payload,
  returns success condition and return data
- ``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``: issue low-level ``DELEGATECALL`` with the given payload,
  returns success condition and return data
- ``<address>.staticcall(bytes memory) returns (bool, bytes memory)``: issue low-level ``STATICCALL`` with the given payload,
  returns success condition and return data
- ``<address payable>.send(uint256 amount) returns (bool)``: send given amount of Wei to :ref:`address`,
  returns ``false`` on failure
- ``<address payable>.transfer(uint256 amount)``: send given amount of Wei to :ref:`address`, throws on failure

.. index:: blockhash, blobhash, block, block;basefee, block;blobbasefee, block;chainid, block;coinbase, block;difficulty, block;gaslimit, block;number, block;prevrandao, block;timestamp
.. index:: gasleft, msg;data, msg;sender, msg;sig, msg;value, tx;gasprice, tx;origin

Block and Transaction Properties
================================

- ``blockhash(uint blockNumber) returns (bytes32)``: hash of the given block - only works for 256 most recent blocks
- ``blobhash(uint index) returns (bytes32)``: versioned hash of the ``index``-th blob associated with the current transaction.
  A versioned hash consists of a single byte representing the version (currently ``0x01``), followed by the last 31 bytes
  of the SHA256 hash of the KZG commitment (`EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_).
- ``block.basefee`` (``uint``): current block's base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.blobbasefee`` (``uint``): current block's blob base fee (`EIP-7516 <https://eips.ethereum.org/EIPS/eip-7516>`_ and `EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_)
- ``block.chainid`` (``uint``): current chain id
- ``block.coinbase`` (``address payable``): current block miner's address
- ``block.difficulty`` (``uint``): current block difficulty (``EVM < Paris``). For other EVM versions it behaves as a deprecated alias for ``block.prevrandao`` that will be removed in the next breaking release
- ``block.gaslimit`` (``uint``): current block gaslimit
- ``block.number`` (``uint``): current block number
- ``block.prevrandao`` (``uint``): random number provided by the beacon chain (``EVM >= Paris``) (see `EIP-4399 <https://eips.ethereum.org/EIPS/eip-4399>`_ )
- ``block.timestamp`` (``uint``): current block timestamp in seconds since Unix epoch
- ``gasleft() returns (uint256)``: remaining gas
- ``msg.data`` (``bytes``): complete calldata
- ``msg.sender`` (``address``): sender of the message (current call)
- ``msg.sig`` (``bytes4``): first four bytes of the calldata (i.e. function identifier)
- ``msg.value`` (``uint``): number of wei sent with the message
- ``tx.gasprice`` (``uint``): gas price of the transaction
- ``tx.origin`` (``address``): sender of the transaction (full call chain)

.. index:: assert, require, revert

Validations and Assertions
==========================

- ``assert(bool condition)``: abort execution and revert state changes if condition is ``false`` (use for internal error)
- ``require(bool condition)``: abort execution and revert state changes if condition is ``false`` (use
  for malformed input or error in external component)
- ``require(bool condition, string memory message)``: abort execution and revert state changes if
  condition is ``false`` (use for malformed input or error in external component). Also provide error message.
- ``revert()``: abort execution and revert state changes
- ``revert(string memory message)``: abort execution and revert state changes providing an explanatory string

.. index:: cryptography, keccak256, sha256, ripemd160, ecrecover, addmod, mulmod

Mathematical and Cryptographic Functions
========================================

- ``keccak256(bytes memory) returns (bytes32)``: compute the Keccak-256 hash of the input
- ``sha256(bytes memory) returns (bytes32)``: compute the SHA-256 hash of the input
- ``ripemd160(bytes memory) returns (bytes20)``: compute the RIPEMD-160 hash of the input
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: recover address associated with
  the public key from elliptic curve signature, return zero on error
- ``addmod(uint x, uint y, uint k) returns (uint)``: compute ``(x + y) % k`` where the addition is performed with
  arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.
- ``mulmod(uint x, uint y, uint k) returns (uint)``: compute ``(x * y) % k`` where the multiplication is performed
  with arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.

.. index:: this, super, selfdestruct

Contract-related
================

- ``this`` (current contract's type): the current contract, explicitly convertible to ``address`` or ``address payable``
- ``super``: a contract one level higher in the inheritance hierarchy
- ``selfdestruct(address payable recipient)``: destroy the current contract, sending its funds to the given address

.. index:: type;name, type;creationCode, type;runtimeCode, type;interfaceId, type;min, type;max

Type Information
================

- ``type(C).name`` (``string``): the name of the contract
- ``type(C).creationCode`` (``bytes memory``): creation bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): runtime bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): value containing the EIP-165 interface identifier of the given interface, see :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): the minimum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): the maximum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.
>>>>>>> english/develop


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

<<<<<<< HEAD
- ``pure`` para funciones: No acepta la modificación o acceso al estado.
- ``view`` para funciones: No acepta la modificación del estado.
- ``payable`` para funciones: Permite recibir Ether junto con una llamada.  
- ``constant`` para variables de estado: No permite la asignación (excepto la inicialización), no ocupa lugar de almacenamiento.
- ``immutable`` para variables de estado: Permite exactamente una asignación en el tiempo de construcción y es constante después. Se almacena en el código.
- ``anonymous`` para eventos: No almacena la signatura del evento como tema.
- ``indexed`` para parámetros de eventos: Almacena el parámetro como tema. 
- ``virtual`` para funciones y modificadores: Permite que el comportamiento de las funciones y modificadores se modifique en contratos derivados.
- ``override``: Establece que esta función, modificador o variable de estado pública cambia el comportamiento de una función o modificador en un contrato de base.
=======
- ``pure`` for functions: Disallows modification or access of state.
- ``view`` for functions: Disallows modification of state.
- ``payable`` for functions: Allows them to receive Ether together with a call.
- ``constant`` for state variables: Disallows assignment (except initialization), does not occupy storage slot.
- ``immutable`` for state variables: Allows assignment at construction time and is constant when deployed. Is stored in code.
- ``anonymous`` for events: Does not store event signature as topic.
- ``indexed`` for event parameters: Stores the parameter as topic.
- ``virtual`` for functions and modifiers: Allows the function's or modifier's
  behavior to be changed in derived contracts.
- ``override``: States that this function, modifier or public state variable changes
  the behavior of a function or modifier in a base contract.

>>>>>>> english/develop
