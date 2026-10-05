.. _security_considerations:

#######################
Consideraciones de Seguridad
#######################

Aunque normalmente es bastante fácil construir software que funcione como se espera,
es mucho más difícil controlar que nadie pueda usarlo de un manera **no** anticipada.

In Solidity, this is even more important because you can use smart contracts to handle tokens or,
possibly, even more valuable things.
Furthermore, every execution of a smart contract happens in public and,
in addition to that, the source code is often available.

Of course, you always have to consider how much is at stake:
You can compare a smart contract with a web service that is open to the public
(and thus, also to malicious actors) and perhaps even open-source.
If you only store your grocery list on that web service, you might not have to take too much care,
but if you manage your bank account using that web service, you should be more careful.

This section will list some pitfalls and general security recommendations
but can, of course, never be complete.
Also, keep in mind that even if your smart contract code is bug-free,
the compiler or the platform itself might have a bug.
A list of some publicly known security-relevant bugs of the compiler can be found
in the :ref:`list of known bugs<known_bugs>`, which is also machine-readable.
Note that there is a `Bug Bounty Program <https://ethereum.org/en/bug-bounty/>`_
that covers the code generator of the Solidity compiler.

As always, with open-source documentation,
please help us extend this section (especially, some examples would not hurt)!

NOTA: Además de la lista de abajo, puede encontrar más recomendaciones de seguridad y buenas prácticas `en la lista de Guy Lando <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_ y `the Consensys GitHub repo <https://consensys.github.io/smart-contract-best-practices/>`_.

********
Peligros
********

Información privada y Aleatoriedad
==================================

Everything you use in a smart contract is publicly visible,
even local variables and state variables marked ``private``.

Using random numbers in smart contracts is quite tricky if you do not want block builders to be able to cheat.

Reentrancy
==========

Any interaction from a contract (A) with another contract (B)
and any transfer of Ether hands over control to that contract (B).
This makes it possible for B to call back into A before this interaction is completed.
To give an example, the following code contains a bug (it is just a snippet and not a complete contract):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // ESTE CONTRATO CONTIENE UN BUG - NO USAR
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
        // This will report a warning (deprecation)
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

The problem is not too serious here because of the limited gas as part of ``send``,
but it still exposes a weakness:
Ether transfer can always include code execution,
so the recipient could be a contract that calls back into ``withdraw``.
This would let it get multiple refunds and, basically, retrieve all the Ether in the contract.
In particular, the following contract will allow an attacker to refund multiple times
as it uses ``call`` which does not limit the amount of gas that is forwarded by default:

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

To avoid reentrancy, you can use the Checks-Effects-Interactions pattern as demonstrated below:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            (bool success, ) = payable(msg.sender).call{value: share}("");
            require(success);
        }
    }

The Checks-Effects-Interactions pattern ensures that all code paths through a contract
complete all required checks of the supplied parameters before modifying the contract's state (Checks);
only then it makes any changes to the state (Effects);
it may make calls to functions in other contracts
*after* all planned state changes have been written to storage (Interactions).
This is a common foolproof way to prevent *reentrancy attacks*,
where an externally called malicious contract can double-spend an allowance,
double-withdraw a balance, among other things,
by using logic that calls back into the original contract before it has finalized its transaction.

Note that reentrancy is not only an effect of Ether transfer
but of any function call on another contract.
Furthermore, you also have to take multi-contract situations into account.
A called contract could modify the state of another contract you depend on.

Límite de Gas y Bucles
===================

Loops that do not have a fixed number of iterations, for example,
loops that depend on storage values, have to be used carefully:
Due to the block gas limit, transactions can only consume a certain amount of gas.
Either explicitly or just due to normal operation,
the number of iterations in a loop can grow beyond the block gas limit
which can cause the complete contract to be stalled at a certain point.
This may not apply to ``view`` functions that are only executed to read data from the blockchain.
Still, such functions may be called by other contracts as part of on-chain operations and stall those.
Please be explicit about such cases in the documentation of your contracts.

