.. index:: storage, state variable, mapping, transient storage

<<<<<<< HEAD
************************************
Diseño de variables de estado en almacenamiento
************************************

.. _storage-inplace-encoding:

Las variables de estado de loa contratos son almacen en almacenamiento en una forma
compacta de modo que varios valores a veces utilizan la misma ranura de almacenamiento.
Con la excepción para arrays y mapping que tiene los tamaños dinámicos (véase más adelante), datos
se almacena de manera contigua elemento despues elemento que comienza con la primera variable estado,
que se almacena en ranura ``0``. Para cada variable, un tamaño en bytes se determina según su tipo.
Varios, elementos contiguos que necesita menos que 32 bytes se empaquetan en una sola ranura
de almacenamiento si es posible, de acuerdo con las siguientes reglas:
=======
**********************************************************
Layout of State Variables in Storage and Transient Storage
**********************************************************

.. _storage-inplace-encoding:

.. note::
    The rules described in this section apply for both storage and transient storage data locations.
    The layouts are completely independent and don't interfere with each other's variable locations.
    Thus storage and transient storage state variables can be safely interleaved without any side effects.
    Only value types are supported for transient storage.

State variables of contracts are stored in storage in a compact way such
that multiple values sometimes use the same storage slot.
Except for dynamically-sized arrays and mappings (see below), data is stored
contiguously item after item starting with the first state variable,
which is stored in slot ``0``. For each variable,
a size in bytes is determined according to its type.
Multiple, contiguous items that need less than 32 bytes are packed into a single
storage slot if possible, according to the following rules:
>>>>>>> english/develop

- El primer elemento en una ranura de almacenamiento se almacena alineado en orden inferior.
- Los tipos de valor se usa sólo tantos bytes como sean necesarios para almacenarlos.
- Si un tipo de valor no se ajusta a la parte restante de una ranura de almacenamiento, se almacena en el siguiente ranura de almacenamiento.
- Structs y el dato de array inician una nueva ranura y sus elementos se empaquetan firmemente de acuerdo con estas reglas.
- Items following struct or array data always start a new storage slot.
- Los elementos que siguen struct o el dato de array siempre inician una ranura de almacenamiento neuva.

Para los contratos que utilizan herencia, el orden de las variables de estado está determinado por 
el orden linealizado C3 de los contratos a partir del contrato más básico. Si las reglas anteriores permiten, 
las variables de estado de diferentes contratos comparten la misma ranura de almacenamiento.

Los elementos de structs y arrays se almacenan uno después del otro, como si se dieran 
como valores individuales.

If a contract specifies a :ref:`custom storage layout<custom-storage-layout>`, the slots assigned
to static storage variables are shifted according the value defined as the layout base.
Locations of dynamic arrays and mappings are also indirectly affected by this due to shifting
of the static slots they are based on.
The custom layout is specified in the most derived contract and, following the order explained
above, starting from the most base-ward contract's variables, all storage slots are adjusted.

In the following example, contract ``C`` inherits from contracts ``A`` and ``B`` and also
specifies a custom storage base slot.
The result is that all storage variable slots of the inheritance tree are adjusted according to
the value specified by ``C``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.29;

    struct S {
        int32 x;
        bool y;
    }

    contract A {
        uint a;
        uint128 transient b;
        uint constant c = 10;
        uint immutable d = 12;
    }

    contract B {
        uint8[] e;
        mapping(uint => S) f;
        uint16 g;
        uint16 h;
        bytes16 transient i;
        S s;
        int8 k;
    }

    contract C is A, B layout at 42 {
        bytes21 l;
        uint8[10] m;
        bytes5[8] n;
        bytes5 o;
    }

In the example, the storage layout starts with the inherited
state variable ``a`` stored directly inside the base slot (slot ``42``).
Transient, constant and immutable variables are stored in separate
locations, and thus, ``b``, ``i``, ``c`` and ``d`` have no effect on the storage layout.
Then we get to the dynamic array ``e`` and mapping ``f``.
They both reserve a whole slot whose address will be used to :ref:`calculate<storage-hashed-encoding>`
the location where their data is actually stored.
The slot cannot be shared with any other variable, because the resulting addresses must be unique.
The next two variables, ``g`` and ``h``, need 2 bytes each and can be packed together into
slot ``45``, at offsets ``0`` and ``2`` respectively.
Since ``s`` is a struct, its two members are packed contiguously, each taking up 5 bytes.
Even though they both would still fit in slot ``45``, structs and arrays always start a new slot.
Therefore, ``s`` is placed in slot ``46`` and the next variable, ``k``, in slot ``47``.
Base contracts, on the other hand, can share slots with derived ones, so ``l`` does not require an new one.
Then variable ``m``, which is an array of 10 items, gets into slot ``48`` and takes up 10 bytes.
``n`` is an array as well, but due to the size of its items, cannot fill its first slot perfectly
and spills over to the next one.
Finally, variable ``o`` ends up in slot ``51``, even though it is of the same type as items of ``n``.
As explained before, variables after structs and arrays always start a new slot.

