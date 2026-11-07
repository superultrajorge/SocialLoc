import Foundation

/// Un plan del calendario: película + cena.
struct MoviePlan: Identifiable, Hashable {
    let id: Int
    let month: Int
    let day: Int
    let title: String
    let food: String
    let image: String
    let emoji: String
    /// Minutos que hay que empezar a cocinar antes de la hora de la peli.
    let prepMinutes: Int
    let prepTip: String
    let ingredients: [String]
    var isSpecial: Bool = false

    static let year = 2026

    var date: Date {
        Calendar.current.date(from: DateComponents(year: Self.year, month: month, day: day))!
    }

    /// "SÁB 7 NOV"
    var dayLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "EEE d MMM"
        return f.string(from: date).replacingOccurrences(of: ".", with: "").uppercased()
    }

    /// Fecha y hora de la peli según la hora elegida en ajustes.
    func movieTime(dinnerMinutes: Int) -> Date {
        Calendar.current.startOfDay(for: date).addingTimeInterval(TimeInterval(dinnerMinutes * 60))
    }

    func prepStart(dinnerMinutes: Int) -> Date {
        movieTime(dinnerMinutes: dinnerMinutes).addingTimeInterval(TimeInterval(-prepMinutes * 60))
    }

    var prepText: String {
        let h = prepMinutes / 60, m = prepMinutes % 60
        switch (h, m) {
        case (0, _): return "\(m) min"
        case (_, 0): return "\(h) h"
        default: return "\(h) h \(m) min"
        }
    }
}