Envío y Recepción de Ether
===========================

- Neither contracts nor "externally-owned accounts" are currently able to prevent someone from sending them Ether.
  Contracts can react on and reject a regular transfer, but there are ways to move Ether without creating a message call.
  One way is to simply "mine to" the contract address and the second way is using ``selfdestruct(x)``.

- If a contract receives Ether (without a function being called), either the :ref:`receive Ether <receive-ether-function>`
  or the :ref:`fallback <fallback-function>` function is executed.
  If it does not have a ``receive`` nor a ``fallback`` function, the Ether will be rejected (by throwing an exception).
  During the execution of one of these functions, the contract can only rely on the "gas stipend" it is passed (2300 gas)
  being available to it at that time.
  This stipend is not enough to modify storage (do not take this for granted though, the stipend might change with future hard forks).
  To be sure that your contract can receive Ether in that way, check the gas requirements of the receive and fallback functions
  (for example in the "details" section in Remix).

- There is a way to forward more gas to the receiving contract using ``addr.call{value: x}("")``.
  This is essentially the same as ``addr.transfer(x)``, only that it forwards all remaining gas,
  subject to additional limits imposed by some EVM versions (such as the `63/64th rule <https://eips.ethereum.org/EIPS/eip-150>`_
  introduced by ``tangerineWhistle``), and opens up the ability for the recipient to perform more expensive actions
  (and it returns a failure code instead of automatically propagating the error).
  This might include calling back into the sending contract or other state changes you might not have thought of.
  So it allows for great flexibility for honest users but also for malicious actors.

- Use the most precise units to represent the Wei amount as possible, as you lose any that is rounded due to a lack of precision.

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

External function calls can fail at any time
because they exceed the maximum call stack size limit of 1024.
In such situations, Solidity throws an exception.
Malicious actors might be able to force the call stack to a high value
before they interact with your contract.
Note that, since `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork,
the `63/64 rule <https://eips.ethereum.org/EIPS/eip-150>`_ makes call stack depth attack impractical.
Also note that the call stack and the expression stack are unrelated,
even though both have a size limit of 1024 stack slots.

Note that ``.send()`` does **not** throw an exception if the call stack is depleted
but rather returns ``false`` in that case.
The low-level functions ``.call()``, ``.delegatecall()`` and ``.staticcall()`` behave in the same way.

Proxies Autorizados
==================

If your contract can act as a proxy, i.e. if it can call arbitrary contracts with user-supplied data,
then the user can essentially assume the identity of the proxy contract.
Even if you have other protective measures in place, it is best to build your contract system such
that the proxy does not have any permissions (not even for itself).
If needed, you can accomplish that using a second proxy:

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

Never use ``tx.origin`` for authorization.
Let's say you have a wallet contract like this:

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
            // This will report a warning (deprecation)
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

If your wallet had checked ``msg.sender`` for authorization, it would get the address of the attack wallet,
instead of the owner's address.
But by checking ``tx.origin``, it gets the original address that kicked off the transaction,
which is still the owner's address.
The attack wallet instantly drains all your funds.

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

The Solidity type ``mapping`` (see :ref:`mapping-types`) is a storage-only key-value data structure
that does not keep track of the keys that were assigned a non-zero value.
Because of that, cleaning a mapping without extra information about the written keys is not possible.
If a ``mapping`` is used as the base type of a dynamic storage array,
deleting or popping the array will have no effect over the ``mapping`` elements.
The same happens, for example, if a ``mapping`` is used as the type of a member field of a ``struct``
that is the base type of a dynamic storage array.
The ``mapping`` is also ignored in assignments of structs or arrays containing a ``mapping``.

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