Putting it all together, the storage and transient storage layouts of contract ``C`` can be illustrated as follows:

- Storage:
  ::

      42 [aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]
      43 [eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee]
      44 [ffffffffffffffffffffffffffffffff]
      45 [                            hhgg]
      46 [                           yxxxx]
      47 [          lllllllllllllllllllllk]
      48 [                      mmmmmmmmmm]
      49 [  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn]
      50 [                      nnnnnnnnnn]
      51 [                           ooooo]

- Transient storage:
  ::

      00 [iiiiiiiiiiiiiiiibbbbbbbbbbbbbbbb]

Note that the storage specifier affects ``A`` and ``B`` only as a part of ``C``'s inheritance hierarchy.
When deployed independently, their storage starts at ``0``:

- Storage layout of ``A``:
  ::

      00 [aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa]

- Storage layout of ``B``:
  ::

      00 [eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee]
      01 [ffffffffffffffffffffffffffffffff]
      02 [                            hhgg]
      03 [                           yxxxx]
      04 [                               k]

.. warning::
    Cuando se utilizan elementos de menos de 32 bytes, el uso de gas de su contrato puede ser mayor.
    Esto se debe a que EVM funciona con 32 bytes a la vez. Por lo tanto, si el elemento es más pequeño
    ademos, el EVM debe utilizar mas operaciones para reducir el tamaño del elemento de 32 bytes hasta el tamaño deseado.

    Puede ser beneficioso utilizar tipos de tamaño reducido se se trata de valores de almacenamiento 
    porque el compilador empaquetará varios elementos en una ranura de almacenamiento y, por tanto, combinará
    varias lecturas o escrituras en una solo operación.
    Si no está leyendo o escribiendo todos los valores de una ranura al mismo tiempo, este puede
    tener el efecto contrario, aunque: Cuando se escribe un valor en un de almacenamiento de varios valores ranura,
    la ranura de almacenamiento debe leerse primero y, a continuacion, combinado con el nuevo valor de modo que no
    se destruyan otros datos de la misma ranura.

    Cuando se trata de argumentos de función o valores de memoria,
    no hay ningún beneficio inherente porque el compilador no empaqueta estos valores.

    Finalmente, para permitir que el EVM se optimice para esto, asegúrese de que intenta solicitar
    su variables de almacenamiento y miembros ``struct`` de tal forma que puedan ser empaquetados herméticamente.
    Por ejemplo, declarando las variables de almacenamiento en el orden de ``uint128, uint128, uint256`` en lugar de
    ``uint128, uint256, uint128``, ya que el primero sólo ocupará dos ranuras de almacenamiento mientras que el este último
    ocupará tres.

.. note::
     El diseño de las variables de estado en el almacenamiento se considera parte de la interfaz external
     de Solidity debido al hecho de que los punteros de almacenamiento se pueden pasar a las bibliotecas.
     Esto significa que cualquier cambio en las reglas descritas en esta sección se considera un de cambio
     de ruptura de lenguaje y debido a su carácter crítico debe ser considerado muy cuidadosamente ante
     en ejecución. En caso de que se produjera en cambio tan importante, deseríamos publicar un modo de compatibilidad
     en el que el compilador generaría compatible con el diseño anterior.


Mapero y Matrices Dinámicas
===========================

.. _storage-hashed-encoding:

Debido a sus tamaño impredecible, los mapeos y tipos de matriz de tamaño dinámico no se pueden almacenar
"entre" los variables de estado que las preceden y siguen.
En cambio, se considera que ocupan solo 32 bytes con respecto a 
:ref:`rules above <storage-inplace-encoding>` y los elementos que almacenan comenzando en una ranura de almacenamiento
diferente que se calcula usando un hash Keccak-256.

