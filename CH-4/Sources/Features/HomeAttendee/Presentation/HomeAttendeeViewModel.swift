//
//  HomeAttendeeViewModel.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import CodeScanner
import Foundation

public final class HomeAttendeeViewModel: ObservableObject {
    @Published var isShowingScanner = false

    @Published var isShowingEventDetail: Bool = false
    @Published var eventDetail: EventValidateModel?

    private var validateEventUseCase: ValidateEventUseCaseProtocol

    public init(validateEventUseCase: ValidateEventUseCaseProtocol) {
        self.validateEventUseCase = validateEventUseCase
    }

    public func handleScan(result: Result<ScanResult, ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let result):
            Task {
                await validateEvent(with: result.string)
            }
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func validateEvent(with code: String) {

        Task {
            do {
                let data = try await validateEventUseCase.execute(code: code)
                eventDetail = data
                self.isShowingEventDetail = true
            } catch {
                print("Validation failed: \(error.localizedDescription)")
            }
        }

    }
}
