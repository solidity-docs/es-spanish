.. index:: type

.. _types:

*****
Tipos
*****

Solidity es estáticamente escrito, lo que significa que se debe especificar el tipo de cada variable (estado y local).
Solidity proporciona varios tipos elementales que se pueden combinar para formar tipos complejos.

In addition, types can interact with each other in expressions containing
operators. For a quick reference of the various operators, see :ref:`order`.

The concept of "undefined" or "null" values does not exist in Solidity, but newly
declared variables always have a :ref:`default value<default-value>` dependent
on its type. To handle any unexpected values, you should use the :ref:`revert function<assert-and-require>` to revert the whole transaction, or return a
tuple with a second ``bool`` value denoting success.

.. include:: types/value-types.rst

.. include:: types/reference-types.rst

.. include:: types/mapping-types.rst

.. include:: types/operators.rst

.. include:: types/conversion.rst