Suponga que la ubicación de almacenamiento del mapeo o matrice termina siendo una ranura ``p`` 
después de aplicar :ref:`the storage layout rules <storage-inplace-encoding>`.
Para matrices dinámicas,
esta ranura se almenace el numero de elementos en el matrice (matrices de bytes 
y strings son excepciónes, consulte :ref:`below <bytes-and-string>`).
Para mapeos, la renura permanece vacía, pero sigue sinedo necesario para garantizar que, incluso si hay
dos mapeos una al lado de la otra, su contenido termine en diferentes ubicaciones de almacenamiento.

Los datos de la matriz se ubican a partir de ``keccak256(p)`` y se presentan de la misma manera que 
lo harían los datos de matriz de tamaño estático: un elemento tras otro, potencialmente compartiendo 
ranuras de almacenamiento si los elementos no tienen más de 16 bytes. Las matrices dinámicas de matrices dinámicas aplican esta 
regla de forma recursiva. La ubicación del elemento ``x[i][j]``, donde el tipo de ``x`` es ``uint24[][]``, 
se calcula de la siguiente manera (de nuevo, suponiendo que ``x`` se almacena en la ranura ``p``):
La ranura es ``keccak256(keccak256(p) i) floor(j / floor(256 / 24))`` y 
el elemento se puede obtener de los datos de la ranura ``v`` usando ``(v >> ((j % floor(256 / 24)) * 24)) & type(uint24).max``.

El valor correspondiente a una clave de mapero ``k`` se encuentra en ``keccak256(h(k) . p)`` 
donde ``.`` es concatenación y ``h`` es una función que se aplica a la clave dependiendo de su tipo:

- Para los tipos de valor, ``h`` rellena el valor a 32 bytes de la misma manera que cuando se almacena el valor en la memoria.
- Para strings y matrices de bytes, ``h(k)`` son solo los datos sin relleno.

Si el valor de mapero es un 
tipo sin valor, la ranura calculada marca el inicio de los datos. Si el valor es de tipo struct, 
por ejemplo, debe agregar un desplazamiento correspondiente al miembro struct para llegar al miembro.

Como ejemplo, considere el siguiente contrato:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;


    contract C {
        struct S { uint16 a; uint16 b; uint256 c; }
        uint x;
        mapping(uint => mapping(uint => S)) data;
    }

Calculemos la ubicación de almacenamiento de ``data[4][9].c``. 
La posición de la asignación en sí es ``1`` (la variable ``x`` con 32 bytes la precede). 
Esto significa que ``data[4]`` se almacena en ``keccak256(uint256(4) . uint256(1))``. El tipo de ``data[4]`` es 
de nuevo un mapeo y los datos para ``data[4][9]`` comienzan en la ranura 
``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))``.
El desplazamiento de ranura del miembro ``c`` dentro de la estructura ``S`` es ``1`` porque ``a`` y ``b`` están empaquetados 
en una sola ranura. Esto significa que la ranura para ``data[4][9].c`` es 
``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1))) 1``. 
El tipo del valor es ``uint256``, por lo que utiliza una sola ranura.


.. _bytes-and-string:

``bytes`` y ``string``
------------------------

``bytes`` y ``string`` están codificados de forma idéntica.
En general, la codificación es similar a ``bytes1[]``, en el sentido de que hay una ranura para la propia matriz y 
un área de datos que se calcula utilizando un hash ``keccak256`` de la posición de esa ranura. 
Sin embargo, para valores cortos (menos de 32 bytes) los elementos de matriz se almacenan junto con la longitud en la misma ranura.

En particular: si los datos tienen como máximo ``31`` bytes de longitud, los elementos se almacenan 
en los bytes de orden superior (alineados a la izquierda) y el byte de orden más bajo almacena el valor ``length * 2``. 
Para las matrices de bytes que almacenan datos que tienen ``32`` o más bytes de longitud, la ranura principal ``p`` almacena ``length * 2 + 1`` y los datos 
se almacenan como de costumbre en ``keccak256(p)``. Esto significa que puede distinguir una matriz corta de una matriz larga 
comprobando si se establece el bit más bajo: corto (no establecido) y largo (conjunto).

.. note::
  Actualmente no se admite el manejo de ranuras codificadas de forma no válida, pero es posible que se agreguen en el futuro. 
  Si está compilando a través de IR, la lectura de una ranura codificada no válidamente da como resultado un error de ``Panico(0x22)``.

