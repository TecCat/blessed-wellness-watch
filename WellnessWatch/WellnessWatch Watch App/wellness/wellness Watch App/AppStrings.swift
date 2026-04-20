// AppStrings.swift — Centralized UI localization (Chinese / English)
import Foundation

enum L {
    static var isEnglish: Bool {
        Locale.current.language.languageCode?.identifier == "en"
    }

    // MARK: - HomeView
    static var navTitleHome: String        { isEnglish ? "Breathing" : "呼吸練習" }
    static var minLabel: String            { isEnglish ? "min" : "分鐘" }

    // MARK: - Stress levels
    static var stressRelaxed: String       { isEnglish ? "Relaxed" : "放鬆" }
    static var stressMild: String          { isEnglish ? "Mild Stress" : "輕度緊張" }
    static var stressHigh: String          { isEnglish ? "High Stress" : "高度緊張" }
    static var stressMeasuring: String     { isEnglish ? "Measuring..." : "測量中..." }

    // MARK: - Breathing phases
    static var phaseInhale: String         { isEnglish ? "Inhale" : "吸氣" }
    static var phaseInhale2: String        { isEnglish ? "Inhale+" : "再吸！" }
    static var phaseHold: String           { isEnglish ? "Hold" : "屏氣" }
    static var phaseExhale: String         { isEnglish ? "Exhale" : "吐氣" }
    static var phaseRest: String           { isEnglish ? "Rest" : "放鬆" }

    // MARK: - BreathingView
    static var stopButton: String          { isEnglish ? "Stop" : "停止" }
    static var stopAlertTitle: String      { isEnglish ? "End session?" : "確定要結束練習？" }
    static var stopAlertContinue: String   { isEnglish ? "Continue" : "繼續" }
    static var stopAlertEnd: String        { isEnglish ? "End" : "結束" }

    // MARK: - PreviewView
    static var startButton: String         { isEnglish ? "Start" : "開始練習" }
    static var paceSlow: String            { isEnglish ? "Slow" : "慢速" }
    static var paceStandard: String        { isEnglish ? "Normal" : "標準" }
    static var paceFast: String            { isEnglish ? "Fast" : "快速" }
    static var paceTitle: String           { isEnglish ? "Pace" : "步調" }
    static var howAreYou: String           { isEnglish ? "How do you feel?" : "目前狀態？" }
    static var feelTense: String           { isEnglish ? "Tense" : "緊張" }
    static var feelNeutral: String         { isEnglish ? "Neutral" : "普通" }
    static var feelCalm: String            { isEnglish ? "Calm" : "放鬆" }
    static var rhythmPreview: String       { isEnglish ? "Rhythm" : "節奏預覽" }
    static var durationLabel: String       { isEnglish ? "Duration" : "時長" }

    // MARK: - ResultView
    static var sessionDone: String         { isEnglish ? "Done!" : "練習完成！" }
    static var sessionStopped: String      { isEnglish ? "Session Ended" : "練習結束" }
    static var statDuration: String        { isEnglish ? "Duration" : "時長" }
    static var statCycles: String          { isEnglish ? "Cycles" : "完成輪" }
    static var statMode: String            { isEnglish ? "Mode" : "模式" }
    static var doneButton: String          { isEnglish ? "Done" : "完成" }
    static var aiCoachLabel: String        { isEnglish ? "Coach" : "教練建議" }
    static var nextSession: String         { isEnglish ? "Next Session" : "下次練習" }

    // MARK: - HistoryView
    static var navTitleHistory: String     { isEnglish ? "History" : "練習紀錄" }
    static var clearAll: String            { isEnglish ? "Clear All" : "清除全部" }
    static var clearConfirm: String        { isEnglish ? "Clear all records?" : "確定清除所有紀錄？" }
    static var clearCancel: String         { isEnglish ? "Cancel" : "取消" }
    static var emptyHistory: String        { isEnglish ? "No sessions yet" : "尚無練習紀錄" }

    // MARK: - StatsView
    static var navTitleStats: String       { isEnglish ? "Statistics" : "練習統計" }
    static var statTotalSessions: String   { isEnglish ? "Sessions" : "總次數" }
    static var statTotalMinutes: String    { isEnglish ? "Minutes" : "總分鐘" }
    static var statStreak: String          { isEnglish ? "Streak" : "連續天" }
    static var last7Days: String           { isEnglish ? "Last 7 Days" : "近 7 天" }
    static var favouritePattern: String    { isEnglish ? "Favourite" : "最常練習" }

    // MARK: - ReminderView
    static var navTitleReminder: String    { isEnglish ? "Reminder" : "提醒設定" }
    static var dailyReminder: String       { isEnglish ? "Daily Reminder" : "每日提醒" }
    static var reminderTime: String        { isEnglish ? "Reminder Time" : "提醒時間" }
    static var hourLabel: String           { isEnglish ? "Hour" : "小時" }
    static var minuteLabel: String         { isEnglish ? "Minute" : "分鐘" }
    static var reminderSet: String         { isEnglish ? "Reminder set for %02d:%02d daily" : "每天 %02d:%02d 提醒練習" }
    static var reminderOff: String         { isEnglish ? "No reminder set" : "未設定提醒" }
    static var reminderSimNote: String     { isEnglish ? "(Simulator: no push, works on device)" : "(模擬器不推送通知，實機有效)" }

    // MARK: - Pattern names & effects (keep originals, add English)
    static func patternName(_ id: String) -> String {
        guard isEnglish else { return "" } // empty = use original Chinese name
        switch id {
        case "4-7-8":              return "4-7-8 Breathing"
        case "box":                return "Box Breathing"
        case "diaphragmatic":      return "Diaphragmatic"
        case "resonance":          return "Resonance"
        case "physiological-sigh": return "Physiological Sigh"
        default:                   return id
        }
    }

    static func patternEffect(_ id: String) -> String {
        guard isEnglish else { return "" }
        switch id {
        case "4-7-8":              return "Relax · Sleep"
        case "box":                return "Focus · Composure"
        case "diaphragmatic":      return "Daily Stress Relief"
        case "resonance":          return "Improve HRV"
        case "physiological-sigh": return "Instant Calm · Double Inhale"
        default:                   return ""
        }
    }

    // MARK: - Result encouragement
    static func encouragement(_ patternID: String) -> String {
        if isEnglish {
            switch patternID {
            case "4-7-8":              return "Nervous system calmed. Ready for good sleep 🌙"
            case "box":                return "Focus reset. Stay sharp 💪"
            case "diaphragmatic":      return "Diaphragm activated. Stress is fading 🌿"
            case "resonance":          return "HRV resonance reached. Autonomic balance improving 💚"
            case "physiological-sigh": return "Alveoli reopened. Parasympathetic activated ✨"
            default:                   return "Well done. Keep going 👏"
            }
        } else {
            switch patternID {
            case "4-7-8":              return "神經系統已放鬆，準備好迎接好眠 🌙"
            case "box":                return "專注力已重置，保持清醒狀態 💪"
            case "diaphragmatic":      return "橫膈膜充分活動，壓力正在消散 🌿"
            case "resonance":          return "HRV 共振達成，自律神經趨於平衡 💚"
            case "physiological-sigh": return "肺泡已重開，副交感神經啟動 ✨"
            default:                   return "做得很好，繼續保持 👏"
            }
        }
    }
}
