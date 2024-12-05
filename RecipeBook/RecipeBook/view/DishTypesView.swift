import SwiftUI
import SwiftData

struct DishTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    
    @State private var newName: String = ""
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(dishTypes) { dishType in
                        HStack {
                            if let imageData = dishType.image, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                            Text(dishType.name)
                            Spacer()
                            Button(action: { deleteDishType(dishType) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if let image = newImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Button(action: { showImagePicker = true }) {
                            Label("Выбрать Изображение", systemImage: "photo")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                    }
                    
                    TextField("Название", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.words)
                    
                    Button(action: addDishType) {
                        Text("Добавить Тип Блюда")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
    }
    
    private func addDishType() {
        guard !newName.isEmpty else { return } // Ensure name is not empty
        
        let newDishType = DishType(
            name: newName,
            image: newImage?.pngData()
        )
        
        modelContext.insert(newDishType)
        do {
            try modelContext.save()
            newName = ""
            newImage = nil
        } catch {
            print("Не удалось сохранить тип блюда: \(error)")
        }
    }
    
    private func deleteDishType(_ dishType: DishType) {
        withAnimation {
            modelContext.delete(dishType)
        }
    }
}
