import SwiftUI
import ARKit
import Vision
import AVFoundation
import Combine

struct ARScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            // AR Camera View
            ARViewContainer(viewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // Top Bar with Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Center Reticle
            VStack {
                Spacer()
                
                ZStack {
                    // Reticle corners
                    ReticleCorners()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    // Classification Result Overlay
                    if arViewModel.hasResult {
                        VStack(spacing: 8) {
                            Text(arViewModel.isRecyclable ? "RECYCLABLE" : "TRASH")
                                .font(.system(size: 24, weight: .light, design: .monospaced))
                                .foregroundColor(.white)
                                .tracking(3)
                                .shadow(color: .black.opacity(0.5), radius: 4)
                            
                            HStack(spacing: 2) {
                                Text("\(Int(arViewModel.confidence * 100))")
                                    .font(.system(size: 32, weight: .ultraLight, design: .monospaced))
                                Text("%")
                                    .font(.system(size: 16, weight: .light, design: .monospaced))
                                    .padding(.top, 10)
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                            
                            Rectangle()
                                .fill(arViewModel.isRecyclable ? Color.green : Color.red)
                                .frame(width: 30, height: 2)
                                .shadow(color: .black.opacity(0.5), radius: 4)
                            
                            // Low confidence warning
                            if arViewModel.isRecyclable && arViewModel.confidence < 0.6 {
                                VStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.5))
                                        .frame(width: 60, height: 1)
                                        .padding(.top, 6)
                                    
                                    Text("⚠️ IF IN DOUBT,")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .tracking(1)
                                        .shadow(color: .black.opacity(0.5), radius: 4)
                                    
                                    Text("THROW IT OUT")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .tracking(1)
                                        .shadow(color: .black.opacity(0.5), radius: 4)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.4))
                                .blur(radius: 20)
                        )
                    } else {
                        Text("POINT AT ITEM")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2)
                            .shadow(color: .black.opacity(0.5), radius: 4)
                    }
                }
                
                Spacer()
                
                // Instructions
                Text("AIM CENTER AT ITEM TO SCAN")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(1)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            arViewModel.startSession()
        }
        .onDisappear {
            arViewModel.stopSession()
        }
    }
}

// Custom shape for reticle corners
struct ReticleCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerLength: CGFloat = 30
        
        // Top-left corner
        path.move(to: CGPoint(x: 0, y: cornerLength))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cornerLength, y: 0))
        
        // Top-right corner
        path.move(to: CGPoint(x: rect.width - cornerLength, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: cornerLength))
        
        // Bottom-right corner
        path.move(to: CGPoint(x: rect.width, y: rect.height - cornerLength))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width - cornerLength, y: rect.height))
        
        // Bottom-left corner
        path.move(to: CGPoint(x: cornerLength, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height - cornerLength))
        
        return path
    }
}

// ViewModel to handle AR session and classification
class ARViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var hasResult = false
    @Published var isRecyclable = false
    @Published var confidence: Double = 0.0
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var lastClassificationTime = Date()
    private let classificationInterval: TimeInterval = 0.5 // Classify every 0.5 seconds
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Failed to create video input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
    
    // This gets called for every camera frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Throttle classification to avoid overwhelming the device
        let now = Date()
        guard now.timeIntervalSince(lastClassificationTime) >= classificationInterval else {
            return
        }
        lastClassificationTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        classifyFrame(pixelBuffer: pixelBuffer)
    }
    
    private func classifyFrame(pixelBuffer: CVPixelBuffer) {
        guard let model = try? VNCoreMLModel(for: SiftModel(configuration: MLModelConfiguration()).model) else {
            print("Failed to load model")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                return
            }
            
            DispatchQueue.main.async {
                self?.confidence = Double(topResult.confidence)
                self?.isRecyclable = topResult.identifier == "Recyclable"
                self?.hasResult = true
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

// UIViewRepresentable to bridge AVCaptureVideoPreviewLayer to SwiftUI
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        if let previewLayer = viewModel.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = viewModel.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    ARScanView()
}
