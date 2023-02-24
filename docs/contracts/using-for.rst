.. index:: ! using for, library

.. _using-for:

*********
Using For
*********

La directiva ``using A for B;`` se puede usar para adjuntar
funciones (``A``) como miembro para cualquier tipo (``B``).
Estas funciones recibirán el objeto al que se llaman
como su primer parámetro (como la variable ``self`` en Python).

Es válido a nivel de archivo o dentro de un contrato,
a nivel de contrato.

La primera parte, ``A``, puede ser una de:

- Una lista de nivel de archivo o de funciones de biblioteca (e.g. ``using {f, g, h, L.t} for uint;``) -
  solo esas funciones se adjuntarán al tipo como funciones miembro.
  Ten en cuenta que funciones de la biblioteca privada solo se pueden especificar cuando ``using for`` esté dentro de la biblioteca.
- El nombre de una biblioteca (por ejemplo: ``using L for uint;``) -
  todas las funciones de la biblioteca, tanto públicas como internas, se adjuntan al tipo.

A nivel de archivo, la segunda parte, ``B``, tiene que ser un tipo explícito (sin especificador de ubicación de datos).
Dentro de los contratos, también puedes usar ``*`` en lugar del tipo (por ejemplo: ``using L for *;``),
que tiene el efecto de que todas las funciones de la biblioteca ``L``
se adjuntan a *todos* los tipos.

Si especificas una biblioteca, *todas* las funciones en la biblioteca se adjuntan,
incluso aquellas en las que el tipo del primer parámetro no
coincide con el tipo del objeto. El tipo se comprueba en el
momento en que se llama a la función y se realiza la
resolución se la sobrecarga de funciones.

Si usas una lista de funciones (por ejemplo: ``using {f, g, h, L.t} for uint;``),
el tipo (``uint``) tiene que ser implícitamente convertible al
primer parámetro de cada una de estas funciones. Esta comprobación se
realiza incluso si no se llama a ninguna de estas funciones.

La directiva ``using A for B;`` se activa solo dentro del ámbito
actual (ya sea el contrato o el módulo/unidad fuente actual),
incluso dentro de todas sus funciones, y no tiene ningún efecto
fuera del contrato o módulo en el que se utiliza.

Cuando la directiva se usa a nivel de archivo y se aplica a un
tipo definido por el usuario que se definió a nivel de archivo en el mismo archivo,
la palabra ``global`` se puede agregar al final. Esto tendrá el
efecto de que las funciones se adjuntan al tipo en todos los lugares donde
el tipo esté disponible (incluidos otros archivos), no solo en el
ámbito de la declaración using.

Reescribamos el ejemplo establecido de la sección
:ref:`libraries` de esta manera, usando funciones a nivel de archivo
en lugar de funciones de biblioteca.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    struct Data { mapping(uint => bool) flags; }
    // Ahora adjuntamos funciones al tipo.
    // Las funciones adjuntadas se pueden usar en el resto del módulo.
    // Si importas el módulo, tienes que
    // repetir la directiva using ahí, por ejemplo como
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
            // Aquí, todas las variables de tipo Data tienen
            // funciones miembro correspondientes.
            // La siguiente llamada de función es idéntica a
            // `Set.insert(knownValues, value)`
            require(knownValues.insert(value));
        }
    }

También es posible ampliar los tipos incorporados de esta manera.
En este ejemplo, usaremos una biblioteca.

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
            // Esto realiza la llamada a la función de la biblioteca.
            uint index = data.indexOf(from);
            if (index == type(uint).max)
                data.push(to);
            else
                data[index] = to;
        }
    }

Ten en cuenta que todas las llamadas a bibliotecas externas son llamadas a funciones EVM reales. Esto significa que
si pasas tipos de memoria o de valor, se realizará una copia, incluso en el caso de
la variable ``self``. La única situación donde no se realizará una copia es
cuando se utilizan variables de referencia de almacenamiento o cuando se llama a
funciones de biblioteca interna.