Salida JSON
===========

.. _storage-layout-top-level:

<<<<<<< HEAD
El diseño de almacenamiento de un contrato se puede solicitar a través 
de :ref:`standard JSON interface <compiler-api>`. La salida es un objeto JSON que contiene dos claves,
``storage`` y ``types``. El objeto ``storage`` es una matriz donde cada 
elemento tiene la siguiente forma:
=======
The storage (or transient storage) layout of a contract can be requested via
the :ref:`standard JSON interface <compiler-api>`.  The output is a JSON object containing two keys,
``storage`` and ``types``.  The ``storage`` object is an array where each
element has the following form:
>>>>>>> english/develop


.. code-block:: json


    {
        "astId": 2,
        "contract": "fileA:A",
        "label": "x",
        "offset": 0,
        "slot": "0",
        "type": "t_uint256"
    }

El ejemplo anterior es el diseño de almacenamiento de ``contract A { uint x; }`` de la unidad de origen ``fileA`` 
y

- ``astId`` es el identificador del nodo AST de la declaración de la variable de estado
- ``contract`` es el nombre del contrato incluyendo su ruta como prefijo
- ``label`` es el nombre de la variable de estado
- ``offset`` es el desplazamiento en bytes dentro de la ranura de almacenamiento según la codificación
- ``slot`` es la ranura de almacenamiento donde reside o se inicia la variable de estado. Este 
  número puede ser muy grande y, por lo tanto, su valor JSON se representa como una 
  cadena. 
- ``type`` es un identificador utilizado como clave para la información de tipo de la variable (que se describe a continuación)

El ``type`` en esta caso ``t_uint256`` representa un elemento un
``types``, que tiene la forma: 


.. code-block:: json

    {
        "encoding": "inplace",
        "label": "uint256",
        "numberOfBytes": "32",
    }

donde

- ``encoding`` cómo se codifican los datos en el almacenamiento, donde los valores posibles son:

  - ``inplace``: Los datos se presentan de forma contigua en el almacenamiento (consulte :ref:`above <storage-inplace-encoding>`).
  - ``mapping``: Método basado en hash Keccak-256 (consulte :ref:`above <storage-hashed-encoding>`).
  - ``dynamic_array``: Método basado en hash Keccak-256 (consulte :ref:`above <storage-hashed-encoding>`).
  - ``bytes``: una sola ranura o basado en hash Keccak-256 dependiendo del tamaño de los datos (consulte :ref:`above <bytes-and-string>`).


- ``label`` es el nombre de tipo canónico.
- ``numberOfBytes`` es el número de bytes utilizados (como una cadena decimal).
  Tenga cuenta que si ``numberOfBytes > 32`` esto significa que se utiliza más de una ranura.

Algunos tipos tienen información adicional además de los cuatro anteriores. Los mapeos contienen 
sus tipos ``key`` y ``value`` (de nuevo haciendo referencia a una entrada en esta asignación de tipos), 
las matrices tienen su tipo ``base`` y las structs enumeran sus ``members`` en el 
mismo formato que el ``storage`` de nivel superior (consulte :ref:`above <storage-layout-top-level>`).

.. note::
  The JSON output format of a contract's storage layout is still considered experimental
  and is subject to change in non-breaking releases of Solidity.

<<<<<<< HEAD
El ejemplo siguiente muestra un contrato y su diseño de almacenamiento, que 
contiene tipos de valor y referencía, tipos codificados empaquetados y tipos anidados.
=======
The following example shows a contract and both its storage and transient storage layout,
containing value and reference types, types that are encoded packed, and nested types.
>>>>>>> english/develop


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.28;
    contract A {
        struct S {
            uint128 a;
            uint128 b;
            uint[2] staticArray;
            uint[] dynArray;
        }

        uint x;
        uint transient y;
        uint w;
        uint transient z;

        S s;
        address addr;
        address transient taddr;
        mapping(uint => mapping(address => bool)) map;
        uint[] array;
        string s1;
        bytes b1;
    }

Storage Layout
--------------

