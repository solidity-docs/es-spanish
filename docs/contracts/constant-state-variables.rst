.. index:: ! constant

.. _constants:

*******************************************
Variables de estado constantes e inmutables
*******************************************

Las variables de estado pueden ser declaradas como ``constant`` o ``ìmmutable``.
En ambos casos, estas variables ya no podrán ser modificadas una vez se haya creado el contrato.

Las variables ``constant`` fijarán su valor ya directamente en el propio proceso de compilación,
mientras que las variables ``immutable``, podrán hacerlo cuando el contrato sea construido.

También se pueden definir variables ``constant`` a nivel de archivo.

El compilador no reservará un espacio de almacenamiento (storage slot) para estas variables.
En su lugar, cada una de estas variables será reemplazada por su respectivo valor.

En comparación con las variables de estado convencionales, el coste de gas de las variables 
constantes e inmutables es mucho más bajo. Una variable declarada como constante tiene un valor 
fijo, el cual es copiado directamente en todos los lugares que aparece o es accedido. Y gracias 
a esto, se obtiene una mayor optimización de los recursos computacionales a nivel local. En el
caso de las variables declaradas como inmutables, dichas variables se evaluarán tan solo una 
única vez, justo cuando se realice la construcción del contrato. Será en ese momento, cuando 
se copiarán todos los respectivos valores, en todos aquellos lugares del código que existan 
referencias a estas variables. Para estos valores inmutables, se reservan siempre 32 bytes,
incluso cuando no sea necesaria toda esta capacidad. Por este motivo, a veces, las variables
constantes resultan más económicas que las variables inmutables.

Por ahora, no se soportan todos los tipos de datos para estas variables constantes e 
inmutables. Únicamente se soportan los tipos :ref:`strings <strings>` (solo para constantes)
y :ref:`value types <value-types>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.21;

    uint constant X = 32**22 + 8;

    contract C {
        string constant TEXT = "abc";
        bytes32 constant MY_HASH = keccak256("abc");
        uint immutable decimals = 18;
        uint immutable maxBalance;
        address immutable owner = msg.sender;

        constructor(uint decimals_, address ref) {
<<<<<<< HEAD
            decimals = decimals_;
            // Las asignaciones a variables inmutables también pueden tener acceso a datos de su entorno.
=======
            if (decimals_ != 0)
                // Immutables are only immutable when deployed.
                // At construction time they can be assigned to any number of times.
                decimals = decimals_;

            // Assignments to immutables can even access the environment.
>>>>>>> english/develop
            maxBalance = ref.balance;
        }

        function isBalanceTooHigh(address other) public view returns (bool) {
            return other.balance > maxBalance;
        }
    }


Constantes
==========

En el caso de las variables ``constant``, el valor tiene que ser una constante en tiempo 
de compilación, y tiene que ser asignado en cada lugar donde las variables sean 
declaradas. Cualquier expresión que acceda al almacenamiento, información de la 
blockchain (por ejemplo, ``block.timestamp``, ``address(this).balance`` o 
``block.number``) o datos de ejecución (``msg.value`` o ``gasleft()``) o llamadas 
hechas a contratos externos, son expresiones no permitidas. Las expresiones con 
efectos secundarios en las asignaciones de memoria están permitidas, pero las que 
tengan efectos secundarios sobre los objetos de la memoria no. Las funciones 
integradas (built-in functions) ``keccak256``, ``sha256``, ``ripemd160``, 
``ecrecover``, ``addmod`` y ``mulmod`` están permitidas (e incluso, a excepción de 
``keccak256``, aunque hagan llamadas a contratos externos).

El motivo por el cual se permiten efectos secundarios sobre las asignaciones de memoria,
es que sea posible construir objetos complejos como, por ejemplo, lookup-tables.
Aunque esta característica todavía no está totalmente disponible para ser usada.

Inmutables
==========

<<<<<<< HEAD
Las variables declaradas como ``immutable`` son un poco menos restrictivas que las
declaradas como ``constant``: Las variables inmutables pueden tener un valor
arbitrario en el constructor del contracto o en el lugar de su declaración.
Eso sí, su valor solo puede ser asignado una vez. Pero a partir de ahí, ese valor 
puede leerse incluso durante el proceso de construcción.

El código de creación del contrato el cual es generado por el compilador, será modificado 
en tiempo de ejecución, y reemplazará todas las referencias a variables inmutables por 
sus correspondientes valores asignados en cada caso. Esto es importante a la hora de 
comparar el código que se usa en tiempo de ejecución, y el cual está generado por el 
compilador, respecto del código que finalmente permanece alojado en la blockchain.

.. note::
  Las variables inmutables que sean asignadas al ser declaradas solo se 
  considerarán inicializadas una vez sea ejecutado el constructor del contrato.
  Esto implica que no puedes inicializar inmutables en línea con un valor 
  el cual dependa de otra variable inmutable. Sin embargo, sí que puedes hacerlo
  dentro del constructor del contrato.
  
  Esto evita que existan diferentes interpretaciones del código, en relación al 
  orden de inicialización de las variables de estado y la ejecución del constructor,
  especialmente cuando hay casos de herencia de valores.
=======
Variables declared as ``immutable`` are a bit less restricted than those
declared as ``constant``: Immutable variables can be assigned a
value at construction time.
The value can be changed at any time before deployment and then it becomes permanent.

One additional restriction is that immutables can only be assigned to inside expressions for which
there is no possibility of being executed after creation.
This excludes all modifier definitions and functions other than constructors.

There are no restrictions on reading immutable variables.
The read is even allowed to happen before the variable is written to for the first time because variables in
Solidity always have a well-defined initial value.
For this reason it is also allowed to never explicitly assign a value to an immutable.

.. warning::
    When accessing immutables at construction time, please keep the :ref:`initialization order
    <state-variable-initialization-order>` in mind.
    Even if you provide an explicit initializer, some expressions may end up being evaluated before
    that initializer, especially when they are at a different level in inheritance hierarchy.

.. note::
    Before Solidity 0.8.21 initialization of immutable variables was more restrictive.
    Such variables had to be initialized exactly once at construction time and could not be read
    before then.

The contract creation code generated by the compiler will modify the
contract's runtime code before it is returned by replacing all references
to immutables with the values assigned to them. This is important if
you are comparing the
runtime code generated by the compiler with the one actually stored in the
blockchain. The compiler outputs where these immutables are located in the deployed bytecode
in the ``immutableReferences`` field of the :ref:`compiler JSON standard output <compiler-api>`.
>>>>>>> english/develop
