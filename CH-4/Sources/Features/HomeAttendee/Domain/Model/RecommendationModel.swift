//
//  RecommendationModels.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation
import SwiftUI
import UIComponentsKit

// MARK: - Domain Models

public struct RecommendationModel: Identifiable, Equatable, Codable {
    public let id: String
    public let score: Decimal
    public let reasoning: String
    public let targetAttendee: TargetAttendeeModel

    public init(
        id: String, score: Decimal, reasoning: String,
        targetAttendee: TargetAttendeeModel
    ) {
        self.id = id
        self.score = score
        self.reasoning = reasoning
        self.targetAttendee = targetAttendee
    }

    // Computed property for score as percentage
    public var scorePercentage: Double {
        return Double(truncating: score as NSNumber) * 100
    }
}

public struct TargetAttendeeModel: Equatable, Codable {
    public let nickname: String
    public let profession: ProfessionModelRecommendation
    public let goalsCategory: GoalsCategoryModel
    public let linkedinUsername: String?
    public let photoLink: String
    public let shareableAnswers: [ShareableAnswerModel]

    public init(
        nickname: String,
        profession: ProfessionModelRecommendation,
        goalsCategory: GoalsCategoryModel,
        linkedinUsername: String?,
        photoLink: String,
        shareableAnswers: [ShareableAnswerModel]
    ) {
        self.nickname = nickname
        self.profession = profession
        self.goalsCategory = goalsCategory
        self.linkedinUsername = linkedinUsername
        self.photoLink = photoLink
        self.shareableAnswers = shareableAnswers
    }

    // Helper computed properties
    public var hasLinkedIn: Bool {
        return linkedinUsername != nil && !linkedinUsername!.isEmpty
    }

    public var linkedinUrl: String? {
        guard let username = linkedinUsername else { return nil }
        return "https://www.linkedin.com/in/\(username)"
    }
}

public struct ProfessionModelRecommendation: Equatable, Codable {
    public let name: String
    public let categoryName: String

    public init(name: String, categoryName: String) {
        self.name = name
        self.categoryName = categoryName
    }
}

public struct GoalsCategoryModel: Equatable, Codable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct ShareableAnswerModel: Equatable, Codable {
    public let question: String
    public let questionType: QuestionTypeResponse
    public let answerLabel: String?
    public let textValue: String?
    public let numberValue: Decimal?
    public let dateValue: String?
    public let rank: Int?

    public init(
        question: String,
        questionType: QuestionTypeResponse,
        answerLabel: String?,
        textValue: String?,
        numberValue: Decimal?,
        dateValue: String?,
        rank: Int?
    ) {
        self.question = question
        self.questionType = questionType
        self.answerLabel = answerLabel
        self.textValue = textValue
        self.numberValue = numberValue
        self.dateValue = dateValue
        self.rank = rank
    }

    // Helper computed properties
    public var displayValue: String {
        switch questionType {
        case .text:
            return textValue ?? answerLabel ?? ""
        case .number:
            if let numberValue = numberValue {
                return String(describing: numberValue)
            }
            return answerLabel ?? ""
        case .date:
            return dateValue ?? answerLabel ?? ""
        case .multipleChoice, .boolean:
            return answerLabel ?? ""
        case .ranking:
            if let rank = rank {
                return "Rank \(rank)"
            }
            return answerLabel ?? ""
        }
    }

    public var parsedDate: Date? {
        guard let dateValue = dateValue else { return nil }

        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd",
        ]

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateValue) {
                return date
            }
        }

        return nil
    }
}

extension RecommendationModel {
    func toParticipantCardData() -> ParticipantCardData {
        return ParticipantCardData(
            imageURL: targetAttendee.photoLink,
            fallbackImageName: "abg",
            name: targetAttendee.nickname,
            title: targetAttendee.profession.name,
            detailContent: AnyView(createDetailView()),
            onTap: {
                print("\(targetAttendee.nickname)'s card tapped")
                // Add any additional tap actions here
            }
        )

    }

    private func createDetailView() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal")
                    .font(AppFont.cardHead2)
                    .foregroundStyle(.white)

                Text(targetAttendee.goalsCategory.name)
                    .font(AppFont.cardText)
                    .foregroundStyle(AppColors.cardTextDetails)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 1)
                    )
            }

            // Connect section
            if let connectText = targetAttendee.linkedinUsername {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connect")
                        .font(AppFont.cardHead2)
                        .foregroundStyle(.white)

                    HStack {
                        Image(systemName: "link")
                            .font(AppFont.cardText)
                            .foregroundStyle(.white)
                        Text(connectText)
                            .font(AppFont.cardText)
                            .foregroundStyle(.white)
                        //                            Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.white)
                            .font(AppFont.cardText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 1)
                    )
                }
            }

            // Key Reasons section

            VStack(alignment: .leading, spacing: 12) {
                Text("Key Reason")
                    .font(AppFont.cardHead2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text(reasoning)
                        .foregroundStyle(.white)
                }

            }
        }

    }
}
