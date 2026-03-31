import Foundation
import SwiftData

actor SyncService {
    static let shared = SyncService()

    private var supabaseURL: String { AuthService.shared.supabaseURL }
    private var supabaseKey: String { AuthService.shared.supabaseKey }
    private var appId: String { AuthService.shared.appId }
    private var userId: String? { AuthService.shared.userId }

    // MARK: - Full Sync (on sign-in)

    @MainActor
    func syncAll(context: ModelContext) async {
        guard let uid = AuthService.shared.userId,
              AuthService.shared.isSignedIn else { return }

        #if DEBUG
        print("Starting full sync for user \(uid) [\(appId)]")
        #endif

        await pushSavedItems(context: context)
        await pushJournalEntries(context: context)
        await pushReadingPlanProgress(context: context)
        await pushStreakData()

        await pullSavedItems(context: context)
        await pullJournalEntries(context: context)
        await pullReadingPlanProgress(context: context)

        #if DEBUG
        print("Sync complete")
        #endif
    }

    // MARK: - Push Local -> Supabase

    @MainActor
    private func pushSavedItems(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        let descriptor = FetchDescriptor<SavedPassage>()
        guard let passages = try? context.fetch(descriptor) else { return }

        for passage in passages {
            let body: [String: Any] = [
                "id": passage.id.uuidString,
                "user_id": uid,
                "app_id": appId,
                "reference": passage.reference,
                "text": passage.text,
                "translation": passage.translation,
                "notes": passage.notes as Any,
                "saved_at": ISO8601DateFormatter().string(from: passage.savedAt)
            ]
            await upsert(table: "saved_items", body: body)
        }
        #if DEBUG
        print("  Pushed \(passages.count) saved items")
        #endif
    }

    @MainActor
    private func pushJournalEntries(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        let descriptor = FetchDescriptor<JournalEntry>()
        guard let entries = try? context.fetch(descriptor) else { return }

        for entry in entries {
            let body: [String: Any] = [
                "id": entry.id.uuidString,
                "user_id": uid,
                "app_id": appId,
                "reference": entry.reference,
                "mode": entry.mode,
                "response": entry.response,
                "reflection": entry.reflection as Any,
                "created_at": ISO8601DateFormatter().string(from: entry.createdAt)
            ]
            await upsert(table: "journal_entries", body: body)
        }
        #if DEBUG
        print("  Pushed \(entries.count) journal entries")
        #endif
    }

    @MainActor
    private func pushReadingPlanProgress(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        let descriptor = FetchDescriptor<ReadingPlanProgress>()
        guard let progress = try? context.fetch(descriptor) else { return }

        for plan in progress {
            let body: [String: Any] = [
                "user_id": uid,
                "app_id": appId,
                "plan_id": plan.planId,
                "completed_days": plan.completedDays,
                "started_at": ISO8601DateFormatter().string(from: plan.startedAt),
                "last_read_at": plan.lastReadAt.map { ISO8601DateFormatter().string(from: $0) } as Any
            ]
            await upsert(table: "reading_plan_progress", body: body, onConflict: "user_id,app_id,plan_id")
        }
        #if DEBUG
        print("  Pushed \(progress.count) reading plan progress")
        #endif
    }

    private func pushStreakData() async {
        let streak = StreakService.shared
        await AuthService.shared.updateProfile(
            streakCurrent: streak.currentStreak,
            streakLongest: streak.longestStreak,
            totalStudies: streak.totalStudies
        )
    }

    // MARK: - Pull Supabase -> Local

    @MainActor
    private func pullSavedItems(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        guard let data = await fetch(table: "saved_items", filter: "user_id=eq.\(uid)&app_id=eq.\(appId)") else { return }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

        let descriptor = FetchDescriptor<SavedPassage>()
        let existing = (try? context.fetch(descriptor))?.map { $0.id.uuidString } ?? []

        var pulled = 0
        for item in items {
            guard let idStr = item["id"] as? String,
                  !existing.contains(idStr),
                  let id = UUID(uuidString: idStr),
                  let reference = item["reference"] as? String,
                  let text = item["text"] as? String else { continue }

            let passage = SavedPassage(
                id: id,
                reference: reference,
                text: text,
                translation: item["translation"] as? String ?? "default",
                notes: item["notes"] as? String
            )
            if let dateStr = item["saved_at"] as? String {
                passage.savedAt = ISO8601DateFormatter().date(from: dateStr) ?? .now
            }
            context.insert(passage)
            pulled += 1
        }
        #if DEBUG
        print("  Pulled \(pulled) new saved items")
        #endif
    }

    @MainActor
    private func pullJournalEntries(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        guard let data = await fetch(table: "journal_entries", filter: "user_id=eq.\(uid)&app_id=eq.\(appId)") else { return }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

        let descriptor = FetchDescriptor<JournalEntry>()
        let existing = (try? context.fetch(descriptor))?.map { $0.id.uuidString } ?? []

        var pulled = 0
        for item in items {
            guard let idStr = item["id"] as? String,
                  !existing.contains(idStr),
                  let id = UUID(uuidString: idStr),
                  let reference = item["reference"] as? String,
                  let mode = item["mode"] as? String,
                  let response = item["response"] as? String else { continue }

            let entry = JournalEntry(
                id: id,
                reference: reference,
                mode: mode,
                response: response,
                reflection: item["reflection"] as? String
            )
            if let dateStr = item["created_at"] as? String {
                entry.createdAt = ISO8601DateFormatter().date(from: dateStr) ?? .now
            }
            context.insert(entry)
            pulled += 1
        }
        #if DEBUG
        print("  Pulled \(pulled) new journal entries")
        #endif
    }

    @MainActor
    private func pullReadingPlanProgress(context: ModelContext) async {
        guard let uid = AuthService.shared.userId else { return }

        guard let data = await fetch(table: "reading_plan_progress", filter: "user_id=eq.\(uid)&app_id=eq.\(appId)") else { return }
        guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

        let descriptor = FetchDescriptor<ReadingPlanProgress>()
        let existingPlans = (try? context.fetch(descriptor))?.map { $0.planId } ?? []

        var pulled = 0
        for item in items {
            guard let planId = item["plan_id"] as? String,
                  !existingPlans.contains(planId) else { continue }

            let progress = ReadingPlanProgress(planId: planId)
            if let days = item["completed_days"] as? [Int] {
                progress.completedDays = days
            }
            if let dateStr = item["started_at"] as? String {
                progress.startedAt = ISO8601DateFormatter().date(from: dateStr) ?? .now
            }
            context.insert(progress)
            pulled += 1
        }
        #if DEBUG
        print("  Pulled \(pulled) new reading plan progress")
        #endif
    }

    // MARK: - Supabase REST Helpers

    private func upsert(table: String, body: [String: Any], onConflict: String? = nil) async {
        let authService = AuthService.shared
        guard let token = authService.accessToken else { return }

        var urlStr = "\(supabaseURL)/rest/v1/\(table)"
        if let conflict = onConflict {
            urlStr += "?on_conflict=\(conflict)"
        }
        guard let url = URL(string: urlStr) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        _ = try? await URLSession.shared.data(for: request)
    }

    private func fetch(table: String, filter: String) async -> Data? {
        let authService = AuthService.shared
        guard let token = authService.accessToken else { return nil }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/\(table)?\(filter)") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { return nil }

        return data
    }
}
