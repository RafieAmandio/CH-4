import SwiftUI

struct DynamicQuestionView: View {
    let question: QuestionDTO
    @ObservedObject var answerManager: QuestionAnswerManager
    @State private var otherText: String = ""
    @State private var showingOtherField: Bool = false

    init(question: QuestionDTO, answerManager: QuestionAnswerManager) {
        self.question = question
        self.answerManager = answerManager
    }

    var body: some View {
        switch question.type {
        case .singleChoice:
            StyledSingleSelectView(
                question: question, answerManager: answerManager)
        case .multiSelect:
            StyledMultiSelectView(
                question: question, answerManager: answerManager)
        case .rankedChoice:
            RankedChoiceView(question: question, answerManager: answerManager)
        case .freeText:
            StyledTextFieldView(question: question, answerManager: answerManager)
        case .number:
            NumberInputView(question: question, answerManager: answerManager)
        case .scale:
            ScaleInputView(question: question, answerManager: answerManager)
        case .date:
            DateInputView(question: question, answerManager: answerManager)
        }

    }
}


// MARK: - Free Text View
struct FreeTextView: View {
    let question: QuestionDTO
    let answerManager: QuestionAnswerManager
    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                question.placeholder ?? "Enter your answer", text: $text,
                axis: .vertical
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .lineLimit(3...6)
            .onChange(of: text) { newValue in
                answerManager.setFreeText(
                    questionId: question.id, text: newValue)
            }

            if let maxLen = question.constraints.textMaxLen {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxLen)")
                        .font(.caption)
                        .foregroundColor(
                            text.count > maxLen ? .red : .secondary)
                }
            }
        }
    }
}

// MARK: - Number Input View
struct NumberInputView: View {
    let question: QuestionDTO
    let answerManager: QuestionAnswerManager
    @State private var numberValue: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                question.placeholder ?? "Enter number", value: $numberValue,
                format: .number
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .onChange(of: numberValue) { newValue in
                answerManager.setNumber(
                    questionId: question.id, number: newValue)
            }

            if let min = question.constraints.numberMin,
                let max = question.constraints.numberMax
            {
                Text(
                    "Range: \(min, specifier: "%.1f") - \(max, specifier: "%.1f")"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Scale Input View
struct ScaleInputView: View {
    let question: QuestionDTO
    let answerManager: QuestionAnswerManager
    @State private var scaleValue: Double = 5

    var body: some View {
        VStack(alignment: .leading) {
            let minValue = question.constraints.numberMin ?? 1
            let maxValue = question.constraints.numberMax ?? 10

            Slider(
                value: $scaleValue, in: minValue...maxValue,
                step: question.constraints.numberStep ?? 1
            )
            .onChange(of: scaleValue) { newValue in
                answerManager.setNumber(
                    questionId: question.id, number: newValue)
            }

            HStack {
                Text("\(Int(minValue))")
                Spacer()
                Text("Current: \(Int(scaleValue))")
                Spacer()
                Text("\(Int(maxValue))")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Date Input View
struct DateInputView: View {
    let question: QuestionDTO
    let answerManager: QuestionAnswerManager
    @State private var selectedDate = Date()

    var body: some View {
        DatePicker(
            "Select date", selection: $selectedDate, displayedComponents: .date
        )
        .datePickerStyle(WheelDatePickerStyle())
        .onChange(of: selectedDate) { newValue in
            answerManager.setDate(questionId: question.id, date: newValue)
        }
    }
}

// MARK: - Ranked Choice View
struct RankedChoiceView: View {
    let question: QuestionDTO
    let answerManager: QuestionAnswerManager
    @State private var rankedOptions: [AnswerOptionDTO] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Drag to reorder by preference")
                .font(.caption)
                .foregroundColor(.secondary)

            // Initialize ranked options on appear
            ForEach(Array(rankedOptions.enumerated()), id: \.element.id) {
                index, option in
                HStack {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(option.label)
                    Spacer()

                    // Move up/down buttons for ranking
                    VStack {
                        Button(action: {
                            moveOption(from: index, to: max(0, index - 1))
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.caption)
                        }
                        .disabled(index == 0)

                        Button(action: {
                            moveOption(
                                from: index,
                                to: min(rankedOptions.count - 1, index + 1))
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .disabled(index == rankedOptions.count - 1)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .onAppear {
            rankedOptions = question.sortedAnswerOptions
        }
    }

    private func moveOption(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }

        let option = rankedOptions.remove(at: sourceIndex)
        rankedOptions.insert(option, at: destinationIndex)

        // Update answer manager with new rankings
        updateRankings()
    }

    private func updateRankings() {
        for (index, option) in rankedOptions.enumerated() {
            answerManager.setRankedChoice(
                questionId: question.id,
                optionId: option.id,
                rank: index + 1
            )
        }
    }
}

//struct MultiSelectTestView: View {
//    @StateObject private var answerManager = QuestionAnswerManager()
//
//    let testQuestion = MockQuestionProvider.getQuestion(ofType: .multiSelect)!
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Multi-Select Test")
//                .font(.title)
//
//            DynamicQuestionView(question: testQuestion, answerManager: answerManager)
//
//            // Debug section
//            VStack(alignment: .leading) {
//                Text("Debug Info:")
//                    .font(.headline)
//
//                Text("Selected Count: \(answerManager.getAnswers(for: testQuestion.id).count)")
//
//                Text("Selected Options:")
//                ForEach(answerManager.getAnswers(for: testQuestion.id), id: \.questionId) { answer in
//                    Text("- \(answer.answerOptionId ?? "No ID")")
//                }
//
//                Button("Clear All") {
//                    answerManager.clearAnswers(for: testQuestion.id)
//                }
//                .foregroundColor(.red)
//            }
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(8)
//
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//// Use this for testing
//struct MultiSelectTestView_Previews: PreviewProvider {
//    static var previews: some View {
//        MultiSelectTestView()
//    }
//}
//
