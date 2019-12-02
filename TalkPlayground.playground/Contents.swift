import Foundation

func validateAddress(_ candidate: String) -> Bool {
//    let generalRegex = "(.*)\\s(\\d+)(\\s(.*))?"
    let doRegex = "(.*)\\s(\\#?\\d+)(\\s(.*))?"
    let currentRegex = doRegex.trimmingCharacters(in: .whitespacesAndNewlines)
    let addressPredicate = NSPredicate(format: "SELF MATCHES %@", currentRegex)
    return addressPredicate.evaluate(with: candidate)
}

print(validateAddress("lober #2134"))
print("lober #2134".replacingOccurrences(of: "#", with: ""))
