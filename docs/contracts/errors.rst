.. index:: ! error, revert, ! selector; of an error
.. _errors:

*******************************
Errores y Instrucción Revert
*******************************

Los errores de solidez proporcionan una forma conveniente y eficiente de la eficiencia del gas de explicar al usuario 
por qué ha fallado una operación. Se pueden definir dentro y fuera de los contratos (incluidas las interfaces y bibliotecas).

Deben utilizarse junto con la instrucción :ref:`revert statement <revert-statement>` 
que hace que se reviertan todos los cambios en la llamada actual y que los datos de error se devuelvan al llamador.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Insufficient balance for transfer. Needed `required` but only
    /// `available` available.
    /// @param available balance available.
    /// @param required requested amount to transfer.
    error InsufficientBalance(uint256 available, uint256 required);

    contract TestToken {
        mapping(address => uint) balance;
        function transfer(address to, uint256 amount) public {
            if (amount > balance[msg.sender])
                revert InsufficientBalance({
                    available: balance[msg.sender],
                    required: amount
                });
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        // ...
    }

Los errores no se pueden sobrecargar ni anular, pero se heredan. 
El mismo error se puede definir en varios lugares, siempre y cuando los ámbitos sean distintos. 
Las instancias de errores solo se pueden crear utilizando instrucciones ``revert``.

El error crea datos que luego se pasan al llamador con la operación de reversión 
para volver al componente fuera de la cadena o capturarlo en una instrucción :ref:`try/catch <try-catch>`. 
Tenga en cuenta que un error solo se puede detectar cuando proviene de una llamada externa, 
las reversiones que ocurren en llamadas internas o dentro de la misma función no se pueden capturar.

Si no proporciona ningún parámetro, el error sólo necesita cuatro bytes de datos 
y puede utilizar :ref:`NatSpec <natspec>` como se indica anteriormente 
para explicar más a fondo las razones del error, que no se almacena en cadena. 
Esto hace que esta sea una función de informe de errores muy barata y conveniente al mismo tiempo.

Más específicamente, una instancia de error está codificada en ABI de la misma manera que 
una llamada a una función del mismo nombre y tipos sería 
y luego utilizada como los datos devueltos en el opcode ``revert``. 
Esto significa que los datos consisten en un selector de 4 bytes seguido por datos de :ref:`ABI-encoded<abi>`. 
El selector consiste en los primeros 4 bytes del hash keccak256 de la firma del tipo de error.

.. note::
    Es posible que un contrato se revierta 
    con diferentes errores del mismo nombre o incluso con errores definidos en diferentes lugares 
    que no son identificables por el llamante. Para el exterior, es decir, el ABI, 
    sólo el nombre del error es relevante, no el contrato o el archivo donde está definido.

La frase ``require(condition, "description");`` sería equivalente a 
``if (!condition) revert Error("description")`` si pudiera definir 
``error Error(string)``. 
Tenga en cuenta, sin embargo, que ``Error`` es un tipo integrado y no se puede definir en código proporcionado por el usuario.

De manera similar, un ``assert`` o condiciones similares se revertirán con un error
del tipo integrado ``Panic(uint256)``

.. note::
    Los datos de error sólo se deben utilizar para indicar un fallo, pero 
    no como un medio para el control-flujo. El motivo es que los datos de reversión 
    de llamadas internas se propaga de vuelta a través de la cadena de llamadas externas 
    de forma predeterminada. Esto significa que una llamada interna 
    puede “forjar” datos de reversión que parecen haber venido del 
    contrato que lo llamó.

Miembros de Errores
=================

- ``error.selector``: Un valor de ``bytes4`` que contiene el selector de errores.
