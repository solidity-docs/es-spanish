###############
Patrones comunes
###############

.. index:: withdrawal

.. _withdrawal_pattern:

*************************
Retiros desde Contratos
*************************

El método recomendado al enviar fondos luego de un efecto
es usar el patrón de retiros. Aunque el método más intuitivo
de enviar Ether, como resultado de un efecto, es una llamada
directa a ``transfer``, esto no se recomienda ya que introduce
un riesgo potencial de seguridad. Podría leer más sobre esto
en la página :ref:`consideraciones_de_seguridad`.

<<<<<<< HEAD
El siguiente ejemplo es un patrón de retiros en práctica en
un contrato donde el objetivo es enviar la mayor cantidad de 
dinero al contrato a fin de llegar a ser "el más rico",
inspirado por `King of the Ether <https://www.kingoftheether.com/>`_.
=======
The following is an example of the withdrawal pattern in practice in
a contract where the goal is to send the most of some compensation, e.g. Ether, to the
contract in order to become the "richest", inspired by
`King of the Ether <https://www.kingoftheether.com/>`_.
>>>>>>> english/develop

En el siguiente contrato, si usted ya no es el más rico, recibe
los fondos de la persona que ahora es la más rica.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract WithdrawalContract {
        address public richest;
        uint public mostSent;

        mapping(address => uint) pendingWithdrawals;

        /// La cantidad enviada de Ether no fue más alta que
        /// la cantidad actualmente más alta.
        error NotEnoughEther();

        constructor() payable {
            richest = msg.sender;
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            pendingWithdrawals[richest] += msg.value;
            richest = msg.sender;
            mostSent = msg.value;
        }

        function withdraw() public {
            uint amount = pendingWithdrawals[msg.sender];
<<<<<<< HEAD
            // Recuerde poner a cero la devolución pendiente antes de 
            // enviar para prevenir ataques de reentrada.
=======
            // Remember to zero the pending refund before
            // sending to prevent reentrancy attacks
>>>>>>> english/develop
            pendingWithdrawals[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

Patrón de envío:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract SendContract {
        address payable public richest;
        uint public mostSent;

        /// La cantidad enviada de Ether no fue más alta que
        /// la cantidad actualmente más alta.
        error NotEnoughEther();

        constructor() payable {
            richest = payable(msg.sender);
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            // Esta línea puede causar problemas (explicado más abajo).
            richest.transfer(msg.value);
            richest = payable(msg.sender);
            mostSent = msg.value;
        }
    }

Nótese que, en este ejemplo, un atacante podría atrapar
al contrato hacia un estado inservible al causar que ``richest``
sea la dirección de un contrato que tiene una función receive o fallback
el cual falla (e.g. al usar ``revert()`` o por solo consumir más de 2300 
estipendio de gas transferido a ello). De esa manera, cuando se llame
``transfer`` para entregar los fondos al contrato "envenenado", fallará
y así también fallará ``becomeRichest``, con el contrato quedando estancado
para siempre.

En contraste, si usted usa el patrón de retiros del primer ejemplo, el
atacante solo puede causar que falle su propio retiro y no el resto del
funcionamiento del contrato.

.. index:: access;restricting

******************
Restricción de Acceso
******************

Restricción de acceso es un patrón muy común en contratos.
Note que usted no puede nunca restringir a ningún humano o 
computadora de leer el contenido de sus transacciones o el
estado del contrato. Lo puede hacer un poco más complicado
al usar encriptación, pero si se supone que su contrato lea
datos, entonces todos podrán tambié̀n hacerlo.

usted puede restringir el acceso a lectura del estado de su
contrato por **otros contratos**. De hecho, ese es el valor
por defecto a menos que usted declare sus variables de estado
``public``.

Además, puede restringir quién puede hacer modificaciones
al estado de sus contratos o llamar a las funciones de su
contrato y esto es de lo que se trata esta sección. 

.. index:: function;modifier

El uso de **modificadores de funciones** hacen a estas
restricciones sumamente legibles.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract AccessRestriction {
        // Estos serán asignados en la fase de
        // construcción, donde `msg.sender` es la cuenta
        // que crea este contrato.
        address public owner = msg.sender;
        uint public creationTime = block.timestamp;

        // Ahora sigue una lista de errores que 
        // este contrato puede generar junto a
        // una explicación textual en
        // comentarios especiales.

        /// Remitente no autorizado para esta
        /// operación.
        error Unauthorized();

        /// Función invocada muy temprano.
        error TooEarly();

        /// No se envió suficiente Ether con la llamada a la función.
        error NotEnoughEther();

        // Modificadores pueden usarse para cambiar
        // el cuerpo de una función.
        // Si este modificador es usado, 
        // antepondrá una verificación que solo pasa
        // si la función se invoca desde 
        // una cierta dirección.
        modifier onlyBy(address account)
        {
            if (msg.sender != account)
                revert Unauthorized();
            // ¡No olvide el "_;"! 
            // Se reemplazará por el cuerpo de la función actual
            // cuando se use el modificador.
            _;
        }

        /// Convierte a `newOwner` al nuevo  dueño
        /// de este contrato.
        function changeOwner(address newOwner)
            public
            onlyBy(owner)
        {
            owner = newOwner;
        }

        modifier onlyAfter(uint time) {
            if (block.timestamp < time)
                revert TooEarly();
            _;
        }

        /// Borra información de propiedad.
        /// Solo puede ser llamado 6 semanas después
        /// de que se creó el contrato.
        function disown()
            public
            onlyBy(owner)
            onlyAfter(creationTime + 6 weeks)
        {
            delete owner;
        }

        // Este modificador requiere un cierto pago
        // asociado con la llamada a la función.
        // Si quien invoca la función envió demasiado, se le devuelve el dinero,
        // pero solo después del cuerpo de la función.
        // Esto era peligroso antes de Solidity 0.4.0,
        //  donde era posible saltarse la parte después de `_;`.
        modifier costs(uint amount) {
            if (msg.value < amount)
                revert NotEnoughEther();

            _;
            if (msg.value > amount)
                payable(msg.sender).transfer(msg.value - amount);
        }

        function forceOwnerChange(address newOwner)
            public
            payable
            costs(200 ether)
        {
            owner = newOwner;
            // solo un ejemplo de condición
            if (uint160(owner) & 0 == 1)
                // Esto no devolvía el dinero en Solidity 
                // antes de la versiñon 0.4.0.
                return;
            // pago de más devuelto
        }
    }

Una manera más especializada en la cual se puede restringir 
el acceso a llamadas de funciones será discutida en el siguiente ejemplo.

.. index:: state machine

*************
Máquina de Estado
*************

Los contratos a menudo actúan como una máquina de estado, lo cual
significa que tienen ciertas **etapas** en las cuales se comportan
diferentes o en la cual funciones diferentes pueden ser llamadas.
Una llamada a una función a menudo finaliza una etapa y transiciona
el contrato a una nueva etapa (especialmente si el contrato modela
**interacción**). También es común que algunas etapas se alcancen
automáticamente en un cierto punto en el **tiempo**.

Un ejemplo de esto es un contrato de subasta a ciegas el cual 
comienza en la etapa de "aceptación de ofertas a ciegas", 
luego transiciona a "revelación de ofertas" lo cual termina con la 
"determinación del resultado de la subasta".

.. index:: function;modifier

Los modificadores de funciones se pueden usar en esta situación
para modelar los estados y proteger de un uso incorrecto del contrato.

Ejemplo
=======

En el siguiente ejemplo, el modificador ``atStage`` asegura que la
función solo puede ser invocada en un escenario en particular.

Las transiciones automáticas planeadas son manejadas por el modificador
``timedTransitions``, el cual debería ser usado para todas las funciones.

.. note::
    **El orden del modificador importa**.
    Si se combina atStage con timedTransitions,
    asegúrese que lo menciona luego del último,
    de modo que se tome en cuenta el nuevo escenario.

Finalmente, el modificador ``transitionNext`` se puede usar
para ir automáticamente al próximo escenario cuando termina
la función.

.. note::
    **El modificador puede ser saltado**.
    Esto solo aplica a Solidity antes de la versión 0.4.0:
    Ya que los modificadores se aplican al simplemente 
    reemplazar código y noal usar una llamada a una función,
    el código en el modificador transitionNext puede ser 
    saltado si la misma función usa return. Si quiere hacer
    esto, asegúrese llamar a nextStage manualmente desde esas
    funciones. A partir de la versión 0.4.0, el código del 
    modificador se jecutará incluso si la función retorna
    explícitamente.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract StateMachine {
        enum Stages {
            AcceptingBlindedBids,
            RevealBids,
            AnotherStage,
            AreWeDoneYet,
            Finished
        }
        /// La función no puede ser llamada en este momento.
        error FunctionInvalidAtThisStage();

        // Este es el escenario actual.
        Stages public stage = Stages.AcceptingBlindedBids;

        uint public creationTime = block.timestamp;

        modifier atStage(Stages stage_) {
            if (stage != stage_)
                revert FunctionInvalidAtThisStage();
            _;
        }

        function nextStage() internal {
            stage = Stages(uint(stage) + 1);
        }

        // Lleva a cabo transiciones programadas. Asegúrese de mencionar 
        // primero este modificador, de lo contrario los guardas
        // no tomarán en cuenta el nuevo escenario.
        modifier timedTransitions() {
            if (stage == Stages.AcceptingBlindedBids &&
                        block.timestamp >= creationTime + 10 days)
                nextStage();
            if (stage == Stages.RevealBids &&
                    block.timestamp >= creationTime + 12 days)
                nextStage();
            // Los otros escenarios transicionan por transacción
            _;
        }

        // ¡El orden de los modificadores import aquí!
        function bid()
            public
            payable
            timedTransitions
            atStage(Stages.AcceptingBlindedBids)
        {
            // No implementaremos eso aquí
        }

        function reveal()
            public
            timedTransitions
            atStage(Stages.RevealBids)
        {
        }

        // Este modificador va al nuevo escenario
        // luego de que termine la función.
        modifier transitionNext()
        {
            _;
            nextStage();
        }

        function g()
            public
            timedTransitions
            atStage(Stages.AnotherStage)
            transitionNext
        {
        }

        function h()
            public
            timedTransitions
            atStage(Stages.AreWeDoneYet)
            transitionNext
        {
        }

        function i()
            public
            timedTransitions
            atStage(Stages.Finished)
        {
        }
    }
