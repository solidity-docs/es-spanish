.. index:: ! contract;interface, ! interface contract

.. _interfaces:

**********
Interfaces
**********

Las interfaces son similares a los contratos abstractos, pero no pueden tener funciones implementadas.
Cuentan con más restricciones:

- No pueden heredar de otros contratos, pero pueden heredar de otras interfaces.
- Todas las funciones declaradas deben ser externas en la interfaz, incluso si son públicas en el contrato.
- No pueden declarar un constructor.
- No pueden declarar variables de estado.
- No pueden declarar modificadores.

Algunas de estas restricciones podrían dejar de aplicarse en un futuro.

Las interfaces se limitan básicamente a lo que puede representar el ABI del contrato.
La conversión entre el ABI y una interfaz debería ser posible sin ninguna pérdida de información.

Las interfaces se indican con su propia palabra clave:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface Token {
        enum TokenType { Fungible, NonFungible }
        struct Coin { string obverse; string reverse; }
        function transfer(address recipient, uint amount) external;
    }

Los contratos pueden heredar interfaces como heredarían otros contratos.

Todas las funciones declaradas en las interfaces son implícitamente ``virtual`` y cualquier función que las invalide no necesita la palabra clave ``override``.
Esto no significa automáticamente que una función de anulación se pueda anular de nuevo; esto solamente es posible si la función de anulación está marcada como ``virtual``.

Las interfaces pueden heredar de otras interfaces.
Aplican las mismas reglas de una herencia normal.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface ParentA {
        function test() external returns (uint256);
    }

    interface ParentB {
        function test() external returns (uint256);
    }

    interface SubInterface is ParentA, ParentB {
        // Must redefine test in order to assert that the parent
        // meanings are compatible.
        function test() external override(ParentA, ParentB) returns (uint256);
    }

Se puede acceder a los tipos definidos dentro de las interfaces y otras estructuras similares a contratos desde otros contratos: ``Token.TokenType`` o ``Token.Coin``.

.. warning::

    Las interfaces admiten tipos ``enum`` desde :doc:`Solidity versión 0.5.0 <050-breaking-changes>`, asegúrese de que la versión pragma especifique esta versión como mínimo.
