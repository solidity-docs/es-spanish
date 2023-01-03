.. _inline-assembly:

###############
Ensamblado en línea
###############

.. index:: ! assembly, ! asm, ! evmasm

Puedes intercalar declaraciones de Solidity con ensamblado en línea en un lenguaje cercano al de la Máquina Virtual de EThereum. Esto te brinda un control más preciso, especialmente útil cuando estás mejorando el lenguaje escribiendo librerías.

El lenguaje utilizado para el ensamblado en línea en Solidity se llama :ref:`Yul <yul>` y está documentado en su propia sección. Esta sección solo cubre cómo el código de ensamblado en línea puede interactuar con el código en Solidity que lo rodea.


.. warning::
    El ensamblado en línea es una forma de acceder a la Máquina Virtual de Ethereum aun nivel bajo. Esto evita varias características y comprobacionoes de seguridad importantes de Solidity. Solo debes usarlo para tareas que lo necesiten y solo si tienes confianza en su uso.


Un bloque de ensamblado en línea está marcado con ``assembly { ... }``, donde el código dentro de las llaves es código en el lenguaje :ref:`Yul <yul>`.

El código de ensablado en línea puede acceder variables locales de solidity como se explica a continuación.

Los diferentes bloques de ensamblado en línea no comparten ningún espacio de nombres, por ejemplo, no es posible llamar a una función Yul o acceder a una variable Yul definida en un bloque de ensamblado en línea diferente.

Ejemplo
-------

El siguiente ejemplo proporciona código de la librería para acceder al código de otro contrato y cargarlo en una variable ``bytes``. Esto también es posible con "Solidity plano" usando ``<dirección>.code``. Pero el punto aquí es que las librerías de ensablado reutilizables pueden mejorar Solidity sin un cambio en el compilador.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library GetCode {
        function at(address addr) public view returns (bytes memory code) {
            assembly {
                // retrieve the size of the code, this needs assembly
                let size := extcodesize(addr)
                // allocate output byte array - this could also be done without assembly
                // by using code = new bytes(size)
                code := mload(0x40)
                // new "memory end" including padding
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // store length in memory
                mstore(code, size)
                // actually retrieve the code, this needs assembly
                extcodecopy(addr, add(code, 0x20), 0, size)
            }
        }
    }

El ensamblado en línea también es beneficioso en casos en los que el optimizador no logra producir código eficiente, por ejemplo:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;


    library VectorSum {
        // This function is less efficient because the optimizer currently fails to
        // remove the bounds checks in array access.
        function sumSolidity(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i)
                sum += data[i];
        }

        // We know that we only access the array in bounds, so we can avoid the check.
        // 0x20 needs to be added to an array because the first slot contains the
        // array length.
        function sumAsm(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(data, 0x20), mul(i, 0x20))))
                }
            }
        }

        // Same as above, but accomplish the entire code within inline assembly.
        function sumPureAsm(uint[] memory data) public pure returns (uint sum) {
            assembly {
                // Load the length (first 32 bytes)
                let len := mload(data)

                // Skip over the length field.
                //
                // Keep temporary variable so it can be incremented in place.
                //
                // NOTE: incrementing data would result in an unusable
                //       data variable after this assembly block
                let dataElementLocation := add(data, 0x20)

                // Iterate until the bound is not met.
                for
                    { let end := add(dataElementLocation, mul(len, 0x20)) }
                    lt(dataElementLocation, end)
                    { dataElementLocation := add(dataElementLocation, 0x20) }
                {
                    sum := add(sum, mload(dataElementLocation))
                }
            }
        }
    }

.. index:: selector; of a function

Acceso a variables, funciones y librerías externas
-----------------------------------------------------

Puedes acceder a las variables y otros identificadores de Solidity utilizando su nombre.

Las variables locales de tipo valor son directamente utilizables en el ensamblado en línea.
Ambas se pueden leer y asignar.

Las variables locales que hacen referencia a memoria evalúan la dirección de la variable en memoria, no el valor en sí.
Tales variables también se peuden asignar, pero ten en cuenta que una asignación solo cambiará hacia donde apunta y no los datos, también que es tu responsabilidad respetar la gestión de memoria de Solidity. Ver :ref:`Conventions in Solidity <conventions-in-solidity>`.

