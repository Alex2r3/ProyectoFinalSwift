import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = GameViewModel()
    @State private var stories: [Story] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                if let featuredStory = stories.first {
                    // Banner Cinematográfico
                    ZStack(alignment: .bottomLeading) {
                        getCoverImageView(named: featuredStory.coverImage)
                            .frame(height: 500)
                            .clipped()
                            .overlay(
                                LinearGradient(colors: [.clear, .black.opacity(0.8), .black], startPoint: .top, endPoint: .bottom)
                            )
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("HISTORIA RECOMENDADA")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.accentRed)
                                .cornerRadius(4)
                            
                            Text(featuredStory.title)
                                .font(.system(size: 40, weight: .black))
                                .foregroundColor(.white)
                            
                            Text(featuredStory.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(3)
                            
                            NavigationLink(destination: NarrativeView(viewModel: viewModel).onAppear {
                                viewModel.startStory(featuredStory)
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("COMENZAR HISTORIA")
                                }
                                .font(.headline)
                                .padding()
                                .frame(width: 250)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                        }
                        .padding(30)
                    }
                    .ignoresSafeArea(edges: .top)
                } else {
                    // Carga vacía
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Cargando historias...")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                    .frame(height: 500)
                    .frame(maxWidth: .infinity)
                }
                
                // Sección de Exploración
                if stories.count > 1 {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("MÁS HISTORIAS")
                            .font(.headline)
                            .tracking(3)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(stories.dropFirst()) { story in
                                    NavigationLink(destination: NarrativeView(viewModel: viewModel).onAppear {
                                        viewModel.startStory(story)
                                    }) {
                                        StoryCard(story: story)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .background(Theme.black.ignoresSafeArea())
        .onAppear {
            var loaded = StoryService.loadStoriesFromBundle()
            // Asegurar que getElUltimoFaro() esté disponible como fallback si no está cargada
            if !loaded.contains(where: { $0.id == "el_ultimo_faro" }) {
                loaded.append(StoryService.getElUltimoFaro())
            }
            self.stories = loaded
        }
    }
    
    @ViewBuilder
    private func getCoverImageView(named name: String) -> some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let path = findImagePath(named: name) {
            if let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                defaultCoverPlaceholder()
            }
        } else {
            defaultCoverPlaceholder()
        }
    }
    
    private func findImagePath(named name: String) -> String? {
        let extensions = ["png", "jpg", "jpeg", "webp"]
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext, subdirectory: "Resources/Images") {
                return path
            }
            if let path = Bundle.main.path(forResource: name, ofType: ext, subdirectory: "Images") {
                return path
            }
        }
        return nil
    }
    
    private func defaultCoverPlaceholder() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Theme.darkGray, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.15))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StoryCard: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                getCardImageView(named: story.coverImage)
                    .frame(width: 180, height: 260)
                    .cornerRadius(15)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Tag de duración
                Text(story.duration)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(10)
            }
            
            Text(story.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text("\(story.genre)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func getCardImageView(named name: String) -> some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let path = findImagePath(named: name) {
            if let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                defaultCardPlaceholder()
            }
        } else {
            defaultCardPlaceholder()
        }
    }
    
    private func findImagePath(named name: String) -> String? {
        let extensions = ["png", "jpg", "jpeg", "webp"]
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext, subdirectory: "Resources/Images") {
                return path
            }
            if let path = Bundle.main.path(forResource: name, ofType: ext, subdirectory: "Images") {
                return path
            }
        }
        return nil
    }
    
    private func defaultCardPlaceholder() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Theme.darkGray, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            Image(systemName: "book.closed")
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
