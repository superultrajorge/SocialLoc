import Foundation

/// Contenido incluido en la app (funciona sin internet).
enum Catalog {
    // MARK: - Menús

    static let menus: [DinnerMenu] = [
        DinnerMenu(id: "burger", name: "Hamburguesas caseras con cheddar, bacon y patatas gajo", emoji: "🍔", prepMinutes: 90,
                   tip: "Mete primero las patatas gajo al horno; las hamburguesas van al final.",
                   ingredients: ["Carne picada de ternera", "Pan de hamburguesa", "Cheddar en lonchas", "Bacon", "Patatas", "Lechuga, tomate y cebolla"], category: .comfort),
        DinnerMenu(id: "lasagna", name: "Lasaña boloñesa gratinada", emoji: "🍝", prepMinutes: 150,
                   tip: "El ragú necesita al menos 45 min a fuego lento antes de montar.",
                   ingredients: ["Placas de lasaña", "Carne picada mixta", "Tomate triturado", "Cebolla y zanahoria", "Bechamel", "Mozzarella y parmesano"], category: .italiana),
        DinnerMenu(id: "pizza-ham", name: "Pizza artesana de jamón, mozzarella y bacon", emoji: "🍕", prepMinutes: 240,
                   tip: "La masa tiene que levar unas 3 horas: amásala ya.",
                   ingredients: ["Harina de fuerza", "Levadura", "Tomate para pizza", "Jamón york", "Mozzarella", "Bacon"], category: .italiana),
        DinnerMenu(id: "ribs", name: "Costillas al horno con salsa barbacoa y patatas asadas", emoji: "🍖", prepMinutes: 210,
                   tip: "2 h tapadas con aluminio a fuego bajo y luego glaseadas con la barbacoa.",
                   ingredients: ["Costillar de cerdo", "Salsa barbacoa", "Pimentón y ajo en polvo", "Patatas", "Papel de aluminio"], category: .horno),
        DinnerMenu(id: "nachos", name: "Nachos gratinados con carne, cheddar y guacamole", emoji: "🌮", prepMinutes: 60,
                   tip: "Haz el guacamole al final para que no se oscurezca.",
                   ingredients: ["Totopos", "Carne picada", "Especias tex-mex", "Cheddar rallado", "Aguacates y lima", "Jalapeños"], category: .texmex),
        DinnerMenu(id: "cannelloni", name: "Canelones de carne con bechamel y queso gratinado", emoji: "🥘", prepMinutes: 150,
                   tip: "Prepara el relleno y la bechamel antes de hervir las placas.",
                   ingredients: ["Placas de canelones", "Carne picada", "Cebolla", "Bechamel", "Queso para gratinar"], category: .horno),
        DinnerMenu(id: "burritos", name: "Burritos de pollo con arroz, queso y salsa de yogur", emoji: "🌯", prepMinutes: 60,
                   tip: "Cuece el arroz mientras marinas el pollo.",
                   ingredients: ["Tortillas grandes", "Pechuga de pollo", "Arroz", "Queso rallado", "Yogur griego", "Pimiento y maíz"], category: .texmex),
        DinnerMenu(id: "sirloin", name: "Solomillo de cerdo con salsa de pimienta y patatas panaderas", emoji: "🥩", prepMinutes: 90,
                   tip: "Empieza las panaderas antes de sellar el solomillo.",
                   ingredients: ["Solomillo de cerdo", "Pimienta en grano", "Nata para cocinar", "Patatas", "Cebolla"], category: .horno),
        DinnerMenu(id: "pizza-ny", name: "Pizza estilo Nueva York de pepperoni y mozzarella", emoji: "🍕", prepMinutes: 240,
                   tip: "Masa con 3–4 h de levado; mejor aún si la haces la noche anterior.",
                   ingredients: ["Harina de fuerza", "Levadura", "Tomate para pizza", "Pepperoni", "Mozzarella", "Orégano"], category: .italiana),
        DinnerMenu(id: "hotdogs", name: "Perritos calientes con cebolla crujiente, cheddar y patatas fritas", emoji: "🌭", prepMinutes: 60,
                   tip: "Fríe las patatas al final para que lleguen crujientes.",
                   ingredients: ["Pan de perrito", "Salchichas", "Cebolla crujiente", "Salsa cheddar", "Patatas", "Kétchup y mostaza"], category: .rapida),
        DinnerMenu(id: "chicken", name: "Pollo asado con miel y mostaza y patatas crujientes", emoji: "🍗", prepMinutes: 120,
                   tip: "Riega el pollo con su jugo cada 20 minutos.",
                   ingredients: ["Pollo entero", "Miel", "Mostaza", "Patatas", "Ajo y romero"], category: .horno),
        DinnerMenu(id: "maccheese", name: "Macarrones con queso y tiras de pollo crujiente", emoji: "🧀", prepMinutes: 60,
                   tip: "Empana el pollo mientras hierve la pasta.",
                   ingredients: ["Macarrones", "Cheddar", "Leche y mantequilla", "Pechuga de pollo", "Pan rallado", "Huevos"], category: .comfort),
        DinnerMenu(id: "sandwich", name: "Sándwiches mixtos gourmet de jamón y tres quesos", emoji: "🥪", prepMinutes: 45,
                   tip: "Aprovecha para preparar el chocolate caliente.",
                   ingredients: ["Pan de molde", "Jamón york", "Cheddar, emmental y mozzarella", "Mantequilla", "Chocolate a la taza"], category: .rapida),
        DinnerMenu(id: "risotto", name: "Risotto cremoso de parmesano con pollo y bacon", emoji: "🍚", prepMinutes: 60,
                   tip: "Ten el caldo caliente antes de empezar: el risotto no espera.",
                   ingredients: ["Arroz arborio", "Caldo de pollo", "Parmesano", "Pollo", "Bacon", "Cebolla y mantequilla"], category: .italiana),
        DinnerMenu(id: "xmas-eve", name: "Ibéricos y quesos, croquetas caseras, hojaldritos y tarta de chocolate", emoji: "🎄", prepMinutes: 360,
                   tip: "La masa de croquetas enfría horas y la tarta necesita nevera. ¡Empieza ya!",
                   ingredients: ["Ibéricos variados", "Quesos variados", "Leche, harina y jamón", "Pan rallado y huevo", "Hojaldre", "Chocolate y nata"], category: .festiva),
        DinnerMenu(id: "fondue", name: "Fondue de quesos con pan, patatas y verduras", emoji: "🫕", prepMinutes: 45,
                   tip: "Ralla los quesos y frota el caquelon con ajo antes de fundir.",
                   ingredients: ["Gruyère y emmental", "Vino blanco", "Ajo", "Pan rústico", "Patatas baby", "Brócoli"], category: .festiva),
        DinnerMenu(id: "raclette", name: "Raclette con embutidos y patatas", emoji: "🧀", prepMinutes: 40,
                   tip: "Cuece las patatas con piel mientras preparas la tabla.",
                   ingredients: ["Queso raclette", "Patatas pequeñas", "Jamón y embutidos", "Pepinillos", "Cebolletas"], category: .festiva),
        DinnerMenu(id: "sushi", name: "Sushi casero: makis y uramakis", emoji: "🍣", prepMinutes: 90,
                   tip: "El arroz tiene que enfriar a temperatura ambiente antes de enrollar.",
                   ingredients: ["Arroz para sushi", "Vinagre de arroz", "Alga nori", "Salmón", "Aguacate", "Pepino y queso crema"], category: .festiva),
        DinnerMenu(id: "fajitas", name: "Fajitas de ternera con pimientos", emoji: "🫑", prepMinutes: 45,
                   tip: "Corta la carne en tiras finas y saltea a fuego muy fuerte.",
                   ingredients: ["Ternera en tiras", "Pimientos de colores", "Cebolla", "Tortillas", "Especias fajita", "Nata agria"], category: .texmex),
        DinnerMenu(id: "crepes", name: "Crêpes saladas y dulces", emoji: "🥞", prepMinutes: 50,
                   tip: "Deja reposar la masa 30 minutos.",
                   ingredients: ["Harina", "Huevos", "Leche", "Jamón y queso", "Nutella", "Fresas"], category: .rapida),
        DinnerMenu(id: "ramen", name: "Ramen casero con huevo marinado", emoji: "🍜", prepMinutes: 120,
                   tip: "Marina los huevos al menos 1 hora en soja y mirin.",
                   ingredients: ["Fideos ramen", "Caldo de pollo", "Soja y mirin", "Huevos", "Panceta", "Cebolleta"], category: .comfort),
    ]