Del mismo modo, las variables locales que hacen referencia a arreglos de calldata de tamaño estático o estructuras calldata evalúan la dirección de la variable en calldata, no el valor en sí. También se le puede asignar un nuevo offset a la variable, pero ten en cuenta que no se realiza ninguna validacióno para asegurar que la variable no apunte más allá de ``calldatasize()``.

Para los punteros de función externos, la dirección y el selector de función pueden accederse usando ``x.address`` y ``x.selector``. El selector consiste de cuatro bytes alineados a la derecha. Ambos valores se peuden asignar. Por ejemplo:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.10 <0.9.0;

    contract C {
        // Assigns a new selector and address to the return variable @fun
        function combineToFunctionPointer(address newAddress, uint newSelector) public pure returns (function() external fun) {
            assembly {
                fun.selector := newSelector
                fun.address  := newAddress
            }
        }
    }

Para los arreglos dinámicos de calldata, puedes acceder a su offset de calldata (en bytes) y longitud (número de elementos) utilizando ``x.offset`` y ``x.length``. Ambas expresiones también pueden ser asignadas, pero como en el caso estático, no se realizará ninguna validación para asegurarse que el área de datos resultante esté dentro de los límites de ``calldatasize()``.

Para las variables de almacenamiento local, o variables de estado, un identificador único Yul no es suficiente ya que no necesariamente ocupan un solo espacio de almacenamiento completo. Por lo tanto, su "dirección" está compuesta por un espacio y un offset de bytes dentro del espacio. Para recuperar el espacio apuntado por la variable `x`, utiliza `x.slot` y para recuperar el offset de bytes utiliza `x.offset`. El uso de `x` en sí mismo resultará en un error.

También puedes asignar a la parte ``.slot`` de un puntero de variable de almacenamiento local. Para estos (estructuras, arreglos o mapeos), la parte ``.offset`` siempre es cero. Sin embargo, no es posible asignar a la parte ``.slot`` o ``.offset`` de una variable de estado.

Las variables locales en Solidity están disponibles para asignaciones, por ejemplo:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract C {
        uint b;
        function f(uint x) public view returns (uint r) {
            assembly {
                // We ignore the storage slot offset, we know it is zero
                // in this special case.
                r := mul(x, sload(b.slot))
            }
        }
    }

.. warning::
    If you access variables of a type that spans less than 256 bits
    (for example ``uint64``, ``address``, or ``bytes16``),
    you cannot make any assumptions about bits not part of the
    encoding of the type. Especially, do not assume them to be zero.
    To be safe, always clear the data properly before you use it
    in a context where this is important:
    ``uint32 x = f(); assembly { x := and(x, 0xffffffff) /* now use x */ }``
    To clean signed types, you can use the ``signextend`` opcode:
    ``assembly { signextend(<num_bytes_of_x_minus_one>, x) }``


Since Solidity 0.6.0, the name of a inline assembly variable may not
shadow any declaration visible in the scope of the inline assembly block
(including variable, contract and function declarations).

Since Solidity 0.7.0, variables and functions declared inside the
inline assembly block may not contain ``.``, but using ``.`` is
valid to access Solidity variables from outside the inline assembly block.

Things to Avoid
---------------

Inline assembly might have a quite high-level look, but it actually is extremely
low-level. Function calls, loops, ifs and switches are converted by simple
rewriting rules and after that, the only thing the assembler does for you is re-arranging
functional-style opcodes, counting stack height for
variable access and removing stack slots for assembly-local variables when the end
of their block is reached.

.. _conventions-in-solidity:

Conventions in Solidity
-----------------------

.. _assembly-typed-variables:

Values of Typed Variables
=========================

In contrast to EVM assembly, Solidity has types which are narrower than 256 bits,
e.g. ``uint24``. For efficiency, most arithmetic operations ignore the fact that
types can be shorter than 256
bits, and the higher-order bits are cleaned when necessary,
i.e., shortly before they are written to memory or before comparisons are performed.
This means that if you access such a variable
from within inline assembly, you might have to manually clean the higher-order bits
first.

.. _assembly-memory-management:

Memory Management
=================

Solidity manages memory in the following way. There is a "free memory pointer"
at position ``0x40`` in memory. If you want to allocate memory, use the memory
starting from where this pointer points at and update it.
There is no guarantee that the memory has not been used before and thus
you cannot assume that its contents are zero bytes.
There is no built-in mechanism to release or free allocated memory.
Here is an assembly snippet you can use for allocating memory that follows the process outlined above:

