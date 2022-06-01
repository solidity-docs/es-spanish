Solidity
========

Solidity es un lenguaje de alto nivel orientado a objetos, para implementar contratos inteligentes (smart contracts).
Los contratos inteligentes son programas que rigen el comportamiento de las cuentas dentro del ecosistema de Ethereum.

Solidity es un `lenguaje de llaves <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_, diseñado para la Máquina Virtual de Ethereum (Ethereum Virtual Machine).
Está influenciado por los lenguajes de programación C++, Python y JavaScript.
Para más detalles sobre los lenguajes que han inspirado Solidity visita la sección :doc:`influencia de lenguajes <language-influences>`.

Solidity es estáticamente escrito, soporta herencia, librerías, y tipos complejos definidos por el usuario, entre otras características.

Con Solidity se pueden crear contratos para votaciones, financiación colectiva (crowdfunding), subastas a ciegas, y monederos (wallets) multifirma.

Al momento de desplegar un contrato, debes utilizar la versión más reciente de Solidity.
Aparte de casos excepcionales, solamente la última versión recibe `correciones de seguridad <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Además, cambios importantes y nuevas funciones se introducen periódicamente.
Actualmente se utiliza el número de versión 0.y.z `para indicar estos rápidos cambios <https://semver.org/#spec-item-4>`_.

Advertencia:

Solidity lanzó recientemente la versión 0.8.x, que introdujo varios cambios significantes.
Asegúrese de leer :doc:`la lista completa de cambios <080-breaking-changes>`.

Ideas para mejorar Solidity o esta misma documentación son siempre bienvenidas, lea nuestra :doc:`guía de contribución <contributing>` para más detalles.

Nota:

Puede descargar esta documentación como PDF, HTML o Epub haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando el formato preferido de descarga.

Para Comenzar
---------------

**1. Comprender los Conceptos Básicos de los Contratos Inteligentes**

Si usted es nuevo y todavía no está familiarizado con el concepto de los contratos inteligentes, le recomendamos iniciar con la sección "Introducción a los Contratos Inteligents", que cubre:

* :ref:`Un ejemplo sencillo de un contrato inteligente <simple-smart-contract>` escrito en Solidity.
* :ref:`Conceptos Básicos del Blockchain <blockchain-basics>`.
* :ref:`La Máquina Virtual de Ethereum <the-ethereum-virtual-machine>`.

**2. Conozca Solidity**

Una vez que esté relacionado con los conceptos básicos, le recomendamos leer las secciones de :doc:`"Solidity con Ejemplos" <solidity-by-example>` y "Descripción del Lenguaje" para comprender los conceptos fundamentales del lenguaje.

**3. Instalar el Compilador de Solidity**

Hay distintas maneras de instalar el compilador de Solidity, simplemente elija su opción preferida y siga los pasos indicados en la :ref:`página de instalación <installing-solidity>`.

.. hint::
  You can try out code examples directly in your browser with the
  `Remix IDE <https://remix.ethereum.org>`_. Remix is a web browser based IDE
  that allows you to write, deploy and administer Solidity smart contracts, without
  the need to install Solidity locally.

.. warning::
    As humans write software, it can have bugs. You should follow established
    software development best-practices when writing your smart contracts. This
    includes code review, testing, audits, and correctness proofs. Smart contract
    users are sometimes more confident with code than their authors, and
    blockchains and smart contracts have their own unique issues to
    watch out for, so before working on production code, make sure you read the
    :ref:`security_considerations` section.

**4. Learn More**

If you want to learn more about building decentralized applications on Ethereum, the
`Ethereum Developer Resources <https://ethereum.org/en/developers/>`_
can help you with further general documentation around Ethereum, and a wide selection of tutorials,
tools and development frameworks.

If you have any questions, you can try searching for answers or asking on the
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_, or
our `Gitter channel <https://gitter.im/ethereum/solidity/>`_.

.. _translations:

Translations
------------

Community contributors help translate this documentation into several languages.
Note that they have varying degrees of completeness and up-to-dateness. The English
version stands as a reference.

You can switch between languages by clicking on the flyout menu in the bottom-left corner
and selecting the preferred language.

* `French <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesian <https://github.com/solidity-docs/id-indonesian>`_
* `Persian <https://github.com/solidity-docs/fa-persian>`_
* `Japanese <https://github.com/solidity-docs/ja-japanese>`_
* `Korean <https://github.com/solidity-docs/ko-korean>`_
* `Chinese <https://github.com/solidity-docs/zh-cn-chinese/>`_

.. note::

   We recently set up a new GitHub organization and translation workflow to help streamline the
   community efforts. Please refer to the `translation guide <https://github.com/solidity-docs/translation-guide>`_
   for information on how to start a new language or contribute to the community translations.

Contents
========

:ref:`Keyword Index <genindex>`, :ref:`Search Page <search>`

.. toctree::
   :maxdepth: 2
   :caption: Basics

   introduction-to-smart-contracts.rst
   installing-solidity.rst
   solidity-by-example.rst

.. toctree::
   :maxdepth: 2
   :caption: Language Description

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Compiler

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Internals

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Additional Material

   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst
   natspec-format.rst
   security-considerations.rst
   smtchecker.rst
   resources.rst
   path-resolution.rst
   yul.rst
   style-guide.rst
   common-patterns.rst
   bugs.rst
   contributing.rst
   brand-guide.rst
   language-influences.rst
