.. index:: ! contract;abstract, ! abstract contract

.. _abstract-contract:

********************
Contratos Abstractos
********************

Los contratos deben marcarse como abstractos cuando al menos una de sus funciones no está implementada o cuando no proporcionan argumentos para todos los constructores en los contratos base.
Incluso si este no es el caso, un contrato aún puede marcarse como abstracto cuando no tiene la intención de que ser creado directamente.
Los contratos abstractos son similares a las :ref:`interfaces`, sin embargo, una interfaz está más limitada en lo que puede declarar.

Un contrato abstracto se declara utilizando la palabra clave ``abstract``, como se muestra en el siguiente ejemplo.
Se debe tener en cuenta que este contrato debe definirse como abstracto, porque se declara la función ``utterance()``,
pero no se proporcionó ninguna implementación (no se proporcionó ninguna implementación dentro del cuerpo de la función  ``{ }``).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public virtual returns (bytes32);
    }

Dichos contratos abstractos no pueden instanciarse directamente.
Esto también es cierto, si un contrato abstracto en sí mismo implementa todas las funciones definidas.
El uso de un contrato abstracto como clase base se muestra en el siguiente ejemplo:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public pure virtual returns (bytes32);
    }

    contract Cat is Feline {
        function utterance() public pure override returns (bytes32) { return "miaow"; }
    }

Si un contrato hereda partes de un contrato abstracto y no implementa todas las funciones que no fueron implementadas mediante anulación, debe marcarse como abstracto.

Se debe tener en cuenta que una función sin implementación es diferente de una :ref:`Función Type <function_types>`, aunque su sintaxis sea muy similar.

Ejemplo de función sin implementación (una declaración de función):

.. code-block:: solidity

    function foo(address) external returns (address);

Ejemplo de declaración de una variable cuyo tipo es un tipo función:

.. code-block:: solidity

    function(address) external returns (address) foo;

Los contratos abstractos desacoplan la definición de un contrato de su implementación, proporcionando una mejor extensibilidad y autodocumentación, facilitando patrones como el método de plantilla y eliminando la duplicación de código.
Los contratos abstractos son útiles de la misma manera que lo es definir métodos en una interfaz.
Es una forma de que el diseñador del contrato abstracto diga "cualquier hijo mío debe implementar este método".

.. note:: 

    Los contratos abstractos no pueden anular una función virtual implementada con una no implementada.
