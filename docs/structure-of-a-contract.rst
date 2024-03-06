.. index:: contract, state variable, function, event, struct, enum, function;modifier

.. _contract_structure:

***********************
Estructura de un Contrato
***********************

Los contratos en Solidity son similares a las clases en los lenguajes orientados a objetos.
Cada contrato puede contener declaraciones de :ref:`variables de estado`, :ref:`funciones`,
:ref:`modificadores de funciones`, :ref:`eventos`, :ref:`errores`, tipos :ref:`struct` y :ref:`enum`.
Además, los contratos pueden heredar de otros contratos.

También hay tipos de contratos especiales llamados :ref:`libraries<libraries>` e :ref:`interfaces<interfaces>`.

La sección sobre :ref:`contratos<contracts>` contiene más detalles que esta sección, 
el cual sirve para proveer un rápido resumen.

.. _structure-state-variables:

Variables de Estado
===============

Las variables de estado son variables cuyos valores se almacenan permanentemente en el almacenamiento del contrato.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract SimpleStorage {
        uint storedData; // Variable de estado
        // ...
    }

Véase la sección de :ref:`tipos` para tipos válidos de variables de estado y 
la sección :ref:`visibilidad-y-getters` para posibles opciones de visibilidad.
See the :ref:`types` section for valid state variable types and
:ref:`visibility-and-getters` for possible choices for
visibility.

.. _structure-functions:

Funciones
=========

Las funciones son las unidades de código ejecutables. Las funciones están definidas usualmente 
dentro de los contratos, pero tambíen pueden ser definidas fuera de los contratos.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract SimpleAuction {
        function bid() public payable { // Función
            // ...
        }
    }

    // Función auxiliar definida fuera de un contrato
    function helper(uint x) pure returns (uint) {
        return x * 2;
    }

:ref:`Las-llamadas-a-funciones` pueden suceder interna o externamente
y tienen diferentes niveles de :ref:`visibilidad<visibility-and-getters>`
hacia otros contratos. Las :ref:`funciones<functions>` aceptan :ref:`parámetros y retornan variables<function-parameters-return-variables>`
para pasar parámetros y valores entre ellos.

.. _structure-function-modifiers:

Modificadores de Funciones
==================

Los modificadores de funciones se pueden usar para modificar la semántica de las funciones de una forma declarativa
(véase :ref:`modificadores` en la sección de contratos).

La sobrecarga, es decir, tener el mismo nombre del modificador con diferentes parámetros,
no es posible.

Como las funciones, los modificadores se pueden :ref:`anular <modifier-overriding>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract Purchase {
        address public seller;

        modifier onlySeller() { // Modificador
            require(
                msg.sender == seller,
                "Only seller can call this."
            );
            _;
        }

        function abort() public view onlySeller { // Uso del modificador
            // ...
        }
    }

.. _structure-events:

Eventos
======

Los eventos son interfaces convenientes con las facilidades de registro de la EVM. 

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.22;

    event HighestBidIncreased(address bidder, uint amount); // Event

    contract SimpleAuction {
<<<<<<< HEAD
        event HighestBidIncreased(address bidder, uint amount); // Evento

=======
>>>>>>> english/develop
        function bid() public payable {
            // ...
            emit HighestBidIncreased(msg.sender, msg.value); // Desencadenando un evento
        }
    }

Véase :ref:`eventos` en la sección de contratos para información sobre cómo los eventos se declaran
y pueden ser usados desde dentro de una dapp.

.. _structure-errors:

Errores
======

Los errores le permiten definir nombres y datos descriptivos para situaciones de falla.
Los errores se pueden usar en :ref:`sentencias revert <revert-statement>`.
En comparaciñon a las descripciones de caradenas de caracteres, los errores son mucho más baratos y le permiten
codificar datos adicionales. Puede usar NatSpec para describir el error al usuario.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Sin suficientes fondos para transferir.  Solicitado `requested`,
    /// pero solo disponible `available`.
    error NotEnoughFunds(uint requested, uint available);

    contract Token {
        mapping(address => uint) balances;
        function transfer(address to, uint amount) public {
            uint balance = balances[msg.sender];
            if (balance < amount)
                revert NotEnoughFunds(amount, balance);
            balances[msg.sender] -= amount;
            balances[to] += amount;
            // ...
        }
    }

Véase :ref:`errores` en la sección de contratos para más información.

.. _structure-struct-types:

Tipos de Structs
=============

Los structs son tipos personalizados que pueden agrupar varias variables
(véase :ref:`structs` en la sección tipos).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Ballot {
        struct Voter { // Struct
            uint weight;
            bool voted;
            address delegate;
            uint vote;
        }
    }

.. _structure-enum-types:

Tipos Enum
==========

Los enums pueden ser usados para crear tipos personalizados con un conjunto finito de 'valores constantes'
(véase :ref:`enums` en la sección de tipos).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Purchase {
        enum State { Created, Locked, Inactive } // Enum
    }
