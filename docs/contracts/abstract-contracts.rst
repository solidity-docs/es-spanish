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

If a contract inherits from an abstract contract and does not implement all non-implemented
functions by overriding, it needs to be marked as abstract as well.

Note that a function without implementation is different from
a :ref:`Function Type <function_types>` even though their syntax looks very similar.

Example of function without implementation (a function declaration):

.. code-block:: solidity

    function foo(address) external returns (address);

Example of a declaration of a variable whose type is a function type:

.. code-block:: solidity

    function(address) external returns (address) foo;

Abstract contracts decouple the definition of a contract from its
implementation providing better extensibility and self-documentation and
facilitating patterns like the `Template method <https://en.wikipedia.org/wiki/Template_method_pattern>`_ and removing code duplication.
Abstract contracts are useful in the same way that defining methods
in an interface is useful. It is a way for the designer of the
abstract contract to say "any child of mine must implement this method".

.. note::

  Abstract contracts cannot override an implemented virtual function with an
  unimplemented one.
