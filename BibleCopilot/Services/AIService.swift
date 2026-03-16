import Foundation

class AIService {
    static let shared = AIService()

    func askQuestion(_ question: String) async -> String {
        let lowerQ = question.lowercased()

        if lowerQ.contains("john 3:16") || lowerQ.contains("john 3") {
            return "John 3:16 says: \"For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.\" This verse is often called the Gospel in miniature. It reveals God's motivation (love), His action (giving His Son), the scope (the whole world), the condition (belief), and the promise (eternal life)."
        } else if lowerQ.contains("faith") {
            return "Hebrews 11:1 defines faith as \"confidence in what we hope for and assurance about what we do not see.\" Faith is not blind - it's trust based on God's character and His revealed Word. Romans 10:17 tells us that \"faith comes from hearing the message, and the message is heard through the word about Christ.\""
        } else if lowerQ.contains("prayer") || lowerQ.contains("pray") {
            return "Jesus taught us to pray in Matthew 6:9-13 with what we call the Lord's Prayer. Prayer is conversation with God - bring your requests (Philippians 4:6), confess your sins (1 John 1:9), give thanks (1 Thessalonians 5:18), and intercede for others (James 5:16). The key is approaching God with faith and humility."
        } else if lowerQ.contains("salvation") || lowerQ.contains("saved") || lowerQ.contains("save") {
            return "Ephesians 2:8-9 tells us: \"For it is by grace you have been saved, through faith - and this is not from yourselves, it is the gift of God - not by works, so that no one can boast.\" Salvation comes through repentance and faith in Jesus Christ, who died for our sins and rose again (Romans 10:9-10)."
        } else if lowerQ.contains("love") {
            return "1 Corinthians 13 is the great \"love chapter\" of the Bible. John 3:16 shows God's love for us, and 1 John 4:19 says \"We love because he first loved us.\" Jesus said the greatest commandments are to love God and love your neighbor (Matthew 22:37-39)."
        } else {
            return "That's a meaningful Bible question! Scripture has much to say on this topic. I'd encourage you to search using a concordance or Bible app for key words related to your question. Reading the surrounding context of any verse is essential for proper interpretation. Would you like to ask a more specific question so I can point you to relevant passages?"
        }
    }
}
