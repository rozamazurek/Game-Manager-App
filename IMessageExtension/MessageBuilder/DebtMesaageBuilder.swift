import Foundation
import Messages
import UIKit

struct DebtMessageBuilder {

    static func makeMessage(
        debt: Debt,
        from: Player,
        to: Player
    ) -> MSMessage {

        let message = MSMessage()

        let layout = MSMessageTemplateLayout()
        layout.caption = " Nowy dług"
        layout.subcaption = "\(from.nick) → \(to.nick)"
        layout.trailingCaption = "\(debt.amount) zł"
        layout.image = UIImage(systemName: "creditcard")

        message.layout = layout

        var components = URLComponents()
        components.scheme = "myapp"
        components.host = "debt"
        components.queryItems = [
            URLQueryItem(name: "debtId", value: debt.id.uuidString),
            URLQueryItem(name: "from", value: from.nick),
            URLQueryItem(name: "to", value: to.nick),
            URLQueryItem(name: "amount", value: "\(debt.amount)")
        ]

        message.url = components.url
        message.summaryText = "Dług \(debt.amount) zł"

        return message
    }
}
