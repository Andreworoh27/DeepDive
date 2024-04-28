//
//  ScreenshotView.swift
//  LiveCameraSwiftUI
//
//  Created by Muhammad Rasyad Caesarardhi on 26/04/24.
//

import SwiftUI

struct ScreenshotView: View {
    @State private var screenshot: UIImage? = nil
    @State private var isPresentingNextView = false
    @StateObject private var model = FrameHandler()

    var body: some View {
        ZStack {
            if (!isPresentingNextView) {
                FrameView(image: model.frame)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                
                VStack {
                    // Button to capture screenshot
                    Spacer()
                    Button(action: {
                        self.takeScreenshot()
                    }) {
                        Image(systemName: "camera.fill")
                            .padding()
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(360)
                    }
                    .padding()
                    
                    
                    
                }
            }
            
            if (isPresentingNextView) {
                ZStack {
                    NextView(screenshot: screenshot)
                    VStack {
                        Spacer()
                        
                        Rectangle().frame(height: 100).foregroundColor(Color.yellow).background(Color.yellow).ignoresSafeArea()
                    }
                    
                    
                }
                
            }
        }
        
    }
    
    func takeScreenshot() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let renderer = UIGraphicsImageRenderer(bounds: window!.bounds)
        let screenshotImage = renderer.image { ctx in
            window?.layer.render(in: ctx.cgContext)
        }
        screenshot = screenshotImage
        isPresentingNextView.toggle()
    }
}

struct NextView: View {
    var screenshot: UIImage?
    
    var body: some View {
        VStack {
            if let screenshot = screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                let _ = print("there is a screenshot")
                let _ = print(screenshot)
            } else {
                let _ = print("no screenshot")
                Text("No screenshot available")
            }
        }
        .navigationTitle("Screenshot")
    }
}

struct Screenshot_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

