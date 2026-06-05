import SwiftUI

struct NarrativeView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Theme.black.ignoresSafeArea()
            
            // Fondo Cinematográfico
            VStack {
                if let scene = viewModel.currentScene {
                    getBackgroundImage(named: scene.backgroundImage)
                }
            }
            
            // Borde/Brillo rojo progresivo del temporizador
            if viewModel.isTimerActive {
                ZStack {
                    // Viñeta roja en los bordes
                    RadialGradient(
                        gradient: Gradient(colors: [.clear, Color.red.opacity(0.55)]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 380
                    )
                    .ignoresSafeArea()
                    
                    // Borde rojo difuminado
                    Rectangle()
                        .strokeBorder(Theme.accentRed, lineWidth: 10)
                        .blur(radius: 6)
                        .ignoresSafeArea()
                }
                .opacity(viewModel.timerProgress)
                .allowsHitTesting(false)
            }
            
            VStack {
                // HUD de Estadísticas
                HStack(spacing: 12) {
                    StatBar(label: "CONFIANZA", value: viewModel.trust, color: .blue)
                    StatBar(label: "VALENTÍA", value: viewModel.bravery, color: Theme.accentRed)
                    StatBar(label: "HUMANIDAD", value: viewModel.humanity, color: Theme.accentYellow)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                
                Spacer()
                
                // Diálogo y Decisiones
                VStack(spacing: 20) {
                    if let scene = viewModel.currentScene {
                        VStack(alignment: .leading, spacing: 12) {
                            if let name = scene.characterName {
                                Text(name.uppercased())
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(Theme.accentYellow)
                                    .tracking(3)
                            }
                            
                            Text(scene.dialogue)
                                .font(.custom("AvenirNext-Medium", size: 19))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black.opacity(0.7))
                                .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        )
                        .padding(.horizontal)
                        
                        if !viewModel.gameCompleted {
                            VStack(spacing: 12) {
                                ForEach(scene.choices) { choice in
                                    ChoiceButton(choice: choice) {
                                        viewModel.makeChoice(choice)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        } else {
                            // Pantalla de Final
                            VStack(spacing: 20) {
                                Text(viewModel.activeEndingTitle)
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundColor(Theme.accentRed)
                                
                                Text(viewModel.activeEndingDescription)
                                    .multilineTextAlignment(.center)
                                    .opacity(0.8)
                                    .padding(.horizontal)
                                
                                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                    Text("VOLVER AL MENÚ")
                                        .bold()
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(40)
                            .background(Color.black)
                            .cornerRadius(30)
                            .padding()
                        }
                    }
                }
            }
            
            // Overlay de tiempo agotado
            if viewModel.timeOutTriggered {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "timer")
                            .font(.system(size: 70))
                            .foregroundColor(Theme.accentRed)
                            .padding(.bottom, 10)
                            
                        Text("¡EL TIEMPO SE ACABÓ!")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(Theme.accentRed)
                            .tracking(2)
                            
                        Text("Se seleccionará automáticamente la peor opción...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Theme.accentRed.opacity(0.5), lineWidth: 2)
                            )
                    )
                    .padding(30)
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            AudioManager.shared.stopMusic()
        }
    }
    
    @ViewBuilder
    private func getBackgroundImage(named name: String) -> some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        } else if let path = findImagePath(named: name) {
            if let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            } else {
                defaultBackgroundPlaceholder(named: name)
            }
        } else {
            defaultBackgroundPlaceholder(named: name)
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
    
    private func defaultBackgroundPlaceholder(named name: String) -> some View {
        ZStack {
            Rectangle().fill(Theme.darkGray)
            
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.15))
                Text("Escena: \(name)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.25))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
