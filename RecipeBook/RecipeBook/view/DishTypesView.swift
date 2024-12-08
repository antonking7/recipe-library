import SwiftUI
import SwiftData

struct DishTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    
    @State private var isAddingNewDishType: Bool = false
    @State private var showSearchView: Bool = false

    var body: some View {
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
                ToolbarItem {
                       Button(action: { showSearchView.toggle() }) {
                           Image(systemName: "magnifyingglass")
                               .foregroundColor(.blue)
                       }
               }
            }
            .sheet(isPresented: $isAddingNewDishType) {
                AddDishTypeView(isPresented: $isAddingNewDishType) .navigationTitle("Добавление нового типа блюда")
            }
        .sheet(isPresented: $showSearchView) {
                           SearchRecipesView()
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
