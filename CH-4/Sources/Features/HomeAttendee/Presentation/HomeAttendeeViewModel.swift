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
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isShowError: Bool = false

    private var validateEventUseCase: ValidateEventUseCaseProtocol
    private var registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol

    public init(
        validateEventUseCase: ValidateEventUseCaseProtocol,
        registerAttendeeUseCase: RegisterAttendeeUseCaseProtocol
    ) {
        self.validateEventUseCase = validateEventUseCase
        self.registerAttendeeUseCase = registerAttendeeUseCase
    }

    public func handleScan(result: Result<ScanResult, ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let result):
            Task {
                await validateEvent(with: result.string)
            }
        case .failure(let error):
            isShowError = true
            errorMessage = error.localizedDescription

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
                isShowError = true
                errorMessage = error.localizedDescription
                print("Validation failed: \(error.localizedDescription)")
            }
        }
    }
}
