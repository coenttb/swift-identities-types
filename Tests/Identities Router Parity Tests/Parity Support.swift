//
//  Parity Support.swift
//  swift-identities-types
//
//  Batch-0 wire-shape parity corpus support (url-routing-stack migration).
//

import Foundation
import Testing
import URL_Routing_Test_Support

/// Re-serializes JSON-object body lines with sorted keys so multi-key
/// `Body(.json(...))` payloads (plain `JSONEncoder()`, unordered keys on
/// Darwin) cannot key-order-flap between runs. Marker: `body(utf8/sorted-keys):`.
/// Sites: MFA JSON bodies (TOTP verify/disable, SMS, Email, WebAuthn,
/// BackupCodes verify).
func sortJSONBodyLines(_ corpus: String) -> String {
    corpus
        .split(separator: "\n", omittingEmptySubsequences: false)
        .map { line -> String in
            let prefix = "body(utf8): {"
            guard line.hasPrefix(prefix) else { return String(line) }
            let json = String(line.dropFirst("body(utf8): ".count))
            guard
                let object = try? JSONSerialization.jsonObject(with: Data(json.utf8)),
                let sorted = try? JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                ),
                let text = String(data: sorted, encoding: .utf8)
            else { return String(line) }
            return "body(utf8/sorted-keys): \(text)"
        }
        .joined(separator: "\n")
}

/// Compares a generated corpus against its Swift-embedded reference document.
func assertParity(
    _ corpus: String,
    fixture name: String
) throws {
    let actual = sortJSONBodyLines(corpus)
    guard let expected = ParityCorpus[name] else {
        Issue.record("No Swift-embedded parity corpus named \(name)")
        return
    }
    guard actual != expected else { return }
    let report = difference(expected: expected, actual: actual)
    Issue.record(Comment(rawValue: "Parity mismatch for \(name):\n\(report)"))
}

private func difference(expected: String, actual: String) -> String {
    let expectedLines = expected.split(separator: "\n", omittingEmptySubsequences: false)
    let actualLines = actual.split(separator: "\n", omittingEmptySubsequences: false)
    var differences: [String] = []
    for index in 0..<max(expectedLines.count, actualLines.count) {
        let expected = index < expectedLines.count ? expectedLines[index] : "<absent>"
        let actual = index < actualLines.count ? actualLines[index] : "<absent>"
        if expected != actual {
            differences.append("line \(index + 1):\n  - \(expected)\n  + \(actual)")
        }
        if differences.count >= 40 {
            differences.append("… (further differences truncated)")
            break
        }
    }
    return differences.joined(separator: "\n")
}
