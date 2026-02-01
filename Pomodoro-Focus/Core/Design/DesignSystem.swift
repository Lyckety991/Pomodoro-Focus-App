import SwiftUI

struct DesignSystem {
    static let shared = DesignSystem()
    private init() {}
    
    let colors = AppColors()
    let typography = AppTypography()
    let spacing = AppSpacing()
    let cornerRadius = CornerRadius()
}

// MARK: - Colors (Hardcoded für schnellen Start)
struct AppColors {
    // Primary
    let primary = Color(red: 1.0, green: 0.42, blue: 0.42) // #FF6B6B
    let primaryLight = Color(red: 1.0, green: 0.6, blue: 0.6)
    let primaryDark = Color(red: 0.8, green: 0.2, blue: 0.2)
    
    // Background
    let background = Color(UIColor.systemBackground)
    let surface = Color(UIColor.secondarySystemBackground)
    
    // Text
    let textPrimary = Color(UIColor.label)
    let textSecondary = Color(UIColor.secondaryLabel)
    
    // Semantic
    let success = Color.green
    let error = Color.red
    let warning = Color.orange
    
    // Timer States
    let focus = Color(red: 0.91, green: 0.30, blue: 0.24) // #E74C3C
    let shortBreak = Color(red: 0.18, green: 0.80, blue: 0.44) // #2ECC71
    let longBreak = Color(red: 0.20, green: 0.60, blue: 0.86) // #3498DB
}

// MARK: - Typography
struct AppTypography {
    let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    let body = Font.system(size: 17, weight: .regular, design: .rounded)
    let bodyBold = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    let timerDisplay = Font.system(size: 72, weight: .bold, design: .rounded)
    
    let caption = Font.system(size: 14, weight: .regular, design: .rounded)
    let captionBold = Font.system(size: 14, weight: .semibold, design: .rounded)
}

// MARK: - Spacing
struct AppSpacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    let sm: CGFloat = 8
    let md: CGFloat = 12
    let lg: CGFloat = 16
    let xl: CGFloat = 24
    let circle: CGFloat = 999
}
