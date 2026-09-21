Solidity
========

Solidity is an object-oriented, high-level language for implementing smart contracts.
Smart contracts are programs that govern the behavior of accounts within the Ethereum state.

Solidity is a `curly-bracket language <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly_bracket_languages>`_ designed to target the Ethereum Virtual Machine (EVM).
It is influenced by C++, Python, and JavaScript.
You can find more details about which languages Solidity has been inspired by in the :doc:`language influences <language-influences>` section.

Solidity is statically typed, supports inheritance, libraries, and complex user-defined types, among other features.

With Solidity, you can create contracts for uses such as voting, crowdfunding, blind auctions, and multi-signature wallets.

When deploying contracts, you should use the latest released version of Solidity.
Apart from exceptional cases, only the latest version receives
`security fixes <https://github.com/argotorg/solidity/security/policy#supported-versions>`_.
Furthermore, breaking changes, as well as new features, are introduced regularly.
We currently use a 0.y.z version number `to indicate this fast pace of change <https://semver.org/#spec-item-4>`_.

.. Advertencia::

  Solidity recently released the 0.8.x version that introduced a lot of breaking changes.
  Make sure you read :doc:`the full list <080-breaking-changes>`.

Ideas para mejorar Solidity o esta misma documentación son siempre bienvenidas, lea nuestra :doc:`guía de contribución <contributing>` para más detalles.

.. Nota::

  You can download this documentation as PDF, HTML or Epub
  by clicking on the versions flyout menu in the bottom-right corner and selecting the preferred download format.

Para Comenzar
-------------

**1. Comprender los Conceptos Básicos de los Contratos Inteligentes**

Si usted es nuevo y todavía no está familiarizado con el concepto de los contratos inteligentes, le recomendamos iniciar con la sección "Introducción a los Contratos Inteligentes", que cubre:

If you are new to the concept of smart contracts, we recommend you to get started by digging into the "Introduction to Smart Contracts" section, which covers the following:

**2. Conozca Solidity**

Una vez que esté relacionado con los conceptos básicos, le recomendamos leer las secciones de :doc:`"Solidity con Ejemplos" <solidity-by-example>` y "Descripción del Lenguaje" para comprender los conceptos fundamentales del lenguaje.

**3. Instalar el Compilador de Solidity**

Hay distintas maneras de instalar el compilador de Solidity, simplemente elija su opción preferida y siga los pasos indicados en la :ref:`página de instalación <installing-solidity>`.

.. Nota::

.. hint::
  You can try out code examples directly in your browser with the
  `Remix IDE <https://remix.ethereum.org>`_.
  Remix is a web browser-based IDE that allows you to write, deploy and administer Solidity smart contracts,
  without the need to install Solidity locally.

.. warning::
    As humans write software, it can have bugs.
    Therefore, you should follow established software development best practices when writing your smart contracts.
    This includes code review, testing, audits, and correctness proofs.
    Smart contract users are sometimes more confident with code than their authors,
    and blockchains and smart contracts have their own unique issues to watch out for,
    so before working on production code, make sure you read the :ref:`security_considerations` section.

    Ya que el software está escrito por humanos, puede contener errores.
    Usted debe seguir e implementar las mejores prácticas de desarrollo de software establecidas al escribir sus contratos inteligentes.
    Esto incluye la revisión, pruebas, auditorías y la correcta validez del código.
    Algunas veces los usuarios de los contratos inteligentes tienen más confianza el el código que sus mismos autores; ya que las cadenas de bloques y los contratos inteligentes tienes sus respectivos problemas, se recomienda que lea la sección :ref:`security_considerations` antes de trabajar en el código de producción.

If you want to learn more about building decentralized applications on Ethereum,
the `Ethereum Developer Resources <https://ethereum.org/en/developers/>`_ can help you with further general documentation around Ethereum,
and a wide selection of tutorials, tools, and development frameworks.

If you have any questions, you can try searching for answers or asking on the
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_,
or our `Gitter channel <https://gitter.im/ethereum/solidity>`_.

.. _translations:

Traducciones
------------

Community contributors help translate this documentation into several languages.
Note that they have varying degrees of completeness and up-to-dateness.
The English version stands as a reference.

<<<<<<< HEAD
Puede elegir entre distintos idiomas haciendo click en el menú desplegable que se encuentra en la esquina inferior izquierda y seleccionando su lenguaje preferido.

* `Chino <https://docs.soliditylang.org/zh/latest/>`_
* `Francés <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesio <https://github.com/solidity-docs/id-indonesian>`_
* `Japonés <https://github.com/solidity-docs/ja-japanese>`_
* `Coreano <https://github.com/solidity-docs/ko-korean>`_
* `Persa <https://github.com/solidity-docs/fa-persian>`_
* `Ruso <https://github.com/solidity-docs/ru-russian>`_
* `Español <https://github.com/solidity-docs/es-spanish>`_
* `Turco <https://github.com/solidity-docs/tr-turkish>`_
* `Alemán <https://github.com/solidity-docs/de-german>`_
* `Portugués <https://github.com/solidity-docs/pt-portuguese>`_
=======
You can switch between languages by clicking on the flyout menu in the bottom-right corner
and selecting the preferred language.

* `Chinese <https://docs.soliditylang.org/zh-cn/latest/>`_
* `French <https://docs.soliditylang.org/fr/latest/>`_
* `Indonesian <https://github.com/solidity-docs/id-indonesian>`_
* `Japanese <https://github.com/solidity-docs/ja-japanese>`_
* `Korean <https://github.com/solidity-docs/ko-korean>`_
* `Persian <https://github.com/solidity-docs/fa-persian>`_
* `Russian <https://github.com/solidity-docs/ru-russian>`_
* `Spanish <https://github.com/solidity-docs/es-spanish>`_
* `Turkish <https://docs.soliditylang.org/tr/latest/>`_
>>>>>>> english/develop

.. Note::
  Recientemente se creó una nueva organización en GitHub y un flujo de trabajo para las traducciones, con el motivo de agilizar los esfuerzos de la     comunidad. Por favor, consulte la `guía de traducción <https://github.com/solidity-docs/translation-guide>`_ para obtener información sobre cómo iniciar un nuevo idioma o contribuir en las traducciones de la comunidad.
  Hemos establecido una organización de Github y flujo de trabajo de traducción para ayudar a optimizar los esfuerzos de la comunidad. Consulte la guīa de traducción en `solidity-docs org <https://github.com/solidity-docs>`_ para obtener información sobre cómo iniciar una nuevo idioma o contribuir a la traducciones de la comunidad.

   We set up a GitHub organization and translation workflow to help streamline the community efforts.
   Please refer to the translation guide in the `solidity-docs org <https://github.com/solidity-docs>`_
   for information on how to start a new language or contribute to the community translations.

:ref:`Índice de palabras clave <genindex>`, :ref:`Página de búsqueda <search>`

.. toctree::
   :maxdepth: 2
   :caption: Conceptos Básicos

   introduction-to-smart-contracts.rst
   solidity-by-example.rst
   installing-solidity.rst

.. toctree::
   :maxdepth: 2
   :caption: Descripción del Lenguaje

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
   :caption: Compilador

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Componentes Internos

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
   :caption: Advisory content

   security-considerations.rst
   bugs.rst
   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Additional Material

   natspec-format.rst
   smtchecker.rst
   yul.rst
   path-resolution.rst

.. toctree::
   :maxdepth: 2
   :caption: Resources

   style-guide.rst
   common-patterns.rst
   resources.rst
   contributing.rst
   language-influences.rst
   brand-guide.rst
