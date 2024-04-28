//
//  StoryView.swift
//  HapticTest
//
//  Created by Muhammad Rasyad Caesarardhi on 25/04/24.
//

import SwiftUI

struct StoryView: View {
    @State private var sunOpacity = 0.0
    @State private var cloudOpacity = 0.0
    @State private var moonOpacity = 0.0
    
    let animationDuration: Double = 3
    
    var body: some View {
        // Create a ZStack to add the background color
        ZStack {
                    Color.skyBlue
                        .edgesIgnoringSafeArea(.all)
                    
                    // Add your content on top of the background color
            VStack(spacing: 150) {
                            Spacer()
                            
                Image(systemName: "sun.max.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.yellow)
                                    .opacity(sunOpacity)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            sunOpacity = 1.0
                                        }
                                    }
                                
                                Image(systemName: "cloud.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .opacity(cloudOpacity)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: animationDuration).delay(animationDuration)) {
                                            cloudOpacity = 1.0
                                        }
                                    }
                                
                                Image(systemName: "moon.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .opacity(moonOpacity)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: animationDuration).delay(2 * animationDuration)) {
                                            moonOpacity = 1.0
                                        }
                                    }
                            
                            Spacer()
                        }
                        .padding()
                }
    }
}

extension Color {
    static let skyBlue = Color(red: 135/255, green: 206/255, blue: 235/255)
}

#Preview {
    StoryView()
}
