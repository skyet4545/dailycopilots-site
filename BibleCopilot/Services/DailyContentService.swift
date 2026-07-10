import Foundation

/// Fetches the day's "Today" content (verse + reflection + a suggested first
/// question) from the shared Supabase `daily_content` table. Populated server-side
/// daily by the `copilot-daily-content` task, so the app just reads it.
/// Best-effort and non-blocking: on any failure returns nil and the caller falls
/// back to its own default so the Today screen can never break.
struct DailyContent: Codable {
    let headline: String?          // e.g. "Psalm 46:10"
    let passage: String?           // the verbatim quote
    let reflection: String?        // 2-3 sentence application
    let suggested_question: String? // one-tap prompt that opens the ask flow
    let source: String?            // e.g. "ESV"
}

final class DailyContentService {
    static let shared = DailyContentService()

    private let base = "https://fseqgcebvxiqmzngxhre.supabase.co/rest/v1/daily_content"
    // Same anon key the AnalyticsService uses (read-only REST access).
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA"
    private let appIdentifier = "bible_copilot"

    private var todayET: String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "America/New_York")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    /// Today's content if present, else the most recent row, else nil.
    func fetchToday() async -> DailyContent? {
        if let today = await fetch(dateFilter: "content_date=eq.\(todayET)") { return today }
        return await fetch(dateFilter: nil) // fallback: latest row
    }

    private func fetch(dateFilter: String?) async -> DailyContent? {
        var comps = "\(base)?app_identifier=eq.\(appIdentifier)&select=headline,passage,reflection,suggested_question,source&order=content_date.desc&limit=1"
        if let dateFilter { comps += "&\(dateFilter)" }
        guard let url = URL(string: comps) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let rows = try JSONDecoder().decode([DailyContent].self, from: data)
            return rows.first
        } catch {
            return nil
        }
    }
}
