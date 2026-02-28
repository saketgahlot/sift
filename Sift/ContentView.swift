import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSettings = false // NEW: State for settings
    @State private var hasClassified = false
    @State private var predictionResult = ""
    @State private var confidence: Double = 0.0
    @State private var isRecyclable = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Fixed Header with Settings
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("SIFT")
                                .font(.system(size: 40, weight: .light, design: .monospaced))
                                .foregroundColor(.black)
                                .tracking(8)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 60, height: 1)
                            
                            Text("SCAN TO SORT")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                                .tracking(2)
                        }
                        
                        Spacer()
                    }
                    .overlay(
                        // Settings button in top right
                        HStack {
                            Spacer()
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 22, weight: .light))
                                    .foregroundColor(.black)
                            }
                            .padding(.trailing, 20)
                        }
                    )
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 40) {
                    
                    // Divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 1)
                        Text("OR")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(1)
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    
                    // Image Preview
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 350)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            .frame(height: 350)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 50, weight: .ultraLight))
                                        .foregroundColor(.black.opacity(0.3))
                                    Text("NO IMAGE")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .tracking(1)
                                }
                            )
                    }
                    
                    // Results - Minimalist
                    if hasClassified {
                        VStack(spacing: 20) {
                            Text(isRecyclable ? "RECYCLABLE" : "TRASH")
                                .font(.system(size: 28, weight: .light, design: .monospaced))
                                .foregroundColor(.black)
                                .tracking(4)
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("\(Int(confidence * 100))")
                                        .font(.system(size: 48, weight: .ultraLight, design: .monospaced))
                                    Text("%")
                                        .font(.system(size: 20, weight: .light, design: .monospaced))
                                        .padding(.top, 20)
                                }
                                .foregroundColor(.black)
                                
                                Text("CONFIDENCE")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .tracking(1)
                            }
                            
                            Rectangle()
                                .fill(isRecyclable ? Color.green : Color.red)
                                .frame(width: 40, height: 2)
                            
                            Text(isRecyclable ? "CAN BE RECYCLED" : "GOES IN TRASH")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            // Low confidence warning for recyclable items
                            if isRecyclable && confidence < 0.6 {
                                VStack(spacing: 8) {
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.3))
                                        .frame(height: 1)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 8)
                                    
                                    Text("⚠️")
                                        .font(.system(size: 24))
                                    
                                    Text("IF IN DOUBT,")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .tracking(2)
                                    
                                    Text("THROW IT OUT")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .tracking(2)
                                    
                                    Text("Low confidence items may contaminate recycling")
                                        .font(.system(size: 8, weight: .regular, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .tracking(0.5)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    // Buttons - Minimalist
                    HStack(spacing: 16) {
                        Button(action: {
                            showCamera = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera")
                                    .font(.system(size: 24, weight: .thin))
                                Text("CAMERA")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .tracking(1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 90)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24, weight: .thin))
                                Text("PHOTOS")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .tracking(1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 90)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        
                        if selectedImage != nil {
                            Button(action: {
                                classifyImage()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 24, weight: .thin))
                                    Text("CLASSIFY")
                                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                                        .tracking(1)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 90)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, isPresented: $showCamera, sourceType: .camera)
                    .onDisappear {
                        hasClassified = false
                    }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, isPresented: $showImagePicker, sourceType: .photoLibrary)
                    .onDisappear {
                        hasClassified = false
                    }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func classifyImage() {
        guard let image = selectedImage,
              let ciImage = CIImage(image: image) else { return }
        
        guard let model = try? VNCoreMLModel(for: SiftModel(configuration: MLModelConfiguration()).model) else {
            print("Failed to load model")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                print("Failed to classify image")
                return
            }
            
            DispatchQueue.main.async {
                self.confidence = Double(topResult.confidence)
                self.isRecyclable = topResult.identifier == "Recyclable"
                self.predictionResult = self.isRecyclable ? "Recyclable ♻️" : "Trash 🗑️"
                self.hasClassified = true
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
