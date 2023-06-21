.. index:: ! using for, library, ! operator;user-defined, function;free

.. _using-for:

*********
Using For
*********

La directiva ``using A for B`` se puede utilizar para adjuntar
funciones (``A``) como operadores a tipos de valor definidos por el usuario
o como funciones miembro de cualquier tipo (``B``).
Las funciones miembro reciben como primer parámetro el objeto al que se llama
como primer parámetro (como la variable ``self`` en Python).
Las funciones operador reciben operandos como parámetros.

Es válido tanto a nivel de fichero como dentro de un contrato,
a nivel de contrato.

The first part, ``A``, can be one of:

- Una lista de funciones, opcionalmente con un nombre de operador asignado (p. ej.
  ``usando {f, g como +, h, L.t} para uint``).
  Si no se especifica ningún operador, la función puede ser una función de biblioteca o una función libre y
  se adjunta al tipo como función miembro.
  En caso contrario, debe ser una función libre y se convierte en la definición de ese operador en el tipo.
- El nombre de una biblioteca (por ejemplo, ``usando L para uint``) -
  todas las funciones no privadas de la biblioteca se adjuntan al tipo
  como funciones miembro

A nivel de fichero, la segunda parte, ``B``, tiene que ser un tipo explícito (sin especificador de ubicación de datos).
Dentro de los contratos, también se puede utilizar ``*`` en lugar del tipo (por ejemplo, ``usando L para *;``),
que tiene el efecto de que todas las funciones de la biblioteca ``L``
se adjuntan a *todos* los tipos.

Si especifica una biblioteca, se adjuntan *todas* las funciones no privadas de la biblioteca,
incluso aquellas en las que el tipo del primer parámetro no
no coincide con el tipo del objeto. El tipo se comprueba en el
en el momento en que se llama a la función y se
de la función.

Si usas una lista de funciones (por ejemplo ``usando {f, g, h, L.t} para uint``),
entonces el tipo (``uint``) tiene que ser implícitamente convertible al
primer parámetro de cada una de estas funciones. Esta comprobación se realiza
realiza incluso si no se llama a ninguna de estas funciones.
Tenga en cuenta que las funciones privadas de biblioteca sólo pueden especificarse cuando ``using for`` está dentro de una biblioteca

 Si defines un operador (por ejemplo ``usando {f como +} para T``), entonces el tipo (``T``) debe ser un
:ref:`user-defined value type <user-defined-value-types>` y la definición debe ser una función ``pure``.
Las definiciones de operadores deben ser globales.
Los siguientes operadores pueden definirse de esta forma:

+------------+----------+---------------------------------------------+
| Category   | Operator | Possible signatures                         |
+============+==========+=============================================+
| Bitwise    | ``&``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``|``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``^``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``~``    | ``function (T) pure returns (T)``           |
+------------+----------+---------------------------------------------+
| Aritmética | ``+``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``-``    | ``function (T, T) pure returns (T)``        |
|            +          +---------------------------------------------+
|            |          | ``function (T) pure returns (T)``           |
|            +----------+---------------------------------------------+
|            | ``*``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``/``    | ``function (T, T) pure returns (T)``        |
|            +----------+---------------------------------------------+
|            | ``%``    | ``function (T, T) pure returns (T)``        |
+------------+----------+---------------------------------------------+
| Comparación| ``==``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``!=``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``<``    | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``<=``   | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``>``    | ``function (T, T) pure returns (bool)``     |
|            +----------+---------------------------------------------+
|            | ``>=``   | ``function (T, T) pure returns (bool)``     |
+------------+----------+---------------------------------------------+

Tenga en cuenta que unario y binario ``-`` necesitan definiciones separadas.
El compilador elegirá la definición correcta en función de cómo se invoque el operador.

La directiva ``usar A para B;`` sólo está activa dentro del ámbito actual
actual (ya sea el contrato o el módulo/unidad fuente actual),
incluyendo dentro de todas sus funciones, y no tiene efecto
fuera del contrato o módulo en el que se utiliza.

