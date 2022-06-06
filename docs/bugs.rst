.. index:: Bugs

.. _known_bugs:

##################
Lista de Bugs Conocidos
##################

A continuación, puede encontrar una lista en formato JSON de algunos de los bugs conocidos, relacionados con la seguridad en el compiladfor de Solidity.
El archivo se encuentra en el `repositorio de GitHub <https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_.
La lista se remonta a la versión 0.3.0, los errores que se conocen, que están presentes sólo en versiones anteriores, no se enumeran.

Hay otro archivo llamado `bugs_by_version.json <https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json>`_, que se puede utilizar para comprobar qué errores afectan a una versión específica del compilador.

Herramientas para la verificación del código fuente de un contrato y otras herramientas que interactúen con contratos, deben consultar esta lista de acuerdo a los siguientes criterios:

- Se puede sospechar levemente si un contrato fue compilado con una versión "nightly" del compilador en vez de un versión publicada.
  Esta lista no realiza un seguimiento de las versiones que no han sido publicadas o versiones "nightly".

- It is mildly suspicious if a contract was compiled with a nightly
  compiler version instead of a released version. This list does not keep
  track of unreleased or nightly versions.
- It is also mildly suspicious if a contract was compiled with a version that was
  not the most recent at the time the contract was created. For contracts
  created from other contracts, you have to follow the creation chain
  back to a transaction and use the date of that transaction as creation date.
- It is highly suspicious if a contract was compiled with a compiler that
  contains a known bug and the contract was created at a time where a newer
  compiler version containing a fix was already released.

The JSON file of known bugs below is an array of objects, one for each bug,
with the following keys:

uid
    Unique identifier given to the bug in the form of ``SOL-<year>-<number>``.
    It is possible that multiple entries exists with the same uid. This means
    multiple version ranges are affected by the same bug.
name
    Unique name given to the bug
summary
    Short description of the bug
description
    Detailed description of the bug
link
    URL of a website with more detailed information, optional
introduced
    The first published compiler version that contained the bug, optional
fixed
    The first published compiler version that did not contain the bug anymore
publish
    The date at which the bug became known publicly, optional
severity
    Severity of the bug: very low, low, medium, high. Takes into account
    discoverability in contract tests, likelihood of occurrence and
    potential damage by exploits.
conditions
    Conditions that have to be met to trigger the bug. The following
    keys can be used:
    ``optimizer``, Boolean value which
    means that the optimizer has to be switched on to enable the bug.
    ``evmVersion``, a string that indicates which EVM version compiler
    settings trigger the bug. The string can contain comparison
    operators. For example, ``">=constantinople"`` means that the bug
    is present when the EVM version is set to ``constantinople`` or
    later.
    If no conditions are given, assume that the bug is present.
check
    This field contains different checks that report whether the smart contract
    contains the bug or not. The first type of check are Javascript regular
    expressions that are to be matched against the source code ("source-regex")
    if the bug is present.  If there is no match, then the bug is very likely
    not present. If there is a match, the bug might be present.  For improved
    accuracy, the checks should be applied to the source code after stripping
    comments.
    The second type of check are patterns to be checked on the compact AST of
    the Solidity program ("ast-compact-json-path"). The specified search query
    is a `JsonPath <https://github.com/json-path/JsonPath>`_ expression.
    If at least one path of the Solidity AST matches the query, the bug is
    likely present.

.. literalinclude:: bugs.json
   :language: js
