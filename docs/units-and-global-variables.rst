.. index:: ! denomination

**************************************
Unidades y variables disponibles globalmente
**************************************

.. index:: ! wei, ! finney, ! szabo, ! gwei, ! ether, ! denomination;ether

Unidades de Ether
===========

Un número literal puede tomar un sufijo de ``wei``, ``gwei`` o ``ether`` para especificar una subdenominación de Ether, donde números de Ether sin un postfix se supone que son Wei.

.. code-block:: solidity
    :force:

    assert(1 wei == 1);
    assert(1 gwei == 1e9);
    assert(1 ether == 1e18);

El único efecto del sufijo subdenominación es una multiplicación por una potencia de diez.

.. note::
    Las denominaciones ``finney`` y ``szabo`` se han eliminado en la versión 0.7.0.

.. index:: ! seconds, ! minutes, ! hours, ! days, ! weeks, ! years, ! denomination;time

Unidades de tiempo
==========

Sufijos como ``seconds``, ``minutes``, ``hours``, ``days`` y ``weeks``
después de números literales se pueden utilizar para especificar unidades de tiempo donde segundos son la unidad base y las unidades se consideran ingenuamente de la siguiente manera:

* ``1 == 1 seconds``
* ``1 minutes == 60 seconds``
* ``1 hours == 60 minutes``
* ``1 days == 24 hours``
* ``1 weeks == 7 days``

Tenga cuidado si realiza cálculos de calendario utilizando estas unidades, porque
no todos los años equivalen a 365 días y ni siquiera todos los días tienen 24 horas debido a `segundos bisiestos <https://en.wikipedia.org/wiki/Leap_second>`_.
Debido a que los segundos bisiestos no se pueden predecir, una librería de calendario exacta tiene que ser actualizado por un oráculo externo.

.. note::
    El sufijo ``years`` se ha quitado en la versión 0.5.0 debido a las razones anteriores.

Estos sufijos no se pueden aplicar a las variables. Por ejemplo, si quieres interpretar un parámetro de función en días, puede hacerlo de las siguientes maneras:

.. code-block:: solidity

    function f(uint start, uint daysAfter) public {
        if (block.timestamp >= start + daysAfter * 1 days) {
            // ...
        }
    }

.. _special-variables-functions:

Variables y funciones especiales
===============================

Hay variables y funciones especiales que siempre existen en el espacio de nombres global y se utilizan principalmente para proporcionar información sobre el blockchain
o son funciones de utilidad de uso general.

.. index:: abi, block, coinbase, difficulty, prevrandao, encode, number, block;number, timestamp, block;timestamp, block;basefee, block;blobbasefee, msg, data, gas, sender, value, gas price, origin


Propiedades de bloques y transacciones
--------------------------------

