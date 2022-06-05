.. index:: type

.. _types:

*****
Tipos
*****

Solidity es estáticamente escrito, lo que significa que se debe especificar el tipo de cada variable (de estado y local).
Solidity proporciona varios tipos elementales que se pueden combinar para formar tipos complejos.

Adicionalmente, los tipos pueden interactuar entre sí en expresiones que contienen operadores.
Para obtener una referencia rápida de los distintos operadores, consulte :ref:`orden`.

El concepto de valores "indefinidos (undefined)" o "nulos (null)" no existe en Solidity, pero las variables recién declaradas siempre tienen un :ref:`valor por defecto<default-value>` que depende de su tipo.
Para cualquier valor inesperado, debe usar la :ref:`función revert <assert-and-require>`, para revertir toda la transacción, o devolver una tupla  con un segundo valor bool que indique el éxito de la operación.

.. include:: types/value-types.rst

.. include:: types/reference-types.rst

.. include:: types/mapping-types.rst

.. include:: types/operators.rst

.. include:: types/conversion.rst