    static func menu(_ id: String) -> DinnerMenu { menus.first { $0.id == id }! }

    // MARK: - Películas

    static let movies: [Movie] = [
        Movie(id: "local-hp1", title: "Harry Potter y la piedra filosofal", overview: "Harry descubre en su undécimo cumpleaños que es un mago y empieza su primer curso en Hogwarts.", year: "2001", artwork: "d01", emoji: "⚡️"),
        Movie(id: "local-hp2", title: "Harry Potter y la cámara secreta", overview: "Una misteriosa amenaza petrifica a los alumnos de Hogwarts y Harry escucha una voz en las paredes.", year: "2002", artwork: "d02", emoji: "🐍"),
        Movie(id: "local-hp3", title: "Harry Potter y el prisionero de Azkaban", overview: "Sirius Black escapa de Azkaban y todo indica que va tras Harry.", year: "2004", artwork: "d03", emoji: "🦌"),
        Movie(id: "local-hp4", title: "Harry Potter y el cáliz de fuego", overview: "Harry es elegido misteriosamente para competir en el peligroso Torneo de los Tres Magos.", year: "2005", artwork: "d04", emoji: "🏆"),
        Movie(id: "local-hp5", title: "Harry Potter y la Orden del Fénix", overview: "Nadie cree que Voldemort ha vuelto, y Harry y sus amigos se preparan en secreto.", year: "2007", artwork: "d05", emoji: "🔥"),
        Movie(id: "local-hp6", title: "Harry Potter y el misterio del príncipe", overview: "Dumbledore prepara a Harry para la batalla final explorando el pasado de Voldemort.", year: "2009", artwork: "d06", emoji: "🧪"),
        Movie(id: "local-hp7", title: "Harry Potter y las reliquias de la muerte (Parte 1)", overview: "Harry, Ron y Hermione abandonan Hogwarts para buscar y destruir los horrocruxes.", year: "2010", artwork: "d07", emoji: "🔺"),
        Movie(id: "local-hp8", title: "Harry Potter y las reliquias de la muerte (Parte 2)", overview: "La batalla final por Hogwarts decide el destino del mundo mágico.", year: "2011", artwork: "d08", emoji: "🏰"),
        Movie(id: "local-home1", title: "Solo en casa", overview: "Kevin, de 8 años, se queda solo en casa en Navidad y defiende su hogar de dos ladrones.", year: "1990", artwork: "d09", emoji: "🏠"),
        Movie(id: "local-home2", title: "Solo en casa 2: Perdido en Nueva York", overview: "Kevin coge el avión equivocado y acaba solo en Nueva York... con los mismos ladrones.", year: "1992", artwork: "d10", emoji: "🗽"),
        Movie(id: "local-grinch", title: "El Grinch", overview: "Un ser gruñón que odia la Navidad planea robársela a los habitantes de Villaquién.", year: "2000", artwork: "d11", emoji: "💚"),
        Movie(id: "local-elf", title: "Elf", overview: "Buddy, un humano criado por elfos en el Polo Norte, viaja a Nueva York a buscar a su padre.", year: "2003", artwork: "d12", emoji: "🧝"),
        Movie(id: "local-polar", title: "Polar Express", overview: "En Nochebuena, un niño que duda sube a un tren mágico rumbo al Polo Norte.", year: "2004", artwork: "d13", emoji: "🚂"),
        Movie(id: "local-holiday", title: "The Holiday", overview: "Dos mujeres con el corazón roto intercambian sus casas en Navidad y encuentran el amor.", year: "2006", artwork: "d14", emoji: "🏡"),
        Movie(id: "local-love", title: "Love Actually", overview: "Diez historias de amor entrelazadas en Londres durante las semanas previas a Navidad.", year: "2003", artwork: "d15", emoji: "❤️"),
        Movie(id: "local-klaus", title: "Klaus", overview: "Un cartero mimado y un juguetero solitario cambian un pueblo helado y crean una leyenda.", year: "2019", emoji: "✉️"),
        Movie(id: "local-nightmare", title: "Pesadilla antes de Navidad", overview: "Jack Skellington, rey de Halloween, descubre la Navidad y decide adueñarse de ella.", year: "1993", emoji: "🎃"),
        Movie(id: "local-wonderful", title: "¡Qué bello es vivir!", overview: "Un ángel muestra a George Bailey cómo sería su pueblo si él nunca hubiera nacido.", year: "1946", emoji: "🔔"),
        Movie(id: "local-gremlins", title: "Gremlins", overview: "Un regalo de Navidad muy especial viene con tres reglas... y nadie las cumple.", year: "1984", emoji: "👹"),
        Movie(id: "local-jingle", title: "Un padre en apuros", overview: "Un padre recorre la ciudad en Nochebuena buscando el juguete más deseado del año.", year: "1996", emoji: "🎁"),
        Movie(id: "local-arthur", title: "Operación Regalo", overview: "Arthur, el hijo torpe de Papá Noel, tiene una noche para entregar un regalo olvidado.", year: "2011", emoji: "🎅"),
        Movie(id: "local-chronicles", title: "Crónicas de Navidad", overview: "Dos hermanos intentan grabar a Papá Noel y terminan ayudándole a salvar la Navidad.", year: "2018", emoji: "🛷"),
    ]

