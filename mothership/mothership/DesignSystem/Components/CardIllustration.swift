//
//  CardIllustration.swift
//  mothership
//
//  Card illustrations
//  Uses SVG illustrations from Assets.xcassets
//

import SwiftUI

struct CardIllustration: View {
    let type: IllustrationType
    var size: CGFloat = 100
    
    enum IllustrationType {
        case basics // Heart character with flower (basics-illustration.svg)
        case relaxation // Person with headphones
        case focus // Person meditating
        case happiness // Person with floating spheres
        case dailyThought // Abstract meditation scene
    }
    
    var body: some View {
        ZStack {
            switch type {
            case .basics:
                Image("basics-illustration")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                
            case .relaxation:
                Image("safety")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                
            case .focus:
                Image("officeworker")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                
            case .happiness:
                // Person with floating elements - placeholder
                ZStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.white.opacity(0.9))
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(.white.opacity(0.6))
                            .frame(width: size * 0.15, height: size * 0.15)
                            .offset(
                                x: cos(Double(i) * 2 * .pi / 3) * size * 0.3,
                                y: sin(Double(i) * 2 * .pi / 3) * size * 0.3
                            )
                    }
                }
                
            case .dailyThought:
                // Abstract meditation scene - placeholder
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: size * 0.6, height: size * 0.6)
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: size * 0.4, height: size * 0.4)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack {
        CardIllustration(type: .basics)
        CardIllustration(type: .relaxation)
        CardIllustration(type: .focus)
        CardIllustration(type: .happiness)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}