extension MoviePlan {
    static let all: [MoviePlan] = [
        MoviePlan(id: 1, month: 11, day: 7,
                  title: "Harry Potter y la piedra filosofal",
                  food: "Hamburguesas caseras con cheddar, bacon y patatas gajo",
                  image: "d01", emoji: "🍔", prepMinutes: 90,
                  prepTip: "Corta las patatas gajo y mételas al horno primero; las hamburguesas van al final.",
                  ingredients: ["Carne picada de ternera", "Pan de hamburguesa", "Cheddar en lonchas", "Bacon", "Patatas", "Lechuga, tomate y cebolla"]),
        MoviePlan(id: 2, month: 11, day: 8,
                  title: "Harry Potter y la cámara secreta",
                  food: "Lasaña boloñesa gratinada",
                  image: "d02", emoji: "🍝", prepMinutes: 150,
                  prepTip: "El ragú necesita al menos 45 min a fuego lento antes de montar la lasaña.",
                  ingredients: ["Placas de lasaña", "Carne picada mixta", "Tomate triturado", "Cebolla y zanahoria", "Bechamel", "Mozzarella y parmesano"]),
        MoviePlan(id: 3, month: 11, day: 14,
                  title: "Harry Potter y el prisionero de Azkaban",
                  food: "Pizza artesana de jamón, mozzarella y bacon",
                  image: "d03", emoji: "🍕", prepMinutes: 240,
                  prepTip: "La masa tiene que levar unas 3 horas: amásala ya.",
                  ingredients: ["Harina de fuerza", "Levadura", "Tomate para pizza", "Jamón york", "Mozzarella", "Bacon"]),
        MoviePlan(id: 4, month: 11, day: 15,
                  title: "Harry Potter y el cáliz de fuego",
                  food: "Costillas al horno con salsa barbacoa y patatas asadas",
                  image: "d04", emoji: "🍖", prepMinutes: 210,
                  prepTip: "Las costillas van tapadas con papel de aluminio 2 h a fuego bajo y luego se glasean.",
                  ingredients: ["Costillar de cerdo", "Salsa barbacoa", "Pimentón y ajo en polvo", "Patatas", "Papel de aluminio"]),
        MoviePlan(id: 5, month: 11, day: 21,
                  title: "Harry Potter y la Orden del Fénix",
                  food: "Nachos gratinados con carne, cheddar y guacamole",
                  image: "d05", emoji: "🌮", prepMinutes: 60,
                  prepTip: "Haz el guacamole al final para que no se oscurezca.",
                  ingredients: ["Totopos", "Carne picada", "Especias tex-mex", "Cheddar rallado", "Aguacates y lima", "Jalapeños"]),
        MoviePlan(id: 6, month: 11, day: 22,
                  title: "Harry Potter y el misterio del príncipe",
                  food: "Canelones de carne con bechamel y queso gratinado",
                  image: "d06", emoji: "🥘", prepMinutes: 150,
                  prepTip: "Prepara el relleno y la bechamel antes de hervir las placas.",
                  ingredients: ["Placas de canelones", "Carne picada", "Cebolla", "Bechamel", "Queso para gratinar"]),
        MoviePlan(id: 7, month: 11, day: 28,
                  title: "Harry Potter y las reliquias de la muerte (Parte 1)",
                  food: "Burritos de pollo con arroz, queso y salsa de yogur",
                  image: "d07", emoji: "🌯", prepMinutes: 60,
                  prepTip: "Cuece el arroz mientras marinas el pollo.",
                  ingredients: ["Tortillas grandes", "Pechuga de pollo", "Arroz", "Queso rallado", "Yogur griego", "Pimiento y maíz"]),
        MoviePlan(id: 8, month: 11, day: 29,
                  title: "Harry Potter y las reliquias de la muerte (Parte 2)",
                  food: "Solomillo de cerdo con salsa de pimienta y patatas panaderas",
                  image: "d08", emoji: "🥩", prepMinutes: 90,
                  prepTip: "Las panaderas tardan más: empiézalas antes de sellar el solomillo.",
                  ingredients: ["Solomillo de cerdo", "Pimienta en grano", "Nata para cocinar", "Patatas", "Cebolla"]),
        MoviePlan(id: 9, month: 12, day: 5,
                  title: "Solo en casa",
                  food: "Pizza estilo Nueva York de pepperoni y mozzarella",
                  image: "d09", emoji: "🍕", prepMinutes: 240,
                  prepTip: "Masa con 3–4 h de levado. Si puedes, hazla la noche anterior.",
                  ingredients: ["Harina de fuerza", "Levadura", "Tomate para pizza", "Pepperoni", "Mozzarella", "Orégano"]),
        MoviePlan(id: 10, month: 12, day: 6,
                  title: "Solo en casa 2: Perdido en Nueva York",
                  food: "Perritos calientes con cebolla crujiente, cheddar y patatas fritas",
                  image: "d10", emoji: "🌭", prepMinutes: 60,
                  prepTip: "Fríe las patatas al final para que lleguen crujientes.",
                  ingredients: ["Pan de perrito", "Salchichas", "Cebolla crujiente", "Salsa cheddar", "Patatas", "Kétchup y mostaza"]),
        MoviePlan(id: 11, month: 12, day: 12,
                  title: "El Grinch",
                  food: "Pollo asado con miel y mostaza, con patatas crujientes",
                  image: "d11", emoji: "🍗", prepMinutes: 120,
                  prepTip: "Unta el pollo con miel y mostaza y riégalo con su jugo cada 20 min.",
                  ingredients: ["Pollo entero", "Miel", "Mostaza", "Patatas", "Ajo y romero"]),
        MoviePlan(id: 12, month: 12, day: 13,
                  title: "Elf",
                  food: "Macarrones con queso y tiras de pollo crujiente",
                  image: "d12", emoji: "🧀", prepMinutes: 60,
                  prepTip: "Empana el pollo mientras hierve la pasta.",
                  ingredients: ["Macarrones", "Cheddar", "Leche y mantequilla", "Pechuga de pollo", "Pan rallado (o copos de maíz)", "Huevos"]),
        MoviePlan(id: 13, month: 12, day: 19,
                  title: "Polar Express",
                  food: "Sándwiches mixtos gourmet de jamón y tres quesos",
                  image: "d13", emoji: "🥪", prepMinutes: 45,
                  prepTip: "Y aprovecha para preparar el chocolate caliente.",
                  ingredients: ["Pan de molde", "Jamón york", "Cheddar, emmental y mozzarella", "Mantequilla", "Chocolate a la taza"]),
        MoviePlan(id: 14, month: 12, day: 20,
                  title: "The Holiday",
                  food: "Risotto cremoso de parmesano con pollo y bacon",
                  image: "d14", emoji: "🍚", prepMinutes: 60,
                  prepTip: "Ten el caldo caliente antes de empezar: el risotto no espera.",
                  ingredients: ["Arroz arborio", "Caldo de pollo", "Parmesano", "Pollo", "Bacon", "Cebolla y mantequilla"]),
        MoviePlan(id: 15, month: 12, day: 24,
                  title: "Love Actually",
                  food: "Tabla de ibéricos y quesos, croquetas caseras, hojaldritos de jamón y queso, y tarta de chocolate",
                  image: "d15", emoji: "🎄", prepMinutes: 360,
                  prepTip: "La masa de croquetas tiene que enfriar horas y la tarta necesita nevera. ¡Empieza ya!",
                  ingredients: ["Ibéricos variados", "Quesos variados", "Leche, harina y jamón (croquetas)", "Pan rallado y huevo", "Hojaldre", "Chocolate y nata"],
                  isSpecial: true),
    ]
}
