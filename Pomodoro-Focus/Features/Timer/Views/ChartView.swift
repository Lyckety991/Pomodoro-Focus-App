//
//  ChartView.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import SwiftUI
import Charts

struct ChartView: View {
    let data: [ChartDataPoint]
    
    private let design = DesignSystem.shared
    
    var body: some View {
        if data.isEmpty {
            emptyStateView
        } else {
            Chart {
                ForEach(data) { point in
                    BarMark(
                        x: .value("Time", point.label),
                        y: .value("Minutes", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                design.colors.primary,
                                design.colors.primary.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    // Zeige nur jeden N-ten Wert basierend auf Datenmenge
                    if shouldShowLabel(for: value, in: data) {
                        AxisValueLabel()
                            .font(.system(size: 10))
                            .foregroundStyle(design.colors.textSecondary)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                        .font(.system(size: 11))
                        .foregroundStyle(design.colors.textSecondary)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.background(design.colors.background.opacity(0.3))
            }
        }
    }
    
    // MARK: - Helper
    
    private func shouldShowLabel(for value: AxisValue, in data: [ChartDataPoint]) -> Bool {
        let index = value.index
        
        // More than 12 data points: show every 3rd
        if data.count > 12 {
            return index % 3 == 0
        }
        
        // More than 7 data points: show every 2nd
        if data.count > 7 {
            return index % 2 == 0
        }
        
        // Otherwise show all
        return true
    }
    
    private var emptyStateView: some View {
        VStack(spacing: design.spacing.md) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(design.colors.textSecondary.opacity(0.5))
            
            Text("No data yet")
                .font(design.typography.body)
                .foregroundColor(design.colors.textSecondary)
            
            Text("Complete some focus sessions to see your stats")
                .font(design.typography.caption)
                .foregroundColor(design.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(design.spacing.xl)
    }
}

#Preview {
    let now = Date()
    let sampleData: [ChartDataPoint] = [
        ChartDataPoint(label: "Mon", value: 30, date: now.addingTimeInterval(-5*24*60*60)),
        ChartDataPoint(label: "Tue", value: 45, date: now.addingTimeInterval(-4*24*60*60)),
        ChartDataPoint(label: "Wed", value: 20, date: now.addingTimeInterval(-3*24*60*60)),
        ChartDataPoint(label: "Thu", value: 60, date: now.addingTimeInterval(-2*24*60*60)),
        ChartDataPoint(label: "Fri", value: 50, date: now.addingTimeInterval(-1*24*60*60)),
        ChartDataPoint(label: "Sat", value: 35, date: now),
        ChartDataPoint(label: "Sun", value: 40, date: now.addingTimeInterval(1*24*60*60))
    ]
    return ChartView(data: sampleData)
}
