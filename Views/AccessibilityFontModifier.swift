// Dodaj do osobnego pliku: AccessibilityFontModifier.swift
import SwiftUI

struct DynamicFontModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design)) // ✅ Używaj .system
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .allowsTightening(true)
    }
}

extension View {
    func dynamicFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(DynamicFontModifier(size: size, weight: weight, design: design))
    }
}