.. code-block:: json

    {
      "storage": [
        {
          "astId": 15,
          "contract": "fileA:A",
          "label": "x",
          "offset": 0,
          "slot": "0",
          "type": "t_uint256"
        },
        {
          "astId": 19,
          "contract": "fileA:A",
          "label": "w",
          "offset": 0,
          "slot": "1",
          "type": "t_uint256"
        },
        {
          "astId": 24,
          "contract": "fileA:A",
          "label": "s",
          "offset": 0,
          "slot": "2",
          "type": "t_struct(S)13_storage"
        },
        {
          "astId": 26,
          "contract": "fileA:A",
          "label": "addr",
          "offset": 0,
          "slot": "6",
          "type": "t_address"
        },
        {
          "astId": 34,
          "contract": "fileA:A",
          "label": "map",
          "offset": 0,
          "slot": "7",
          "type": "t_mapping(t_uint256,t_mapping(t_address,t_bool))"
        },
        {
          "astId": 37,
          "contract": "fileA:A",
          "label": "array",
          "offset": 0,
          "slot": "8",
          "type": "t_array(t_uint256)dyn_storage"
        },
        {
          "astId": 39,
          "contract": "fileA:A",
          "label": "s1",
          "offset": 0,
          "slot": "9",
          "type": "t_string_storage"
        },
        {
          "astId": 41,
          "contract": "fileA:A",
          "label": "b1",
          "offset": 0,
          "slot": "10",
          "type": "t_bytes_storage"
        }
      ],
      "types": {
        "t_address": {
          "encoding": "inplace",
          "label": "address",
          "numberOfBytes": "20"
        },
        "t_array(t_uint256)2_storage": {
          "base": "t_uint256",
          "encoding": "inplace",
          "label": "uint256[2]",
          "numberOfBytes": "64"
        },
        "t_array(t_uint256)dyn_storage": {
          "base": "t_uint256",
          "encoding": "dynamic_array",
          "label": "uint256[]",
          "numberOfBytes": "32"
        },
        "t_bool": {
          "encoding": "inplace",
          "label": "bool",
          "numberOfBytes": "1"
        },
        "t_bytes_storage": {
          "encoding": "bytes",
          "label": "bytes",
          "numberOfBytes": "32"
        },
        "t_mapping(t_address,t_bool)": {
          "encoding": "mapping",
          "key": "t_address",
          "label": "mapping(address => bool)",
          "numberOfBytes": "32",
          "value": "t_bool"
        },
        "t_mapping(t_uint256,t_mapping(t_address,t_bool))": {
          "encoding": "mapping",
          "key": "t_uint256",
          "label": "mapping(uint256 => mapping(address => bool))",
          "numberOfBytes": "32",
          "value": "t_mapping(t_address,t_bool)"
        },
        "t_string_storage": {
          "encoding": "bytes",
          "label": "string",
          "numberOfBytes": "32"
        },
        "t_struct(S)13_storage": {
          "encoding": "inplace",
          "label": "struct A.S",
          "members": [
            {
              "astId": 3,
              "contract": "fileA:A",
              "label": "a",
              "offset": 0,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 5,
              "contract": "fileA:A",
              "label": "b",
              "offset": 16,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 9,
              "contract": "fileA:A",
              "label": "staticArray",
              "offset": 0,
              "slot": "1",
              "type": "t_array(t_uint256)2_storage"
            },
            {
              "astId": 12,
              "contract": "fileA:A",
              "label": "dynArray",
              "offset": 0,
              "slot": "3",
              "type": "t_array(t_uint256)dyn_storage"
            }
          ],
          "numberOfBytes": "128"
        },
        "t_uint128": {
          "encoding": "inplace",
          "label": "uint128",
          "numberOfBytes": "16"
        },
        "t_uint256": {
          "encoding": "inplace",
          "label": "uint256",
          "numberOfBytes": "32"
        }
      }
    }

Transient Storage Layout
------------------------

.. code-block:: json

    {
      "storage": [
        {
          "astId": 17,
          "contract": "fileA:A",
          "label": "y",
          "offset": 0,
          "slot": "0",
          "type": "t_uint256"
        },
        {
          "astId": 21,
          "contract": "fileA:A",
          "label": "z",
          "offset": 0,
          "slot": "1",
          "type": "t_uint256"
        },
        {
          "astId": 28,
          "contract": "fileA:A",
          "label": "taddr",
          "offset": 0,
          "slot": "2",
          "type": "t_address"
        }
      ],
      "types": {
        "t_address": {
          "encoding": "inplace",
          "label": "address",
          "numberOfBytes": "20"
        },
        "t_uint256": {
          "encoding": "inplace",
          "label": "uint256",
          "numberOfBytes": "32"
        }
      }
    }
