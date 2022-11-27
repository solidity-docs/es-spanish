.. index:: !mapping
.. _mapping-types:

Tipos Mapping
=============

Los tipos mapping usan la sintaxis ``mapping(KeyType => ValueType)`` y las variables
del tipo mapping son declaradas usando la sintaxis ``mapping(KeyType => ValueType) VariableName``.
Donde  ``KeyType`` puede ser cualquier tipo estándar, ``bytes``, ``string``, cualquier contrato 
o un tipo enum. Sin embargo, tipos definidos por el propio usuario o tipos complejos, como 
mappings, structs o arrays no están permitidos para ``KeyType``. Por otro lado, para ``ValueType``,
puede ser cualquier tipo, incluyendo mappings, arrays o structs.

Puedes pensar en los mappings como `tablas hash <https://es.wikipedia.org/wiki/Tabla_hash>`_, las
cuales se inicializan virtualmente, asumiendo que ya existen todas las posibles claves, y donde 
se mapea cada clave a un valor cuya representación byte está formada por todo ceros, equivalente al 
:ref:`valor por defecto <default-value>` de un tipo. Aunque la similitud termina aquí, 
dado que las claves no se almacenan realmente en el mapping, sino tan solo su hash ``keccak256``, 
el cual se usa para buscar su valor.

Por esto mismo, los mappings no tienen una longitud (length), ni tampoco son exactamente 
una tabla la cual relaciona claves con valores. Por tanto, no puede eliminarse información
respecto a cada clave asociada. (ver :ref:`clearing-mappings`).

Los mappings solo pueden almacenar información en el ``storage``, por lo que solo están
permitidos para variables de estado, como tipos que referencian al storage en funciones, 
o como parámetros de funciones de librerías. Pero no se pueden usar como parámetros o 
como retorno de funciones públicamente visibles de un contrato. Y estas mismas 
restricciones también se aplican para arrays y structs los cuales contengan mappings.

Puedes marcar variables de estado de tipo mapping como ``public`` y así Solidity creará una
:ref:`función get (getter) <visibility-and-getters>` por ti. El ``KeyType`` se convertirá en
un parámetro de la función get.
Si ``ValueType`` es un tipo de valor o un struct, la función get retornará ``ValueType``.
Si ``ValueType`` es un array o un mapping, la función get tendrá un parámetro por cada
``KeyType``, recursivamente.

En el siguiente ejemplo, el contrato ``MappingExample`` define un mapping público ``balances``,
donde el tipo de clave es un tipo ``address``, y el tipo de valor es un tipo ``uint``,
mapeando así una dirección Ethereum a un número entero sin signo. Como ``uint`` es un 
tipo de valor, la función get devolverá un valor que encajará con este tipo, tal como
puedes ver aquí en el contrato ``MappingUser``, el cual retorna el valor para la address 
especificada.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract MappingExample {
        mapping(address => uint) public balances;

        function update(uint newBalance) public {
            balances[msg.sender] = newBalance;
        }
    }

    contract MappingUser {
        function f() public returns (uint) {
            MappingExample m = new MappingExample();
            m.update(100);
            return m.balances(address(this));
        }
    }

El siguiente ejemplo es una versión simplificada de un 
`Token ERC20 <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol>`_.
``_allowances`` es un ejemplo de un tipo mapping dentro de otro tipo mapping.
El ejemplo de a continuación usa ``_allowances`` para registrar el importe total que otra persona puede retirar 
desde su cuenta.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract MappingExample {

        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        function allowance(address owner, address spender) public view returns (uint256) {
            return _allowances[owner][spender];
        }

        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
            require(_allowances[sender][msg.sender] >= amount, "ERC20: Allowance not high enough.");
            _allowances[sender][msg.sender] -= amount;
            _transfer(sender, recipient, amount);
            return true;
        }

        function approve(address spender, uint256 amount) public returns (bool) {
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(_balances[sender] >= amount, "ERC20: Not enough funds.");

            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }


.. index:: !iterable mappings
.. _iterable-mappings:

Iterar un Mapping
-----------------

