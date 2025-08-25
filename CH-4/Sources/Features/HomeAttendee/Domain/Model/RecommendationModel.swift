//
//  RecommendationModels.swift
//  CH-4
//
//  Created by Dwiki on 25/08/25.
//

import Foundation
import SwiftUI

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

public struct TargetAttendeeModel: Equatable, Codable{
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

public struct GoalsCategoryModel: Equatable , Codable{
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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with name and profession
                VStack(alignment: .leading, spacing: 8) {
                    Text(targetAttendee.nickname)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text(targetAttendee.profession.name)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    Text(targetAttendee.profession.categoryName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Match Score
                VStack(alignment: .leading, spacing: 8) {
                    Text("Match Score")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Text("\(Int(scorePercentage))%")
                            .font(.title2.bold())
                            .foregroundColor(.green)

                        Spacer()

                        // Score bar
                        ProgressView(value: scorePercentage / 100)
                            .progressViewStyle(
                                LinearProgressViewStyle(tint: .green)
                            )
                            .frame(width: 100)
                    }
                }

                // Goals
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goals")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(targetAttendee.goalsCategory.name)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(8)
                }

                // LinkedIn (if available)
                if targetAttendee.hasLinkedIn {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Connect")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.blue)

                            Text("LinkedIn Profile")
                                .foregroundColor(.white.opacity(0.8))

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            if let url = targetAttendee.linkedinUrl,
                                let linkedinURL = URL(string: url)
                            {
                                UIApplication.shared.open(linkedinURL)
                            }
                        }
                    }
                }

                // Reasoning for recommendation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why We Recommend")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(reasoning)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }

                // Shareable answers (if any)
                if !targetAttendee.shareableAnswers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Common Interests")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                            ], spacing: 8
                        ) {
                            ForEach(
                                Array(
                                    targetAttendee.shareableAnswers.prefix(4)
                                        .enumerated()), id: \.offset
                            ) { _, answer in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(answer.question)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(2)

                                    Text(answer.displayValue)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
