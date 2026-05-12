//
//  CertificationModels.swift
//  Nubi
//
//  Micro-certificaciones de Soft Skills con módulos y tests
//

import SwiftUI

// MARK: - Modelo de Certificación
struct Certification: Identifiable {
    let id              = UUID()
    let title           : String
    let subtitle        : String
    let sfSymbol        : String
    let accentColor     : Color
    let estimatedTime   : String   // "20 min total"
    let modules         : [CertModule]
}

// MARK: - Módulo dentro de la certificación
struct CertModule: Identifiable {
    let id          = UUID()
    let number      : Int
    let title       : String
    let summary     : String
    let sfSymbol    : String
    let readTime    : String       // "4 min"
    let content     : String
    let keyTakeaway : String       // resumen visual al final
    let quiz        : QuizQuestion // 1 pregunta por módulo
}

// MARK: - Pregunta del Test
struct QuizQuestion: Identifiable {
    let id              = UUID()
    let question        : String
    let options         : [String]
    let correctIndex    : Int
    let explanation     : String  // mostrada después de responder
}

// MARK: ════════════════════════════════════════════════════
// CERTIFICACIÓN 1: COMUNICACIÓN ASERTIVA
// ════════════════════════════════════════════════════════

let certComunicacionAsertiva = Certification(
    title: "Comunicación\nAsertiva",
    subtitle: "Aprende a expresarte sin atacar ni callarte",
    sfSymbol: "bubble.left.and.bubble.right.fill",
    accentColor: Color(hex: "#5C7B99"),
    estimatedTime: "25 min total",
    modules: [
        CertModule(
            number: 1,
            title: "¿Qué es la asertividad?",
            summary: "Los 3 estilos de comunicación y por qué importa",
            sfSymbol: "questionmark.circle.fill",
            readTime: "4 min",
            content: """
            Existen tres estilos de comunicación que usamos todos los días, muchas veces sin darnos cuenta. Identificarlos es el primer paso para mejorar.

            ESTILO PASIVO: Te callas lo que sientes para no incomodar. Dices "sí" cuando quieres decir "no". A corto plazo evitas conflicto, a largo plazo acumulas resentimiento y agotamiento.

            ESTILO AGRESIVO: Expresas lo que piensas sin filtro, atacando o culpando al otro. Logras lo que quieres en el momento, pero rompes relaciones y generas miedo a tu alrededor.

            ESTILO ASERTIVO: Dices lo que piensas y sientes con respeto, sin atacar ni someterte. Es el equilibrio.

            EJEMPLO PRÁCTICO: Tu compañero te pide cubrir su turno por tercera vez en la semana.
            • Pasivo: "Está bien... no te preocupes" (mientras te frustras por dentro).
            • Agresivo: "¡Tú siempre te aprovechas! Resuélvelo solo."
            • Asertivo: "Entiendo que tienes una emergencia, pero ya cubrí dos turnos esta semana y necesito mi descanso. Esta vez no puedo."

            La asertividad no es ser frío ni calculador. Es respetarte a ti mismo tanto como respetas al otro.
            """,
            keyTakeaway: "Asertivo = Respeto a ti + Respeto al otro, al mismo tiempo.",
            quiz: QuizQuestion(
                question: "Tu jefe te pide quedarte 2 horas extra por quinta vez en la semana. ¿Cuál respuesta es ASERTIVA?",
                options: [
                    "Está bien, no hay problema (aunque ya estés agotado)",
                    "¡Esto es injusto! Siempre me toca a mí, búsquese a otro",
                    "Entiendo la urgencia, pero llevo 4 días con horas extra y necesito descansar. Hoy no puedo, mañana lo retomamos",
                    "No respondes y te vas sin decir nada"
                ],
                correctIndex: 2,
                explanation: "La opción 3 reconoce la situación del otro (entiendo la urgencia), expresa tu límite (necesito descansar) y ofrece una alternativa (mañana lo retomamos). Eso es asertividad pura."
            )
        ),
        CertModule(
            number: 2,
            title: "La fórmula DESC",
            summary: "Una estructura comprobada para conversaciones difíciles",
            sfSymbol: "list.number",
            readTime: "5 min",
            content: """
            La fórmula DESC es una herramienta usada en empresas como Google, Apple y Coppel para tener conversaciones difíciles sin que se conviertan en pelea. Tiene 4 pasos:

            D — DESCRIBE el hecho objetivo, sin juicios. Solo lo que pasó.
            "Cuando me asignaste 3 tareas extra ayer..."

            E — EXPRESA cómo te hizo sentir usando "yo me siento". Nunca "tú me hiciste sentir".
            "...me sentí abrumado y con poca claridad sobre las prioridades..."

            S — SUGIERE qué cambio te ayudaría. Sé concreto.
            "...me ayudaría que platiquemos al inicio del turno cuáles son las prioridades..."

            C — CONSECUENCIA positiva. Cierra con el beneficio mutuo.
            "...así puedo ser más eficiente y enfocarme en lo importante."

            Junto suena así, en una sola frase fluida:
            "Cuando me asignaste 3 tareas extra ayer, me sentí abrumado. Me ayudaría que platiquemos las prioridades al inicio del turno; así soy más eficiente y enfocada."

            Ejercicio mental: piensa en una situación real que te incomoda en el trabajo y arma tu DESC mental ahora mismo. La práctica mental es 80% del aprendizaje.
            """,
            keyTakeaway: "DESC: Describe → Expresa → Sugiere → Consecuencia. Cuatro pasos, conversación adulta.",
            quiz: QuizQuestion(
                question: "¿Cuál de estas frases sigue correctamente la fórmula DESC?",
                options: [
                    "Tú siempre llegas tarde y eso me hace ver mal a mí",
                    "Cuando llegaste 20 min tarde el lunes, me sentí preocupada porque tuve que cubrirte. Me ayudaría que me avises si vas a llegar tarde, así me organizo mejor",
                    "Por favor sé más puntual, gracias",
                    "Si vuelves a llegar tarde voy a hablar con el jefe"
                ],
                correctIndex: 1,
                explanation: "La opción 2 tiene los 4 elementos: Describe (llegaste 20 min tarde el lunes), Expresa (me sentí preocupada), Sugiere (avísame), Consecuencia (me organizo mejor). Las otras atacan, son vagas o amenazan."
            )
        ),
        CertModule(
            number: 3,
            title: "Decir NO sin culpa",
            summary: "El arte de poner límites sin romper relaciones",
            sfSymbol: "hand.raised.fill",
            readTime: "4 min",
            content: """
            El "no" más difícil de decir no es a un cliente o a un jefe. Es a alguien que te cae bien y no quieres decepcionar.

            La culpa por decir "no" viene de una creencia errónea: pensar que decir "no" a una petición es decir "no" a la persona. No es lo mismo. Puedes amar a alguien y aún así no poder ayudarle hoy.

            TÉCNICA DEL SÁNDWICH:
            Capa 1 — Reconoce: "Veo que es importante para ti..."
            Capa 2 — Negativa clara: "...pero hoy no puedo ayudarte con eso..."
            Capa 3 — Alternativa o cierre cálido: "...¿podemos verlo mañana?" o "espero lo resuelvas pronto."

            FRASES PODEROSAS PARA TENER LISTAS:
            • "Déjame revisar mi día y te confirmo en 10 minutos." (te da espacio para decidir)
            • "Hoy no me da la energía para eso, pero gracias por pensar en mí."
            • "Esa no es mi prioridad esta semana."
            • "Prefiero hacer una cosa bien que tres a medias."

            REGLA DE ORO: No expliques de más. Cuanto más justifiques tu "no", más débil suena. Una explicación corta es suficiente. No le debes a nadie un ensayo justificando tu límite.

            Recuerda: cada "no" a algo que no quieres es un "sí" a algo que sí importa: tu salud, tu familia, tu paz mental.
            """,
            keyTakeaway: "Decir 'no' a una petición no es decir 'no' a la persona. Y no requiere ensayo.",
            quiz: QuizQuestion(
                question: "Una compañera te pide ayuda con su reporte 30 min antes de salir, y tú ya tienes plan para llegar a casa. ¿Mejor respuesta?",
                options: [
                    "Está bien, te ayudo (cancelas tu plan y llegas tarde a casa)",
                    "No tengo tiempo, búscate la vida",
                    "Entiendo que te urge, hoy no puedo porque tengo un compromiso. ¿Te sirve si mañana llego 15 min antes y lo vemos?",
                    "Mira, es que mi mamá me pidió llegar temprano y luego tengo que pasar al super y luego..."
                ],
                correctIndex: 2,
                explanation: "La opción 3 valida (entiendo que te urge), dice no claramente (hoy no puedo), explica brevemente (tengo un compromiso) y ofrece alternativa (mañana llego 15 min antes). Sin culpa, sin ensayo justificativo."
            )
        ),
        CertModule(
            number: 4,
            title: "Manejar la crítica",
            summary: "Cómo recibir feedback sin ponerte a la defensiva",
            sfSymbol: "ear.fill",
            readTime: "4 min",
            content: """
            Recibir una crítica activa la misma zona del cerebro que sentir dolor físico. Por eso nuestra primera reacción es defendernos. Pero esa reacción te impide aprender.

            EL TRUCO DE LOS 3 SEGUNDOS:
            Cuando alguien te dé una crítica, antes de responder, cuenta hasta 3 mentalmente. En esos 3 segundos pasan tres cosas valiosas: tu amígdala se calma, tu córtex prefrontal se activa, y la otra persona percibe que estás escuchando.

            FILTRA LA CRÍTICA EN 2 PASOS:

            Paso 1 — ¿Tiene algo de verdad?
            Aunque sea solo el 10% de lo que te dijeron. Quédate con eso. Tira el resto.

            Paso 2 — ¿Quién lo dice?
            Si es alguien que te conoce, te valora y quiere lo mejor para ti, presta atención. Si es alguien que critica todo y a todos, la crítica habla más de esa persona que de ti.

            FRASES QUE DESARMAN UNA CRÍTICA HOSTIL:
            • "Gracias por decírmelo, voy a pensarlo." (le quita el oxígeno al ataque)
            • "Tienes parte de razón. Lo que voy a hacer diferente es..."
            • "Entiendo tu punto. ¿Me puedes dar un ejemplo concreto?" (transforma vaguedad en información útil)

            UNA REGLA QUE CAMBIA TODO: Las críticas no te definen. Tu reacción a las críticas, sí.

            Una persona asertiva agradece el feedback útil y deja pasar el dañino, sin contraatacar. Esa madurez es lo que separa a los profesionales de los empleados.
            """,
            keyTakeaway: "3 segundos de pausa + filtra el 10% útil + agradece sin defenderte = madurez profesional.",
            quiz: QuizQuestion(
                question: "Tu jefe te dice frente a otros: 'Tu reporte estuvo flojo'. ¿Mejor respuesta asertiva?",
                options: [
                    "¡Pero si me dijiste que estaba bien la semana pasada!",
                    "Sí, lo siento mucho, soy un desastre, lo voy a rehacer",
                    "Gracias por el feedback. ¿Podemos ver juntos qué parte específica fortalecer? Me interesa mejorarlo",
                    "Bueno, si no le gustó, hágalo usted"
                ],
                correctIndex: 2,
                explanation: "La opción 3 agradece, pide especificidad (transformando vaguedad en info útil) y muestra disposición a mejorar. No se pone a la defensiva, no se humilla y no contraataca. Eso es asertividad profesional."
            )
        ),
        CertModule(
            number: 5,
            title: "Asertividad bajo presión",
            summary: "Cuando todo arde y necesitas mantener la cabeza fría",
            sfSymbol: "flame.fill",
            readTime: "4 min",
            content: """
            Ser asertivo es fácil cuando estás tranquilo. El verdadero examen es cuando un cliente te grita, tu jefe te presiona o tu compañero te traiciona.

            REGLA DE LA VOZ INVERSA:
            Cuando el otro sube la voz, tú la bajas. Cuando el otro habla rápido, tú hablas despacio. Cuando el otro se acalora, tú respiras. Esto no es debilidad: es una técnica usada por negociadores del FBI. Obliga al otro a igualar tu ritmo, no al revés.

            EL ESCUDO DE 4 PALABRAS:
            Cuando alguien te ataca con palabras, ten lista esta frase neutra: "Entiendo lo que dices."

            No es darle la razón. Es decirle "te escuché". Eso baja el nivel emocional al instante. Después puedes responder de fondo.

            CUANDO NO TIENES ENERGÍA PARA SER ASERTIVO:
            Hay días que estás tan agotado que cualquier conversación difícil te puede sacar de balance. Está bien. Una respuesta asertiva válida es: "Esto es importante. Necesito 10 minutos para procesarlo y te respondo bien."

            Pedir tiempo no es huir. Es responsabilidad emocional.

            EJEMPLO REAL DE PISO DE VENTA:
            Cliente: "¡Esto es una porquería de servicio, llevo 20 minutos esperando!"
            Tú (voz baja, ritmo lento): "Entiendo lo que dice, llevar 20 minutos esperando es realmente frustrante. Déjeme ver exactamente qué puedo hacer por usted en este momento..."

            En menos de 30 segundos bajaste la temperatura emocional y recuperaste el control.

            Felicidades: completar este módulo significa que ya tienes una caja de herramientas profesional para cualquier conversación difícil.
            """,
            keyTakeaway: "Voz inversa + 'Entiendo lo que dices' + permiso para pedir tiempo = control bajo presión.",
            quiz: QuizQuestion(
                question: "Un cliente te grita en plena hora pico que eres un inútil. ¿Mejor primera respuesta?",
                options: [
                    "(Levantando la voz) ¡A mí no me grita, soy un profesional!",
                    "(Voz baja, calmada) Entiendo lo que me dice. Veo que la situación lo tiene muy frustrado, ¿qué pasó exactamente?",
                    "Lo siento mucho, perdón, soy nuevo, perdone",
                    "(Le das la espalda y te vas)"
                ],
                correctIndex: 1,
                explanation: "La opción 2 aplica la voz inversa (calmada) + el escudo ('entiendo lo que me dice') + abre espacio para que el cliente baje la energía y dé información útil. Es la técnica que usan los profesionales de servicio al cliente."
            )
        ),
    ]
)

