//
//  StatisticsViewModel.swift
//  Pomodoro-Focus
//
//  Created by Patrick Lanham on 30.01.26.
//

import Foundation
import SwiftUI
internal import CoreData
internal import Combine

class StatisticsViewModel: ObservableObject {
    @Published var todaySessions: [FocusSession] = []
    @Published var weekSessions: [FocusSession] = []
    @Published var monthSessions: [FocusSession] = []
    
    @Published var todayFocusTime: Int = 0
    @Published var weekFocusTime: Int = 0
    @Published var totalFocusTime: Int = 0
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    @Published var selectedTimeRange: TimeRange = .week
    
    private let context = PersistenceController.shared.container.viewContext
    
    enum TimeRange: String, CaseIterable {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }
    
    init() {
        fetchAllData()
    }
    
    // MARK: - Fetch Data
    
    func fetchAllData() {
        fetchTodaySessions()
        fetchWeekSessions()
        fetchMonthSessions()
        calculateStatistics()
        calculateStreaks()
    }
    
    private func fetchTodaySessions() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@ AND completed == true", startOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            todaySessions = try context.fetch(request)
            todayFocusTime = todaySessions.reduce(0) { $0 + Int($1.duration) }
        } catch {
            print("Error fetching today's sessions: \(error)")
        }
    }
    
    private func fetchWeekSessions() {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@ AND completed == true", startOfWeek as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        do {
            weekSessions = try context.fetch(request)
            weekFocusTime = weekSessions.reduce(0) { $0 + Int($1.duration) }
        } catch {
            print("Error fetching week sessions: \(error)")
        }
    }
    
    private func fetchMonthSessions() {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@ AND completed == true", startOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        do {
            monthSessions = try context.fetch(request)
        } catch {
            print("Error fetching month sessions: \(error)")
        }
    }
    
    private func calculateStatistics() {
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "completed == true")
        
        do {
            let allSessions = try context.fetch(request)
            totalFocusTime = allSessions.reduce(0) { $0 + Int($1.duration) }
        } catch {
            print("Error calculating total focus time: \(error)")
        }
    }
    
    private func calculateStreaks() {
        let calendar = Calendar.current
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "completed == true AND timerMode == %@", TimerMode.focus.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            
            // Group sessions by day
            var sessionsByDay: [Date: [FocusSession]] = [:]
            for session in sessions {
                let day = calendar.startOfDay(for: session.startTime ?? Date())
                if sessionsByDay[day] == nil {
                    sessionsByDay[day] = []
                }
                sessionsByDay[day]?.append(session)
            }
            
            // Calculate current streak
            var currentStreakCount = 0
            var checkDate = calendar.startOfDay(for: Date())
            
            while sessionsByDay[checkDate] != nil {
                currentStreakCount += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
            
            currentStreak = currentStreakCount
            
            // Calculate longest streak
            let sortedDays = sessionsByDay.keys.sorted(by: >)
            var longestStreakCount = 0
            var tempStreak = 0
            var lastDate: Date?
            
            for day in sortedDays {
                if let last = lastDate {
                    let daysBetween = calendar.dateComponents([.day], from: day, to: last).day ?? 0
                    if daysBetween == 1 {
                        tempStreak += 1
                    } else {
                        longestStreakCount = max(longestStreakCount, tempStreak)
                        tempStreak = 1
                    }
                } else {
                    tempStreak = 1
                }
                lastDate = day
            }
            
            longestStreak = max(longestStreakCount, tempStreak)
            
        } catch {
            print("Error calculating streaks: \(error)")
        }
    }
    
    // MARK: - Chart Data
    
    func getChartData() -> [ChartDataPoint] {
        switch selectedTimeRange {
        case .today:
            return getTodayChartData()
        case .week:
            return getWeekChartData()
        case .month:
            return getMonthChartData()
        case .all:
            return getAllTimeChartData()
        }
    }
    
    private func getTodayChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        var hourlyData: [Int: Int] = [:]
        
        // Initialize all hours with 0
        for hour in 0..<24 {
            hourlyData[hour] = 0
        }
        
        // Sum durations by hour
        for session in todaySessions {
            let hour = calendar.component(.hour, from: session.startTime ?? Date())
            hourlyData[hour, default: 0] += Int(session.duration) / 60 // Convert to minutes
        }
        
        return hourlyData.map { hour, minutes in
            ChartDataPoint(
                label: "\(hour):00",
                value: Double(minutes),
                date: calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
            )
        }.sorted { $0.date < $1.date }
    }
    
    private func getWeekChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dailyData: [Date: Int] = [:]
        
        // Initialize last 7 days with 0
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: calendar.startOfDay(for: Date()))!
            dailyData[date] = 0
        }
        
        // Sum durations by day
        for session in weekSessions {
            let day = calendar.startOfDay(for: session.startTime ?? Date())
            dailyData[day, default: 0] += Int(session.duration) / 60
        }
        
        return dailyData.map { date, minutes in
            ChartDataPoint(
                label: formatDayLabel(date),
                value: Double(minutes),
                date: date
            )
        }.sorted { $0.date < $1.date }
    }
    
    private func getMonthChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        var weeklyData: [Int: Int] = [:]
        
        // Initialize weeks
        for week in 0..<5 {
            weeklyData[week] = 0
        }
        
        // Sum durations by week
        for session in monthSessions {
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
            let weekOfMonth = calendar.dateComponents([.weekOfMonth], from: startOfMonth, to: session.startTime ?? Date()).weekOfMonth ?? 0
            weeklyData[weekOfMonth, default: 0] += Int(session.duration) / 60
        }
        
        return weeklyData.map { week, minutes in
            ChartDataPoint(
                label: "Week \(week + 1)",
                value: Double(minutes),
                date: Date()
            )
        }.sorted { $0.label < $1.label }
    }
    
    private func getAllTimeChartData() -> [ChartDataPoint] {
        // Simplified: show last 12 months
        let calendar = Calendar.current
        var monthlyData: [Date: Int] = [:]
        
        let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
        request.predicate = NSPredicate(format: "completed == true")
        
        do {
            let sessions = try context.fetch(request)
            
            for session in sessions {
                let month = calendar.date(from: calendar.dateComponents([.year, .month], from: session.startTime ?? Date()))!
                monthlyData[month, default: 0] += Int(session.duration) / 60
            }
            
            return monthlyData.map { date, minutes in
                ChartDataPoint(
                    label: formatMonthLabel(date),
                    value: Double(minutes),
                    date: date
                )
            }.sorted { $0.date < $1.date }
            
        } catch {
            print("Error fetching all time data: \(error)")
            return []
        }
    }
    
    // MARK: - Helpers
    
    private func formatDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func formatMonthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let date: Date
}
