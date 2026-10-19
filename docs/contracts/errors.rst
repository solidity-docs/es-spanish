.. index:: ! error, revert, require, ! selector; of an error
.. _errors:

<<<<<<< HEAD
*******************************
Errores e Instrucción Revert
*******************************
=======
*************
Custom Errors
*************
>>>>>>> english/develop

Los errores en Solidity proporcionan una forma conveniente y eficiente en gas de explicar al usuario 
por qué ha fallado una operación. Se pueden definir dentro y fuera de los contratos (incluidas las interfaces y bibliotecas).

<<<<<<< HEAD
Deben utilizarse junto con la instrucción :ref:`revert statement <revert-statement>` 
que hace que se reviertan todos los cambios en la llamada actual y que los datos de error se devuelvan al llamador.
=======
They have to be used together with the :ref:`revert statement <revert-statement>`
or the :ref:`require function <assert-and-require-statements>`.
In the case of ``revert`` statements, or ``require`` calls where the condition is evaluated to be false,
all changes in the current call are reverted, and the error data passed back to the caller.

The example below shows custom error usage with the ``revert`` statement in function ``transferWithRevertError``,
as well as the newer approach with ``require`` in function ``transferWithRequireError``.
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.27;

    /// Insufficient balance for transfer. Needed `required` but only
    /// `available` available.
    /// @param available balance available.
    /// @param required requested amount to transfer.
    error InsufficientBalance(uint256 available, uint256 required);

    contract TestToken {
        mapping(address => uint) balance;
        function transferWithRevertError(address to, uint256 amount) public {
            if (amount > balance[msg.sender])
                revert InsufficientBalance({
                    available: balance[msg.sender],
                    required: amount
                });
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        function transferWithRequireError(address to, uint256 amount) public {
            require(amount <= balance[msg.sender], InsufficientBalance(balance[msg.sender], amount));
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        // ...
    }

<<<<<<< HEAD
Los errores no se pueden sobrecargar ni anular, pero se heredan. 
El mismo error se puede definir en varios lugares, siempre y cuando los ámbitos sean distintos. 
Las instancias de errores solo se pueden crear utilizando instrucciones ``revert``.
=======
Another important detail to mention when it comes to using ``require`` with custom errors, is that memory
allocation for the error-based revert reason will only happen in the reverting case, which, along with
optimization of constants and string literals makes this about as gas-efficient as the
``if (!condition) revert CustomError(args)`` pattern.

Errors cannot be overloaded or overridden but are inherited.
The same error can be defined in multiple places as long as the scopes are distinct.
Instances of errors can only be created using ``revert`` statements, or as the second argument to ``require`` functions.
>>>>>>> english/develop

El error crea datos que luego se pasan al llamador con la operación de reversión 
para volver al componente fuera de la cadena o capturarlo en una instrucción :ref:`try/catch <try-catch>`. 
Tenga en cuenta que un error solo se puede detectar cuando proviene de una llamada externa, 
las reversiones que ocurren en llamadas internas o dentro de la misma función no se pueden capturar.

Si no proporciona ningún parámetro, el error solo necesita cuatro bytes de datos 
y puede utilizar :ref:`NatSpec <natspec>` como se indica anteriormente 
para explicar más a fondo las razones del error, que no se almacena en la cadena. 
Esto hace que esta sea una función de informe de errores muy barata y conveniente al mismo tiempo.

Más específicamente, una instancia de error está codificada en ABI de la misma manera que 
sería una llamada a una función del mismo nombre y tipos 
y luego utilizada como los datos devueltos en el opcode ``revert``. 
Esto significa que los datos consisten en un selector de 4 bytes seguido por datos de :ref:`ABI-encoded<abi>`. 
El selector consiste en los primeros 4 bytes del hash keccak256 de la firma del tipo de error.

.. note::
    Es posible que un contrato se revierta 
    con diferentes errores del mismo nombre o incluso con errores definidos en diferentes lugares 
    que no son identificables por el llamante. Para el exterior, es decir, el ABI, 
    sólo el nombre del error es relevante, no el contrato o el archivo donde está definido.

<<<<<<< HEAD
La sentencia ``require(condition, "description");`` sería equivalente a 
``if (!condition) revert Error("description")`` si pudiera definir 
``error Error(string)``. 
Tenga en cuenta, sin embargo, que ``Error`` es un tipo integrado y no se puede definir en código proporcionado por el usuario.
=======
The statement ``require(condition, "description");`` would be equivalent to
``if (!condition) revert Error("description")`` if you could define ``error Error(string)``.
Note, however, that ``Error`` is a built-in type and cannot be defined in user-supplied code.
>>>>>>> english/develop

De manera similar, un ``assert`` o condiciones similares se revertirán con un error
del tipo integrado ``Panic(uint256)``

.. note::
    Los datos de error sólo se deben utilizar para indicar un fallo, pero 
    no como un medio para el control de flujo. El motivo es que los datos de reversión 
    de llamadas internas se propaga de vuelta a través de la cadena de llamadas externas 
    de forma predeterminada. Esto significa que una llamada interna 
    puede “forjar” datos de reversión que parecen haber venido del 
    contrato que lo llamó.

Miembros de Errores
=================

- ``error.selector``: Un valor de ``bytes4`` que contiene el selector de errores.
