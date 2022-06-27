.. index:: ! contract

.. _contracts:

##########
Contractos
##########

Los contratos en Solidity son similares a las clases en lenguajes orientados a objetos.
Contienen datos persistentes en variables de estado y funciones que pueden modificar estas variables.
Llamar a una función en un contrato diferente (una instancia) realizará una llamada a una función en el EVM y, por lo tanto, cambiará el contexto, de modo que las variables de estado en el contrato llamado se vuelven inaccesibles.
Un contrato y sus funciones deben ser llamados para que algo suceda.
No existe un concepto "cron" en Ethereum para llamar automáticamente a una función en un evento en particular.

.. include:: contracts/creating-contracts.rst

.. include:: contracts/visibility-and-getters.rst

.. include:: contracts/function-modifiers.rst

.. include:: contracts/constant-state-variables.rst
.. include:: contracts/functions.rst

.. include:: contracts/events.rst
.. include:: contracts/errors.rst

.. include:: contracts/inheritance.rst

.. include:: contracts/abstract-contracts.rst
.. include:: contracts/interfaces.rst

.. include:: contracts/libraries.rst

.. include:: contracts/using-for.rst