Consider the example above and the following sequence of calls: ``allocate(10)``, ``writeMap(4, 128, 256)``.
At this point, calling ``readMap(4, 128)`` returns 256.
If we call ``eraseMaps``, the length of the state variable ``array`` is zeroed,
but since its ``mapping`` elements cannot be zeroed, their information stays alive in the contract's storage.
After deleting ``array``, calling ``allocate(5)`` allows us to access ``array[4]`` again,
and calling ``readMap(4, 128)`` returns 256 even without another call to ``writeMap``.

SI su información de ``mapping`` debe ser eliminada, considere usar una biblioteca similar a `iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_, que le permite atravesar las claves y eliminar sus valores en el ``mapping`` apropiado.

<<<<<<< HEAD
Detalles Menores
=======
Internal Function Pointers in Upgradeable Contracts
===================================================

Updating the code of your contract may :ref:`invalidate the values of variables of internal function
types<function-type-value-stability-across-contract-updates>`.
Consider such values ephemeral and avoid storing them in state variables.
If you do, you must ensure that they never persist across code updates and are never used by
other contracts having access to the same storage space as a result of a delegatecall or account
abstraction.

Minor Details
>>>>>>> english/develop
=============

- Types that do not occupy the full 32 bytes might contain "dirty higher order bits".
  This is especially important if you access ``msg.data`` - it poses a malleability risk:
  You can craft transactions that call a function ``f(uint8 x)``
  with a raw byte argument of ``0xff000001`` and with ``0x00000001``.
  Both are fed to the contract and both will look like the number ``1`` as far as ``x`` is concerned,
  but ``msg.data`` will be different, so if you use ``keccak256(msg.data)`` for anything,
  you will get different results.

***************
Recomendaciones
***************

Tome las advertencias seriamente
=======================

If the compiler warns you about something, you should change it.
Even if you do not think that this particular warning has security implications,
there might be another issue buried beneath it.
Any compiler warning we issue can be silenced by slight changes to the code.

Always use the latest version of the compiler to be notified about all recently introduced warnings.

Messages of type ``info``, issued by the compiler, are not dangerous
and simply represent extra suggestions and optional information
that the compiler thinks might be useful to the user.

Limite la cantidad de Ether 
============================

Restrict the amount of Ether (or other tokens) that can be stored in a smart contract.
If your source code, the compiler or the platform has a bug, these funds may be lost.
If you want to limit your loss, limit the amount of Ether.

Manténgalo modular y pequeño
=========================

Keep your contracts small and easily understandable.
Single out unrelated functionality in other contracts or into libraries.
General recommendations about the source code quality of course apply:
Limit the amount of local variables, the length of functions and so on.
Document your functions so that others can see what your intention was
and whether it is different than what the code does.

Use el patrón Checks-Effects-Interactions
===========================================

Most functions will first perform some checks and they should be done first
(who called the function, are the arguments in range, did they send enough Ether,
does the person have tokens, etc.).

As the second step, if all checks passed, effects to the state variables of the current contract should be made.
Interaction with other contracts should be the very last step in any function.

Early contracts delayed some effects and waited for external function calls to return in a non-error state.
This is often a serious mistake because of the reentrancy problem explained above.

Note que, también, llamadas a contratos conocidos podrían, después, causar llamadas a contratos desconocidos, así que es probablemente mejor aplicar siempre este patrón. 

Incluye un modo de fallo seguro
========================

While making your system fully decentralized will remove any intermediary,
it might be a good idea, especially for new code, to include some kind of fail-safe mechanism:

You can add a function in your smart contract that performs some self-checks like "Has any Ether leaked?",
"Is the sum of the tokens equal to the balance of the contract?" or similar things.
Keep in mind that you cannot use too much gas for that,
so help through off-chain computations might be needed there.

If the self-check fails, the contract automatically switches into some kind of "failsafe" mode,
which, for example, disables most of the features,
hands over control to a fixed and trusted third party
or just converts the contract into a simple "give me back my Ether" contract.

Solicite revisión por pares
===================

The more people examine a piece of code, the more issues are found.
Asking people to review your code also helps as a cross-check to find out
whether your code is easy to understand -
a very important criterion for good smart contracts.
