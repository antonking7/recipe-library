import SwiftUI
import SwiftData

struct DishTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    
    @State private var isAddingNewDishType: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(dishTypes) { dishType in
                    NavigationLink(destination: ContentView(selectedDishType: dishType.name)) {
                        HStack {
                            if let imageData = dishType.image, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                            Text(dishType.name)
                            Spacer()
                        }
                    }
                }
                .onDelete(perform: deleteDishType)
            }
            .navigationTitle("Типы Блюд")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAddingNewDishType.toggle() }) {
                        Label("Добавить Тип", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingNewDishType) {
            AddDishTypeView(isPresented: $isAddingNewDishType)
        }
    }

    private func deleteDishType(_ offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let dishType = dishTypes[index]
                modelContext.delete(dishType)
            }
        }
    }
}

struct DishTypesView_Previews: PreviewProvider {
    static var previews: some View {
        DishTypesView()
    }
}