Cuando la directiva se utiliza a nivel de fichero y se aplica a un
tipo definido por el usuario que se definió a nivel de archivo en el mismo archivo,
puede añadirse al final la palabra ``global``. Esto tendrá el efecto
efecto que las funciones y operadores se adjuntan al tipo en todas partes
el tipo esté disponible (incluyendo otros ficheros), no sólo en el
ámbito de la sentencia "using".

Reescribamos el ejemplo de conjunto de la sección
ref:`libraries` de esta manera, usando funciones a nivel de fichero
en lugar de funciones de biblioteca.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    struct Data { mapping(uint => bool) flags; }
    // Ahora adjuntamos funciones al tipo.
    // Las funciones adjuntas pueden utilizarse en el resto del módulo.
    // Si importa el módulo, tiene que
    // repita allí la directiva using, por ejemplo como
    //   import "flags.sol" as Flags;
    //   using {Flags.insert, Flags.remove, Flags.contains}
    //     for Flags.Data;
    using {insert, remove, contains} for Data;

    function insert(Data storage self, uint value)
        returns (bool)
    {
        if (self.flags[value])
            return false; // ahí ya
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint value)
        returns (bool)
    {
        if (!self.flags[value])
            return false; // ahí no
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint value)
        view
        returns (bool)
    {
        return self.flags[value];
    }


    contract C {
        Data knownValues;

        function register(uint value) public {
            // Aquí, todas las variables de tipo Datos tienen
            // funciones miembro correspondientes.
            // La siguiente llamada de función es idéntica a
            // `Set.insert(knownValues, value)`
            require(knownValues.insert(value));
        }
    }

También es posible extender tipos incorporados de esa manera.
En este ejemplo, utilizaremos una biblioteca.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    library Search {
        function indexOf(uint[] storage self, uint value)
            public
            view
            returns (uint)
        {
            for (uint i = 0; i < self.length; i++)
                if (self[i] == value) return i;
            return type(uint).max;
        }
    }
    using Search for uint[];

    contract C {
        uint[] data;

        function append(uint value) public {
            data.push(value);
        }

        function replace(uint from, uint to) public {
            // Esto realiza la llamada a la función de biblioteca
            uint index = data.indexOf(from);
            if (index == type(uint).max)
                data.push(to);
            else
                data[index] = to;
        }
    }

Tenga en cuenta que todas las llamadas a bibliotecas externas son llamadas a funciones reales de EVM. Esto significa que
si pasas memoria o tipos de valores, se realizará una copia, incluso en el caso de la variable
``self``. La única situación en la que no se realizará ninguna copia
es cuando se utilizan variables de referencia de almacenamiento o cuando se llaman funciones
de la biblioteca.

Otro ejemplo muestra cómo definir un operador personalizado para un tipo definido por el usuario:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.19;

    type UFixed16x2 is uint16;

    using {
        add as +,
        div as /
    } for UFixed16x2 global;

    uint32 constant SCALE = 100;

    function add(UFixed16x2 a, UFixed16x2 b) pure returns (UFixed16x2) {
        return UFixed16x2.wrap(UFixed16x2.unwrap(a) + UFixed16x2.unwrap(b));
    }

    function div(UFixed16x2 a, UFixed16x2 b) pure returns (UFixed16x2) {
        uint32 a32 = UFixed16x2.unwrap(a);
        uint32 b32 = UFixed16x2.unwrap(b);
        uint32 result32 = a32 * SCALE / b32;
        require(result32 <= type(uint16).max, "Divide overflow");
        return UFixed16x2.wrap(uint16(a32 * SCALE / b32));
    }

    contract Math {
        function avg(UFixed16x2 a, UFixed16x2 b) public pure returns (UFixed16x2) {
            return (a + b) / UFixed16x2.wrap(200);
        }
    }