    static func movie(_ id: String) -> Movie { movies.first { $0.id == id }! }

    // MARK: - Calendario de ejemplo (el del póster)

    static func templateCalendar() -> AdventCalendar {
        let items: [(Int, Int, String, String)] = [
            (11, 7, "local-hp1", "burger"), (11, 8, "local-hp2", "lasagna"),
            (11, 14, "local-hp3", "pizza-ham"), (11, 15, "local-hp4", "ribs"),
            (11, 21, "local-hp5", "nachos"), (11, 22, "local-hp6", "cannelloni"),
            (11, 28, "local-hp7", "burritos"), (11, 29, "local-hp8", "sirloin"),
            (12, 5, "local-home1", "pizza-ny"), (12, 6, "local-home2", "hotdogs"),
            (12, 12, "local-grinch", "chicken"), (12, 13, "local-elf", "maccheese"),
            (12, 19, "local-polar", "sandwich"), (12, 20, "local-holiday", "risotto"),
            (12, 24, "local-love", "xmas-eve"),
        ]
        let plans: [MoviePlan] = items.map { item -> MoviePlan in
            let film = Self.movie(item.2)
            return MoviePlan(date: Calendar.current.date(from: DateComponents(year: 2026, month: item.0, day: item.1))!,
                             movie: film, menu: Self.menu(item.3), artwork: film.artwork,
                             isSpecial: item.0 == 12 && item.1 == 24)
        }
        return AdventCalendar(name: "Pelis y Comidas 2026", emoji: "🎄", plans: plans)
    }
}