// MARK: ════════════════════════════════════════════════════
// CERTIFICACIÓN 2: INTELIGENCIA EMOCIONAL
// ════════════════════════════════════════════════════════

let certInteligenciaEmocional = Certification(
    title: "Inteligencia\nEmocional",
    subtitle: "Domina tus emociones antes de que ellas te dominen",
    sfSymbol: "brain.head.profile",
    accentColor: Color(hex: "#9B8EC4"),
    estimatedTime: "22 min total",
    modules: [
        CertModule(
            number: 1,
            title: "Los 4 pilares de la IE",
            summary: "El mapa básico que cambia tu vida",
            sfSymbol: "square.grid.2x2.fill",
            readTime: "4 min",
            content: """
            Daniel Goleman, el psicólogo que popularizó el término, identificó 4 pilares de la inteligencia emocional. Conocerlos te da un mapa para entender qué pilar trabajar primero.

            PILAR 1 — AUTOCONCIENCIA:
            Saber qué estás sintiendo en el momento. Suena obvio, pero la mayoría no lo hace. Decimos "estoy bien" cuando en realidad estamos ansiosos, agotados o enojados, sin nombrarlo. Este pilar es la base de todo lo demás.

            PILAR 2 — AUTOGESTIÓN:
            Una vez que reconoces lo que sientes, ¿qué haces con eso? La autogestión no es suprimir las emociones (eso enferma). Es elegir cómo responder a ellas, en vez de dejarte llevar.

            PILAR 3 — CONCIENCIA SOCIAL (EMPATÍA):
            Leer las emociones de los demás, incluso cuando no las dicen con palabras. Notar cuándo tu compañero está agobiado aunque sonría. Detectar cuándo un cliente está estresado por algo que no es tu producto.

            PILAR 4 — GESTIÓN DE RELACIONES:
            Usar lo anterior para construir vínculos sanos: dar feedback sin herir, resolver conflictos, inspirar a otros, manejar grupos. Es el pilar más visible y por el que la gente reconoce a un líder emocional.

            DATO QUE MOTIVA: Estudios de Harvard Business Review encontraron que en puestos de servicio (como los de Coppel), la inteligencia emocional predice el éxito profesional 4 veces mejor que el coeficiente intelectual o la experiencia técnica.

            Tu IE no es fija. Es una habilidad que se entrena, igual que un músculo.
            """,
            keyTakeaway: "Autoconciencia → Autogestión → Empatía → Relaciones. Cuatro pilares, una sola torre.",
            quiz: QuizQuestion(
                question: "¿Cuál de estos comportamientos muestra MAYOR inteligencia emocional?",
                options: [
                    "Nunca enojarte, siempre estar de buenas",
                    "Notar que estás molesto, identificar por qué, y elegir cómo responder",
                    "Esconder lo que sientes para no incomodar a nadie",
                    "Decir todo lo que piensas sin filtros, eso es ser auténtico"
                ],
                correctIndex: 1,
                explanation: "La inteligencia emocional NO es la ausencia de emociones difíciles. Es la capacidad de reconocerlas (autoconciencia) y manejarlas con propósito (autogestión). Las opciones 1 y 3 reprimen, la 4 explota. La 2 es IE pura."
            )
        ),
        CertModule(
            number: 2,
            title: "Nombrar para domar",
            summary: "El truco neurológico para reducir el estrés en 30 segundos",
            sfSymbol: "tag.fill",
            readTime: "4 min",
            content: """
            El neurocientífico Matthew Lieberman descubrió algo fascinante: cuando le pones nombre específico a una emoción que sientes, la actividad de tu amígdala (la zona del cerebro que dispara el estrés) baja de inmediato, mientras que tu córtex prefrontal (la zona racional) se activa.

            En palabras simples: nombrar = domar.

            Pero hay un truco. Tienes que ser específico.

            DECIR "ME SIENTO MAL" no funciona. Es demasiado vago. Tu cerebro no sabe qué hacer con esa información.

            DECIR "ME SIENTO FRUSTRADO PORQUE LLEVO 3 DÍAS SIN VER A MIS HIJOS" sí funciona. El cerebro recibe un dato concreto y baja el nivel de alarma.

            EL VOCABULARIO EMOCIONAL ES UNA SUPERPOTENCIA:
            La mayoría de la gente usa solo 5-7 palabras emocionales (feliz, triste, enojado, cansado, bien). Las personas con alta IE manejan 20+ matices.

            EJEMPLOS DE ESPECIFICIDAD:
            • En vez de "enojado": frustrado, irritado, indignado, resentido, traicionado
            • En vez de "triste": melancólico, decepcionado, desolado, nostálgico, vacío
            • En vez de "ansioso": preocupado, abrumado, intranquilo, sobrepasado, en alerta
            • En vez de "cansado": agotado, drenado, hastiado, desbordado, sin batería

            EJERCICIO DE 30 SEGUNDOS — HAZLO AHORA:
            Cierra los ojos. Pregúntate: "¿Qué siento en este momento, exactamente?" No te conformes con la primera palabra que te venga. Busca la segunda, la tercera. La emoción real suele estar dos capas abajo.

            La gente que practica esto diariamente reporta menos ansiedad, mejor sueño y menos conflictos en 2 semanas.
            """,
            keyTakeaway: "Específico vence a vago. 'Frustrado por X' baja el estrés. 'Mal' lo amplifica.",
            quiz: QuizQuestion(
                question: "Después de un turno difícil, ¿cuál descripción muestra mejor IE?",
                options: [
                    "Estoy mal",
                    "Estoy de la chingada",
                    "Estoy agotada y un poco frustrada porque dos clientes me trataron mal y no pude defenderme",
                    "No sé qué tengo"
                ],
                correctIndex: 2,
                explanation: "La opción 3 es específica: nombra el cansancio, identifica la frustración, ubica la causa concreta y reconoce su propia respuesta. Esa precisión es lo que activa tu córtex prefrontal y baja el estrés. Las otras son vagas y no ayudan al cerebro a procesar."
            )
        ),
        CertModule(
            number: 3,
            title: "La pausa de 6 segundos",
            summary: "El secreto de quienes nunca explotan en el trabajo",
            sfSymbol: "timer",
            readTime: "3 min",
            content: """
            Cuando algo te detona emocionalmente —un cliente te grita, recibes un mensaje injusto del jefe, un compañero te culpa de algo que no hiciste— pasa lo siguiente en tu cerebro:

            Segundo 0: tus sentidos captan el estímulo.
            Segundo 1-2: tu amígdala dispara una respuesta de pelea o huida. Es automática.
            Segundo 3-4: las hormonas del estrés (cortisol, adrenalina) ya están en tu sangre.
            Segundo 5-6: tu córtex prefrontal (la parte racional) finalmente se activa y puede tomar el control.

            Por eso se dice que "primero reacciona el cuerpo, después la mente."

            LA PAUSA DE 6 SEGUNDOS:
            Es exactamente el tiempo que tu cerebro racional necesita para "encenderse" después de un detonante emocional. Si respondes antes de esos 6 segundos, estás siendo gobernado por tu amígdala primitiva. Si esperas, tu yo adulto puede responder.

            CÓMO HACERLA EN LA PRÁCTICA:

            1. Cuando sientas el detonante (calor en la cara, el corazón acelerado, el impulso de hablar fuerte), reconócelo.

            2. Cierra la boca durante 6 segundos. Literalmente.

            3. Durante esos 6 segundos: respira hondo una vez. Suelta los hombros. Mueve los dedos de los pies dentro de los zapatos (te conecta con el cuerpo y saca de la cabeza).

            4. Después de los 6 segundos, tu respuesta será 10 veces mejor.

            HISTORIA REAL: Un supervisor de Coppel cuenta que adoptó esta técnica después de casi perder su empleo por gritarle a un cliente. Ahora la usa cada vez que detecta el calor en el cuerpo. "No me ha vuelto a pasar nada parecido en 4 años. Antes era el clásico explosivo que se arrepentía. Hoy soy el que mantiene la calma."

            6 segundos. Cuesta nada. Cambia todo.
            """,
            keyTakeaway: "6 segundos de silencio = la diferencia entre ser víctima de tu amígdala o dueño de tu respuesta.",
            quiz: QuizQuestion(
                question: "Un cliente te insulta. Sientes que la sangre te sube a la cabeza. ¿Qué hacer?",
                options: [
                    "Responder de inmediato para que vea que no te dejas",
                    "Cerrar la boca 6 segundos, respirar, sentir tus pies en el piso, y después responder con calma",
                    "Llorar para que vea lo que provoca",
                    "Salir corriendo para no decir algo de lo que te arrepientas"
                ],
                correctIndex: 1,
                explanation: "La opción 2 es la pausa de 6 segundos en acción. Esos segundos permiten que tu córtex prefrontal recupere el control y respondas como adulto, no como amígdala reactiva. Las otras opciones son reactivas (1), exageradas (3) o evasivas (4)."
            )
        ),
        CertModule(
            number: 4,
            title: "Empatía táctica",
            summary: "Leer al otro sin que te diga una palabra",
            sfSymbol: "eye.fill",
            readTime: "4 min",
            content: """
            La empatía no es solo "ponerte en los zapatos del otro". Eso es la versión simplista. La empatía táctica es leer las señales no verbales de otra persona y responder a ellas estratégicamente.

            En el trabajo de servicio, esto es oro puro.

            LAS 5 SEÑALES NO VERBALES MÁS IMPORTANTES:

            1. POSTURA DE HOMBROS: Hombros encogidos = ansiedad o miedo. Hombros echados atrás con pecho abierto = confianza o agresión.

            2. CONTACTO VISUAL: Evita los ojos = vergüenza, miente, o se siente intimidado. Sostiene mirada fija = enojado o muy seguro.

            3. RITMO DE HABLA: Habla rápido = ansioso, urgente, emocionado. Habla muy despacio = cansado, deprimido, o calculador.

            4. MANOS: Manos visibles y abiertas = honestidad, calma. Manos en bolsillos o tras la espalda = nerviosismo, deseo de esconder algo.

            5. RESPIRACIÓN: Pecho que sube y baja rápido = activación del sistema simpático (estrés). Respiración suave y profunda = calma.

            EJERCICIO DEL DETECTIVE:
            En tu próximo turno, observa a 3 personas (cliente, compañero, jefe) sin que se den cuenta. ¿Qué señales lees? ¿Qué emoción detectas detrás de las palabras?

            CÓMO USAR LA EMPATÍA TÁCTICA EN TIEMPO REAL:

            Si detectas a un cliente con hombros encogidos y voz baja: probablemente está cansado o intimidado. Bájale al ritmo, sé extra paciente.

            Si detectas a un compañero con respiración rápida y mirada perdida: está al borde. No es buen momento para pedirle algo. Mejor pregúntale si está bien.

            Si detectas a tu jefe con mandíbula apretada y movimientos cortos: viene de algo malo. No lleves un problema en ese momento. Espera a que se relaje.

            La empatía táctica no es manipulación. Es respeto: ajustar tu manera de tratar al otro a lo que necesita en ese momento.
            """,
            keyTakeaway: "Las palabras dicen el 30%. El cuerpo dice el 70%. Aprende a leer el 70%.",
            quiz: QuizQuestion(
                question: "Tu compañera está sentada con la cabeza baja, hombros encogidos y respira corto. Le hablas y dice 'estoy bien' pero no te mira. ¿Qué hacer?",
                options: [
                    "Creerle y seguir con tu día",
                    "Insistir 5 veces hasta que confiese",
                    "Decir 'okay, te creo, pero si quieres platicar luego, aquí estoy' y darle espacio",
                    "Avisarle al supervisor que está rara"
                ],
                correctIndex: 2,
                explanation: "La opción 3 reconoce las señales no verbales (que claramente dicen 'no estoy bien') sin invadir, abre la puerta sin presionar, y respeta su autonomía. Empatía táctica = ver lo que no se dice + respetar el tiempo del otro."
            )
        ),
    ]
)

// MARK: - All certifications
let allCertifications: [Certification] = [
    certComunicacionAsertiva,
    certInteligenciaEmocional,
]