<<<<<<< HEAD
- ``blockhash(uint blockNumber) returns (bytes32)``: hash del bloque dado cuando ``blocknumber`` es uno de los 256 bloques más recientes; de lo contrario devuelve cero
- ``block.basefee`` (``uint``): tarifa base del bloque actual (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ y `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): ID de cadena actual
- ``block.coinbase`` (``address payable``): dirección actual del minero del bloque
- ``block.difficulty`` (``uint``): dificultad del bloque actual. Para otras versiones de EVM se comporta como un alias obsoleto de 
``block.prevrandao`` (`EIP-4399 <https://eips.ethereum.org/EIPS/eip-4399>`_ )
- ``block.gaslimit`` (``uint``): límite de gas del bloque actual
- ``block.number`` (``uint``): número de bloque actual
- ``block.timestamp`` (``uint``): marca de tiempo de bloque actual como segundos desde la época unix
- ``gasleft() returns (uint256)``: gas restante
- ``msg.data`` (``bytes calldata``): calldata completo
- ``msg.sender`` (``address``): remitente del mensaje (llamada actual)
- ``msg.sig`` (``bytes4``): primeros cuatro bytes de calldata (i.e. identificador de función)
- ``msg.value`` (``uint``): número de wei enviado con el mensaje
- ``tx.gasprice`` (``uint``): precio del gas de la transacción
- ``tx.origin`` (``address``): remitente de la transacción (cadena de llamadas completa)
=======
- ``blockhash(uint blockNumber) returns (bytes32)``: hash of the given block when ``blocknumber`` is one of the 256 most recent blocks; otherwise returns zero
- ``blobhash(uint index) returns (bytes32)``: versioned hash of the ``index``-th blob associated with the current transaction.
  A versioned hash consists of a single byte representing the version (currently ``0x01``), followed by the last 31 bytes
  of the SHA256 hash of the KZG commitment (`EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_).
- ``block.basefee`` (``uint``): current block's base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.blobbasefee`` (``uint``): current block's blob base fee (`EIP-7516 <https://eips.ethereum.org/EIPS/eip-7516>`_ and `EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_)
- ``block.chainid`` (``uint``): current chain id
- ``block.coinbase`` (``address payable``): current block miner's address
- ``block.difficulty`` (``uint``): current block difficulty (``EVM < Paris``). For other EVM versions it behaves as a deprecated alias for ``block.prevrandao`` (`EIP-4399 <https://eips.ethereum.org/EIPS/eip-4399>`_ )
- ``block.gaslimit`` (``uint``): current block gaslimit
- ``block.number`` (``uint``): current block number
- ``block.prevrandao`` (``uint``): random number provided by the beacon chain (``EVM >= Paris``)
- ``block.timestamp`` (``uint``): current block timestamp as seconds since unix epoch
- ``gasleft() returns (uint256)``: remaining gas
- ``msg.data`` (``bytes calldata``): complete calldata
- ``msg.sender`` (``address``): sender of the message (current call)
- ``msg.sig`` (``bytes4``): first four bytes of the calldata (i.e. function identifier)
- ``msg.value`` (``uint``): number of wei sent with the message
- ``tx.gasprice`` (``uint``): gas price of the transaction
- ``tx.origin`` (``address``): sender of the transaction (full call chain)
>>>>>>> english/develop

.. note::
    Los valores de todos los miembros de ``msg``, incluyendo ``msg.sender`` y
    ``msg.value`` pueden cambiar para cada llamada a una función **externa**.
    Esto incluye llamadas a funciones de librería.

.. note::
    Cuando se evalúan los contratos fuera de la cadena en lugar de en contexto de una transacción incluido en un bloque, no debería asumir que ``block.*`` y ``tx.*`` se refieren a valores de cualquier bloque o transacción específica. Estos valores son proporcionados por la implementación de EVM que ejecuta el contrato y pueden ser arbitrarios.

.. note::
    No confíe en ``block.timestamp`` o ``blockhash`` como fuente de aleatoriedad,
    a menos que sepas lo que estás haciendo.

<<<<<<< HEAD
    Tanto la marca de tiempo y el hash de bloque pueden ser influenciados por los mineros hasta cierto punto.
    Malos actores en la comunidad minera pueden, por ejemplo, ejecutar una función de pago de casino en un hash elegido y simplemente reintentar un hash diferente si no recibieron dinero.
=======
    Both the timestamp and the block hash can be influenced by miners to some degree.
    Bad actors in the mining community can for example run a casino payout function on a chosen hash
    and just retry a different hash if they did not receive any compensation, e.g. Ether.
>>>>>>> english/develop

    La marca de fecha del bloque actual debe ser estrictamente más grande que la marca de fecha del último bloque, pero la única garantía es que estará entre las marcas de fecha de dos bloques consecutivos en la cadena canónica.

.. note::
    Los hashes de bloque no están disponibles para todos los bloques por razones de escalabilidad. Solo puede acceder a los hashes de los 256 bloques más recientes, todos los demás valores serán cero.

.. note::
    La función ``blockhash`` se conocía anteriormente como ``block.blockhash``, que quedó en desuso en la versión 0.4.22 y eliminado en la versión 0.5.0.

.. note::
    La función ``gasleft`` se conocía anteriormente como ``msg.gas``, que quedó en desuso en la versión 0.4.21 y eliminado en la versión 0.5.0.

.. note::
    En versión 0.7.0, el alias ``now`` (para ``block.timestamp``) se quitó.

.. index:: abi, encoding, packed

Funciones de codificación y decodificación ABI
-----------------------------------

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: ABI-decodifica los datos dados, mientras que los tipos se dan entre paréntesis como segundo argumento. Ejemplo: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: ABI codifica los argumentos dados
- ``abi.encodePacked(...) returns (bytes memory)``: Realiza :ref:`packed encoding <abi_packed_mode>` de los argumentos dados. ¡Tenga en cuenta que la codificación empaquetada puede ser ambigua!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: ABI codifica los argumentos dados a partir del segundo y antepone el selector de cuatro bytes dado
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Equivalente a ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI codifica una llamada a ``functionPointer`` con los argumentos encontrados en la tupla. Realiza una comprobación de tipo completa, garantizar que los tipos coincidan la firma de la función. El resultado es igual a ``abi.encodeWithSelector(functionPointer.selector, (...))``

.. note::
    Estas funciones de codificación se pueden utilizar para crear datos para llamadas a funciones externas sin llamar realmente a una función externa. Además, ``keccak256(abi.encodePacked(a, b))`` es una forma de calcular el hash de los datos estructurados (aunque tenga en cuenta que es posible crear una "colisión de hash" usando diferentes tipos de parámetros de función).

Consulte la documentación sobre la :ref:`ABI <ABI>` y la
:ref:`codificación tightly packed <abi_packed_mode>` para obtener más información sobre la codificación.

.. index:: bytes members

Miembros de bytes
----------------

- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatena el número de variable de bytes y bytes1, ..., argumentos de bytes32 para una matriz de bytes<bytes-concat>`

.. index:: string members

Miembros de cadena
-----------------

- ``string.concat(...) returns (string memory)``: :ref:`Concatena el número variable de argumentos de cadena en una matriz de cadenas<string-concat>`


.. index:: assert, revert, require

Manejo de errores
--------------

Consulte la sección dedicada a :ref:`assert y require<assert-and-require>` para obtener más información sobre el control de errores y cuándo usar qué función.

``assert(bool condition)``
    provoca un error de pánico y, por lo tanto, cambiar el estado de reversión si no se cumple la condición - para ser utilizado para errores internos.

``require(bool condition)``
    se revierte si no se cumple la condición - para ser utilizado para errores en componentes internos o externos.

``require(bool condition, string memory message)``
    se revierte si no se cumple la condición - para ser utilizado para errores en componentes internos o externos. También proporciona un mensaje de error.

``revert()``
    anular la ejecución y revertir los cambios de estado

``revert(string memory reason)``
    anular la ejecución y revertir los cambios de estado, proporcionar una cadena explicativa

.. index:: keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography,

.. _mathematical-and-cryptographic-functions:

Funciones matemáticas y criptográficas
----------------------------------------

``addmod(uint x, uint y, uint k) returns (uint)``
    calcular ``(x + y) % k`` donde se realiza la adición con precisión arbitraria y no se envuelve en ``2**256``. Afirman que ``k != 0`` a partir de la versión 0.5.0.

``mulmod(uint x, uint y, uint k) returns (uint)``
    calcular ``(x * y) % k`` donde se realiza la multiplicación con precisión arbitraria y no se envuelve en ``2**256``. Afirman que ``k != 0`` a partir de la versión 0.5.0.

``keccak256(bytes memory) returns (bytes32)``
    computadora el hash Keccak-256 de la entrada

.. note::

    Solía haber un alias para ``keccak256`` llamado ``sha3``, que se eliminó en la versión 0.5.0.

``sha256(bytes memory) returns (bytes32)``
    computa el hash SHA-256 de la entrada

``ripemd160(bytes memory) returns (bytes20)``
    computa el hash RIPEMD-160 de la entrada

``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``
    recupera la dirección asociada con la clave pública de la firma de curva elíptica o devuelva cero en el error.
    Los parámetros de la función corresponden a los valores de ECDSA de la firma:

    * ``r`` = primeros 32 bytes de firma
    * ``s`` = segundo 32 bytes of signature
    * ``v`` = 1 byte final de firma

    ``ecrecover`` devuelve una ``address``, y no una ``address payable``. Ver :ref:`dirección payable<address>` para la conversión, en caso de que necesite transferir fondos a la dirección recuperada.

    Para más detalles, lea `ejemplo de uso <https://ethereum.stackexchange.com/questions/1777/workflow-on-signing-a-string-with-private-key-followed-by-signature-verificatio>`_.

.. warning::

    Si utiliza ``ecrecover``, tenga en cuenta que una firma válida se puede convertir en una firma válida diferente sin requerir el conocimiento de la clave privada correspondiente. En la bifurcación dura de Homestead, este problema se ha corregido para las firmas de _transaction_ (see `EIP-2 <https://eips.ethereum.org/EIPS/eip-2#specification>`_), pero la función ecrecover permaneció sin cambios.

<<<<<<< HEAD
    Por lo general, esto no es un problema a menos que requiera que las firmas sean únicas o utilícelos para identificar elementos. OpenZeppelin tiene una `biblioteca auxiliar de ECDSA <https://docs.openzeppelin.com/contracts/2.x/api/cryptography#ECDSA>`_ que puede usar como envoltorio para ``ecrecover`` sin este problema.
=======
    This is usually not a problem unless you require signatures to be unique or use them to identify items.
    OpenZeppelin has an `ECDSA helper library <https://docs.openzeppelin.com/contracts/4.x/api/utils#ECDSA>`_ that you can use as a wrapper for ``ecrecover`` without this issue.
>>>>>>> english/develop

.. note::

    Al ejecutar ``sha256``, ``ripemd160`` o ``ecrecover`` en un *blockchain privado*, es posible que se encuentre sin gas. Esto se debe a que estas funciones se implementan como "contratos precompilados" y solo existen realmente después de recibir el primer mensaje (aunque su código de contrato está codificado). Los mensajes a contratos inexistentes son más caros y, por lo tanto, la ejecución podría encontrarse con un error de falta de gas. Una solución para este problema es enviar primero Wei (1 por ejemplo) a cada uno de los contratos antes de utilizarlos en sus contratos reales. Esto no es un problema en la red principal o de prueba.

.. index:: balance, codehash, send, transfer, call, callcode, delegatecall, staticcall

.. _address_related:

Miembros de tipos de direcciones
------------------------

``<address>.balance`` (``uint256``)
    balance de la :ref:`dirección` en Wei

``<address>.code`` (``bytes memory``)
    código en la :ref:`dirección` (puede estar vacío)

``<address>.codehash`` (``bytes32``)
    el codehash de la :ref:`dirección`

``<address payable>.transfer(uint256 amount)``
    envía la cantidad dada de Wei a :ref:`dirección`, revierte en caso de error, adelanta 2300 estipendios de gas, no ajustable

``<address payable>.send(uint256 amount) returns (bool)``
    envìa la cantidad dada de Wei a :ref:`dirección`, devuelve ``false`` en caso de error, adelanta 2300 estipendios de gas, no ajustable

``<address>.call(bytes memory) returns (bool, bytes memory)``
    emite ``CALL`` de bajo nivel con la carga útil dada, devuelve la condición de éxito y devuelve datos, reenvía todo el gas disponible, ajustable

``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``
    emite  ``DELEGATECALL`` de bajo nivel con la carga útil dada, devuelve la condición de éxito y devuelve datos, reenvía todo el gas disponible, ajustable

``<address>.staticcall(bytes memory) returns (bool, bytes memory)``
    emite ``STATICCALL`` de bajo nivel con la carga útil dada, devuelve la condición de éxito y devuelve datos, reenvía todo el gas disponible, ajustable

Para obtener más información, consulte la sección sobre :ref:`dirección`.

.. warning::
    Debe evitar usar ``.call()`` siempre que sea posible al ejecutar otra función de contrato, ya que omite la comprobación de tipo, comprobación de existencia de funciones y empaquetado de argumentos.

.. warning::
<<<<<<< HEAD
    Hay algunos peligros en el uso de ``send``: La transferencia falla si la profundidad de la pila de llamadas está en 1024 (esto siempre puede ser forzado por el autor de la llamada) y también falla si el receptor se queda sin gasolina. Entonces,
    para hacer transferencias seguras de Ether, compruebe siempre el valor devuelto de ``send``, usar ``transfer`` o incluso mejor:
    Use un patrón en el que el destinatario retire el dinero.
=======
    There are some dangers in using ``send``: The transfer fails if the call stack depth is at 1024
    (this can always be forced by the caller) and it also fails if the recipient runs out of gas. So in order
    to make safe Ether transfers, always check the return value of ``send``, use ``transfer`` or even better:
    Use a pattern where the recipient withdraws the Ether.
>>>>>>> english/develop

.. warning::
    Debido a que la EVM considera que una llamada a un contrato inexistente siempre tiene éxito,
    Solidity incluye una comprobación adicional utilizando el opcode ``extcodesize`` al realizar llamadas externas.
    Esto asegura que el contrato que está a punto de ser llamado realmente existe (contiene código)
    o se genera una excepción.

    Las llamadas de bajo nivel que operan en direcciones en lugar de instancias de contrato (i.e. ``.call()``,
    ``.delegatecall()``, ``.staticcall()``, ``.send()`` y ``.transfer()``) **no** incluya esta
    comprobación, lo que los hace más baratos en términos de gas, pero también menos seguros.

.. note::
    Antes de la versión 0.5.0, Solidity permitió que se accediera a los miembros de la dirección mediante una instancia de contrato, por ejemplo ``this.balance``.
    Esto ahora está prohibido y se debe hacer una conversión explícita a la dirección: ``address(this).balance``.

.. note::
    Si se accede a las variables de estado a través de una delegatecall de bajo nivel, el diseño de almacenamiento de los dos contratos debe alinearse para que el contrato llamado tenga acceso correctamente a las variables de almacenamiento del contrato de llamada por su nombre.
    Por supuesto, este no es el caso si los punteros de almacenamiento se pasan como argumentos de función como en el caso de las bibliotecas de alto nivel.

.. note::
    Antes de la versión 0.5.0, ``.call``, ``.delegatecall`` y ``.staticcall`` solo devolvieron la condición de éxito y no los datos de devolución.

.. note::
    Antes de la versión 0.5.0, había un miembro llamado ``callcode`` con una semántica similar pero ligeramente diferente a la de ``delegatecall``.


.. index:: this, selfdestruct, super

<<<<<<< HEAD
Relacionados con el contrato
----------------

``this`` (tipo de contrato actual)
    el contrato actual, explícitamente convertible en :ref:`dirección`
=======
Contract-related
----------------

``this`` (current contract's type)
    The current contract, explicitly convertible to :ref:`address`

``super``
    A contract one level higher in the inheritance hierarchy
>>>>>>> english/develop

``selfdestruct(address payable recipient)``
    Destruir el contrato actual, enviando sus fondos a la :ref:`dirección`
    dada y finalizar la ejecución.
    Tenga en cuenta que ``selfdestruct`` tiene algunas peculiaridades heredadas del EVM:

    - la función de recepción del contrato receptor no se ejecuta.
    - el contrato solo se destruye realmente al final de la transacción y ``revert`` podría "deshacer" la destrucción.

Además, todas las funciones del contrato actual son llamables directamente, incluida la función actual.

.. warning::
<<<<<<< HEAD
    A partir de la versión 0.8.18, el uso de ``selfdestruct`` tanto en Solidity como en Yul provocará una advertencia de obsoleto, ya que el opcode       ``SELFDESTRUCT`` sufrirá eventualmente cambios en su comportamiento.
    deprecation warning, ya que el opcode ``SELFDESTRUCT`` sufrirá eventualmente cambios en su comportamiento
    como se indica en `EIP-6049 <https://eips.ethereum.org/EIPS/eip-6049>`_.
=======
    From version 0.8.18 and up, the use of ``selfdestruct`` in both Solidity and Yul will trigger a
    deprecation warning, since the ``SELFDESTRUCT`` opcode will eventually undergo breaking changes in behavior
    as stated in `EIP-6049 <https://eips.ethereum.org/EIPS/eip-6049>`_.
>>>>>>> english/develop

.. note::
    Antes de la versión 0.5.0, había una función llamada ``suicide`` con la misma semántica que ``selfdestruct``.

.. index:: type, creationCode, runtimeCode

.. _meta-type:

Información de tipo
----------------

La expresión ``type(X)`` se puede utilizar para recuperar información sobre el tipo
``X``. Actualmente, la compatibilidad con esta característica es limitada (``X`` puede ser un contrato o un tipo entero) pero podría ampliarse en el futuro.

Las siguientes propiedades están disponibles para un tipo de contrato ``C``:

``type(C).name``
    El nombre del contrato.

``type(C).creationCode``
    Matriz de bytes de memoria que contiene el código de bytes de creación del contrato.
    Esto se puede utilizar en el ensamblaje en línea para crear rutinas de creación personalizadas, especialmente mediante el uso del opcode ``create2``.
    **No** se puede acceder a esta propiedad en el propio contrato o en cualquier contrato derivado. Hace que el bytecode se incluya en el bytecode del sitio de la llamada y, por lo tanto, las referencias circulares como esa no son posibles.

``type(C).runtimeCode``
    Matriz de bytes de memoria que contiene el código de bytes en tiempo de ejecución del contrato.
    Este es el código que suele implementar el constructor de ``C``.
    Si ``C`` tiene un constructor que utiliza un conjunto en línea, esto podría ser diferente del bytecode realmente implementado. Tenga en cuenta también que las librerías modifican su bytecode en tiempo de ejecución en el momento de la implementación para protegerse contra las llamadas regulares.
    Las mismas restricciones que con ``.creationCode`` también se aplican a esta propiedad.

Además de las propiedades anteriores, las siguientes propiedades están disponibles
para un tipo de interfaz ``I``:

<<<<<<< HEAD
``type(I).interfaceId``:
    Un valor ``bytes4`` que contiene el `EIP-165 <https://eips.ethereum.org/EIPS/eip-165>`_
    identificador de interfaz de la interfaz dada ``I``. Este identificador se define como el ``XOR`` de todos los selectores de funciones definidos dentro de la propia interfaz - excluyendo todas las funciones heredadas.
=======
``type(I).interfaceId``
    A ``bytes4`` value containing the `EIP-165 <https://eips.ethereum.org/EIPS/eip-165>`_
    interface identifier of the given interface ``I``. This identifier is defined as the ``XOR`` of all
    function selectors defined within the interface itself - excluding all inherited functions.
>>>>>>> english/develop

Las siguientes propiedades están disponibles para un tipo entero ``T``:

``type(T).min``
    El valor más pequeño representable por el tipo ``T``.

``type(T).max``
    El valor más grande representable por el tipo ``T``.

Palabras clave reservadas
=================

Estas palabras clave están reservadas en Solidity. Podrían formar parte de la sintaxis en el futuro:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
