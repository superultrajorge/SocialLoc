import SwiftUI

/// Carta de menús por categorías. Con `selection` sirve para elegir; sin ella, para explorar.
struct MenuPickerView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var selection: Binding<DinnerMenu?>?

    @State private var category: MenuCategory?
    @State private var detail: DinnerMenu?
    @State private var showCreate = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var menus: [DinnerMenu] {
        guard let category else { return model.allMenus }
        return model.allMenus.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            AppBackground(snow: false)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal) {
                        GlassEffectContainer(spacing: 8) {
                            HStack(spacing: 8) {
                                chip(nil, "Todos")
                                ForEach(MenuCategory.allCases) { chip($0, $0.rawValue) }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollIndicators(.hidden)

                    LazyVGrid(columns: columns, spacing: 12) {
                        Button { showCreate = true } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill").font(.system(size: 36))
                                Text("Crear mi menú").font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(Theme.gold)
                            .frame(maxWidth: .infinity, minHeight: 150)
                        }
                        .buttonStyle(.plain)
                        .glassCard(20, tint: Theme.gold.opacity(0.1), interactive: true)

                        ForEach(menus) { menu in card(menu) }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Menús")
        .sheet(item: $detail) { menu in MenuDetailSheet(menu: menu) }
        .sheet(isPresented: $showCreate) { CustomMenuEditor() }
    }

    @ViewBuilder
    private func chip(_ value: MenuCategory?, _ title: String) -> some View {
        if category == value {
            Button(title) { withAnimation(.snappy) { category = value } }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.glassProminent)
        } else {
            Button(title) { withAnimation(.snappy) { category = value } }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.glass)
        }
    }

    private func card(_ menu: DinnerMenu) -> some View {
        let selected = selection?.wrappedValue?.id == menu.id
        return Button {
            if let selection {
                selection.wrappedValue = menu
                dismiss()
            } else {
                detail = menu
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(menu.emoji).font(.system(size: 40))
                    Spacer()
                    if selected { Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.gold) }
                }
                Text(menu.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.cream)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Label(menu.prepText, systemImage: "timer")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.gold)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassCard(20, tint: selected ? Theme.gold.opacity(0.3) : Theme.burgundy.opacity(0.2), interactive: true)
        .contextMenu {
            if menu.category == .propia {
                Button("Eliminar", systemImage: "trash", role: .destructive) {
                    model.customMenus.removeAll { $0.id == menu.id }
                }
            }
        }
    }
}

struct MenuDetailSheet: View {
    let menu: DinnerMenu
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text(menu.emoji).font(.system(size: 50))
                        VStack(alignment: .leading) {
                            Text(menu.name).font(.headline)
                            Label("Preparación: \(menu.prepText)", systemImage: "timer").font(.subheadline).foregroundStyle(Theme.gold)
                        }
                    }
                    Text(menu.tip)
                }
                Section("Lista de la compra") {
                    ForEach(menu.ingredients, id: \.self) { Label($0, systemImage: "cart") }
                }
            }
            .navigationTitle(menu.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

struct CustomMenuEditor: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var emoji = "🍽️"
    @State private var prepMinutes = 60
    @State private var tip = ""
    @State private var ingredients = ""

    private let emojis = ["🍽️", "🍕", "🍔", "🌮", "🍣", "🍝", "🥘", "🍗", "🥩", "🧀", "🥗", "🍜", "🍰", "🎄"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Menú") {
                    TextField("Nombre (p. ej. Tacos de cochinita)", text: $name)
                    Picker("Icono", selection: $emoji) {
                        ForEach(emojis, id: \.self) { Text($0).tag($0) }
                    }
                    Stepper("Preparación: \(prepMinutes) min", value: $prepMinutes, in: 10...600, step: 10)
                }
                Section("Consejo para el aviso") {
                    TextField("Qué hay que empezar primero", text: $tip, axis: .vertical)
                }
                Section("Ingredientes (uno por línea)") {
                    TextField("Ingredientes", text: $ingredients, axis: .vertical)
                        .lineLimit(4...10)
                }
            }
            .navigationTitle("Mi menú")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar", role: .cancel) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let menu = DinnerMenu(
                            id: "custom-\(UUID().uuidString)", name: name, emoji: emoji, prepMinutes: prepMinutes,
                            tip: tip.isEmpty ? "¡Manos a la obra!" : tip,
                            ingredients: ingredients.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty },
                            category: .propia)
                        model.customMenus.insert(menu, at: 0)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