No puedes iterar un mapping. Es decir, no puedes numerar las claves.
Sin embargo, sí es posible implementar una estructura de datos por encima para
poder iterar esta estructura contenedora. Por ejemplo, el siguiente código implementa
una librería ``IterableMapping`` donde luego el contrato ``User`` añade información,
y la función ``sum`` puede iterar sobre la suma de todos los valores.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    struct IndexValue { uint keyIndex; uint value; }
    struct KeyFlag { uint key; bool deleted; }

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    type Iterator is uint;

    library IterableMapping {
        function insert(itmap storage self, uint key, uint value) internal returns (bool replaced) {
            uint keyIndex = self.data[key].keyIndex;
            self.data[key].value = value;
            if (keyIndex > 0)
                return true;
            else {
                keyIndex = self.keys.length;
                self.keys.push();
                self.data[key].keyIndex = keyIndex + 1;
                self.keys[keyIndex].key = key;
                self.size++;
                return false;
            }
        }

        function remove(itmap storage self, uint key) internal returns (bool success) {
            uint keyIndex = self.data[key].keyIndex;
            if (keyIndex == 0)
                return false;
            delete self.data[key];
            self.keys[keyIndex - 1].deleted = true;
            self.size --;
        }

        function contains(itmap storage self, uint key) internal view returns (bool) {
            return self.data[key].keyIndex > 0;
        }

        function iterateStart(itmap storage self) internal view returns (Iterator) {
            return iteratorSkipDeleted(self, 0);
        }

        function iterateValid(itmap storage self, Iterator iterator) internal view returns (bool) {
            return Iterator.unwrap(iterator) < self.keys.length;
        }

        function iterateNext(itmap storage self, Iterator iterator) internal view returns (Iterator) {
            return iteratorSkipDeleted(self, Iterator.unwrap(iterator) + 1);
        }

        function iterateGet(itmap storage self, Iterator iterator) internal view returns (uint key, uint value) {
            uint keyIndex = Iterator.unwrap(iterator);
            key = self.keys[keyIndex].key;
            value = self.data[key].value;
        }

        function iteratorSkipDeleted(itmap storage self, uint keyIndex) private view returns (Iterator) {
            while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
                keyIndex++;
            return Iterator.wrap(keyIndex);
        }
    }

    // Modo de funcionamiento
    contract User {
        // Un simple struct mantiene nuestros datos
        itmap data;
        // Se aplican las funciones de la librería para este tipo de datos
        using IterableMapping for itmap;
        
        // Añadimos algo
        function insert(uint k, uint v) public returns (uint size) {
            // Esto llama a IterableMapping.insert(data, k, v)
            data.insert(k, v);
            // Todavía podemos acceder a las partes del struct
            // pero debemos hacerlo con cuidado para no desorganizar la lógica
            return data.size;
        }

        // Se calcula la suma de todos los datos almacenados
        function sum() public view returns (uint s) {
            for (
                Iterator i = data.iterateStart();
                data.iterateValid(i);
                i = data.iterateNext(i)
            ) {
                (, uint value) = data.iterateGet(i);
                s += value;
            }
        }
    }

.. note::
      **Nota del traductor:**
      En la documentación oficial en inglés no se explica literalmente. Sin embargo,
      sería conveniente aclarar la diferencia que existe entre arrays y mappings,
      dado que si no estás muy familiarizado con el desarrollo de smart contracts, te
      puede parecer extraño qué sentido tiene la existencia de mappings, cuando ya
      tenemos arrays, los cuales sirven aparentemente para lo mismo, y además con menos
      limitaciones, por poder almacenar claves tanto en el storage como en la memoria,
      la posibilidad de ser iterados, etc. En la documentación oficial, tan solo se indica
      la existencia del tipo mapping, y cómo funciona, pero obvia su razón de ser, y el
      motivo por el cual se creó este tipo.
      
      La razón es muy sencilla. En el mundo de Ethereum, todo cuesta gas, el cálculo de expresiones,
      el almacenamiento, etc. Y por eso se han creado los mappings, pues son una solución mucho más
      económica y eficiente, en términos de gas, respecto de los arrays. Al no tener que guardar 
      realmente las claves en la blockchain, ahorramos gas. Al no tener la necesidad de recorrer 
      los valores, también ahorramos gas. Y al no tener que crear un índice para funciones de búsqueda, 
      nuevamente ahorramos gas.
      
      Obviamente, no son siempre la mejor solución, dado que también tienen las limitaciones explicadas
      en este apartado, pero siempre que estas limitaciones no nos supongan un problema, los 
      mappings serán una mejor opción. El ejemplo de uso inteligente de mappings más común, es la relación 
      de unos datos determinados con una address concreta. Por ejemplo, un posible balance que pueda estar
      asociado a cada dirección.