.. code-block:: yul

    function allocate(length) -> pos {
      pos := mload(0x40)
      mstore(0x40, add(pos, length))
    }

The first 64 bytes of memory can be used as "scratch space" for short-term
allocation. The 32 bytes after the free memory pointer (i.e., starting at ``0x60``)
are meant to be zero permanently and is used as the initial value for
empty dynamic memory arrays.
This means that the allocatable memory starts at ``0x80``, which is the initial value
of the free memory pointer.

Elements in memory arrays in Solidity always occupy multiples of 32 bytes (this is
even true for ``bytes1[]``, but not for ``bytes`` and ``string``). Multi-dimensional memory
arrays are pointers to memory arrays. The length of a dynamic array is stored at the
first slot of the array and followed by the array elements.

.. warning::
    Statically-sized memory arrays do not have a length field, but it might be added later
    to allow better convertibility between statically and dynamically-sized arrays; so,
    do not rely on this.

Memory Safety
=============

Without the use of inline assembly, the compiler can rely on memory to remain in a well-defined
state at all times. This is especially relevant for :ref:`the new code generation pipeline via Yul IR <ir-breaking-changes>`:
this code generation path can move local variables from stack to memory to avoid stack-too-deep errors and
perform additional memory optimizations, if it can rely on certain assumptions about memory use.

While we recommend to always respect Solidity's memory model, inline assembly allows you to use memory
in an incompatible way. Therefore, moving stack variables to memory and additional memory optimizations are,
by default, globally disabled in the presence of any inline assembly block that contains a memory operation
or assigns to Solidity variables in memory.

However, you can specifically annotate an assembly block to indicate that it in fact respects Solidity's memory
model as follows:

.. code-block:: solidity

    assembly ("memory-safe") {
        ...
    }

In particular, a memory-safe assembly block may only access the following memory ranges:

- Memory allocated by yourself using a mechanism like the ``allocate`` function described above.
- Memory allocated by Solidity, e.g. memory within the bounds of a memory array you reference.
- The scratch space between memory offset 0 and 64 mentioned above.
- Temporary memory that is located *after* the value of the free memory pointer at the beginning of the assembly block,
  i.e. memory that is "allocated" at the free memory pointer without updating the free memory pointer.

Furthermore, if the assembly block assigns to Solidity variables in memory, you need to assure that accesses to
the Solidity variables only access these memory ranges.

Since this is mainly about the optimizer, these restrictions still need to be followed, even if the assembly block
reverts or terminates. As an example, the following assembly snippet is not memory safe, because the value of
``returndatasize()`` may exceed the 64 byte scratch space:

.. code-block:: solidity

    assembly {
      returndatacopy(0, 0, returndatasize())
      revert(0, returndatasize())
    }

On the other hand, the following code *is* memory safe, because memory beyond the location pointed to by the
free memory pointer can safely be used as temporary scratch space:

.. code-block:: solidity

    assembly ("memory-safe") {
      let p := mload(0x40)
      returndatacopy(p, 0, returndatasize())
      revert(p, returndatasize())
    }

Note that you do not need to update the free memory pointer if there is no following allocation,
but you can only use memory starting from the current offset given by the free memory pointer.

If the memory operations use a length of zero, it is also fine to just use any offset (not only if it falls into the scratch space):

.. code-block:: solidity

    assembly ("memory-safe") {
      revert(0, 0)
    }

Note that not only memory operations in inline assembly itself can be memory-unsafe, but also assignments to
Solidity variables of reference type in memory. For example the following is not memory-safe:

.. code-block:: solidity

    bytes memory x;
    assembly {
      x := 0x40
    }
    x[0x20] = 0x42;

Inline assembly that neither involves any operations that access memory nor assigns to any Solidity variables
in memory is automatically considered memory-safe and does not need to be annotated.

.. warning::
    It is your responsibility to make sure that the assembly actually satisfies the memory model. If you annotate
    an assembly block as memory-safe, but violate one of the memory assumptions, this **will** lead to incorrect and
    undefined behaviour that cannot easily be discovered by testing.

In case you are developing a library that is meant to be compatible across multiple versions
of Solidity, you can use a special comment to annotate an assembly block as memory-safe:

.. code-block:: solidity

    /// @solidity memory-safe-assembly
    assembly {
        ...
    }

Note that we will disallow the annotation via comment in a future breaking release; so, if you are not concerned with
backwards-compatibility with older compiler versions, prefer using the dialect string.
