//
//  ReceiptParser.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import Foundation

/// Parser for extracting drink information from receipt text
/// Supports both English and Chinese (Simplified + Traditional)
class ReceiptParser {
    
    // MARK: - Brand Patterns (Fuzzy Matching)
    
    private let brandPatterns: [(keywords: [String], brandName: String)] = [
        // CoCo
        (["coco", "cocofresh", "coco fresh", "都可", "coco tea"], "CoCo Fresh Tea & Juice"),
        // Gong Cha
        (["gong cha", "gongcha", "贡茶", "貢茶"], "Gong Cha"),
        // Tiger Sugar
        (["tiger sugar", "tigersugar", "老虎堂", "tiger"], "Tiger Sugar"),
        // Kung Fu Tea
        (["kung fu tea", "kungfu tea", "kung fu", "kungfu", "功夫茶"], "Kung Fu Tea"),
        // It's Boba Time
        (["boba time", "it's boba time", "its boba time", "波霸时光", "波霸時光"], "It's Boba Time"),
        // Nayuki
        (["nayuki", "奈雪", "奈雪的茶"], "Nayuki"),
        // ShareTea
        (["sharetea", "share tea", "歇脚亭"], "ShareTea"),
        // Happy Lemon
        (["happy lemon", "happylemon", "快乐柠檬", "快樂檸檬"], "Happy Lemon"),
        // The Alley
        (["the alley", "alley", "鹿角巷"], "The Alley"),
        // Yi Fang
        (["yi fang", "yifang", "一芳"], "Yi Fang")
    ]
    
    // MARK: - Sugar Level Patterns (Bilingual)
    
    private let sugarPatterns: [(SugarLevel, [String])] = [
        // No sugar - check first as it's most specific
        (.none, [
            // English - various formats
            "no sugar", "sugar free", "zero sugar", "0% sugar", "unsweetened", "sugar 0%", "0 sugar",
            "sugar: 0%", "sugar:0%", "sugar - 0%", "sugar-0%", "0%sugar",
            // Standalone percentage
            "0%",
            // Simplified Chinese
            "无糖", "不加糖", "0糖", "零糖",
            // Traditional Chinese
            "無糖"
        ]),
        // Light sugar (30%)
        (.light, [
            // English - various formats
            "light sugar", "30% sugar", "sugar 30%", "less sweet", "slightly sweet", "1/3 sugar",
            "sugar: 30%", "sugar:30%", "sugar - 30%", "sugar-30%", "30%sugar", "30 % sugar",
            "25% sugar", "sugar 25%", "sugar: 25%",
            // Standalone percentages
            "30%", "25%", "30 %", "25 %",
            // Simplified Chinese
            "微糖", "三分糖", "少少糖", "3分糖",
            // Traditional Chinese
            "微糖", "三分糖"
        ]),
        // Half sugar (50%)
        (.less, [
            // English - various formats with many variations for 50%
            "half sugar", "50% sugar", "sugar 50%", "half sweet", "1/2 sugar", "med sugar", "medium sugar",
            "sugar: 50%", "sugar:50%", "sugar - 50%", "sugar-50%", "50%sugar", "50 % sugar",
            "50 percent", "sugar 50 %", "50% sweet", "sweet 50%",
            "45% sugar", "sugar 45%", "55% sugar", "sugar 55%",
            // Standalone percentages - most common format
            "50%", "50 %", "45%", "55%",
            // Simplified Chinese
            "半糖", "五分糖", "5分糖",
            // Traditional Chinese
            "半糖", "五分糖"
        ]),
        // Regular sugar (70%)
        (.regular, [
            // English - various formats
            "regular sugar", "70% sugar", "sugar 70%", "normal sugar", "standard sugar", "less sugar",
            "sugar: 70%", "sugar:70%", "sugar - 70%", "sugar-70%", "70%sugar", "70 % sugar",
            "75% sugar", "sugar 75%", "65% sugar", "sugar 65%",
            // Standalone percentages
            "70%", "75%", "65%", "70 %", "75 %",
            // Simplified Chinese
            "正常糖", "七分糖", "少糖", "7分糖",
            // Traditional Chinese
            "正常糖", "七分糖"
        ]),
        // Extra/Full sugar (100%)
        (.extra, [
            // English - various formats
            "extra sugar", "100% sugar", "sugar 100%", "full sugar",
            "sugar: 100%", "sugar:100%", "sugar - 100%", "sugar-100%", "100%sugar", "100 % sugar",
            "90% sugar", "sugar 90%", "95% sugar", "sugar 95%",
            // Standalone percentages
            "100%", "90%", "95%", "100 %",
            // Simplified Chinese
            "全糖", "十分糖", "多糖", "10分糖", "满糖",
            // Traditional Chinese
            "全糖", "十分糖", "滿糖"
        ])
    ]
    
    // MARK: - Ice Level Patterns (Bilingual)
    
    private let icePatterns: [(IceLevel, [String])] = [
        // No ice
        (.none, [
            // English - various formats
            "no ice", "hot", "without ice", "room temp", "room temperature", "warm", "ice free",
            "noice", "no-ice", "ice: no", "ice:no", "0% ice", "zero ice",
            // Simplified Chinese
            "去冰", "热饮", "常温", "温", "热", "无冰", "不加冰",
            // Traditional Chinese
            "去冰", "熱飲", "常溫", "溫", "熱", "無冰"
        ]),
        // Less ice
        (.less, [
            // English - various formats including common OCR variations
            "less ice", "light ice", "easy ice", "little ice", "half ice",
            "lessice", "less  ice", "lite ice", "liteice", "low ice",
            "less-ice", "ice: less", "ice:less", "50% ice",
            // Simplified Chinese
            "少冰", "微冰",
            // Traditional Chinese
            "少冰", "微冰"
        ]),
        // Regular ice
        (.regular, [
            // English - various formats
            "regular ice", "normal ice", "standard ice",
            "regularice", "reg ice", "ice: regular", "ice:regular", "100% ice",
            // Simplified Chinese
            "正常冰", "标准冰",
            // Traditional Chinese
            "正常冰", "標準冰"
        ]),
        // Extra ice
        (.extra, [
            // English
            "extra ice", "more ice", "lots of ice",
            // Simplified Chinese
            "多冰", "加冰",
            // Traditional Chinese
            "多冰", "加冰"
        ])
    ]
    
    // MARK: - Size Patterns (Bilingual)
    
    private let sizePatterns: [(DrinkSize, [String])] = [
        // Small
        (.small, [
            // English
            "small", "sm", "s size", "(s)",
            // Simplified Chinese
            "小杯", "小",
            // Traditional Chinese
            "小杯", "小"
        ]),
        // Medium
        (.medium, [
            // English
            "medium", "med", "m size", "(m)", "regular", "standard",
            // Simplified Chinese
            "中杯", "中",
            // Traditional Chinese
            "中杯", "中"
        ]),
        // Large
        (.large, [
            // English
            "large", "lg", "l size", "(l)", "big",
            // Simplified Chinese
            "大杯", "大",
            // Traditional Chinese
            "大杯", "大"
        ])
    ]
    
    // MARK: - Bubble/Boba Patterns (Bilingual)
    
    private let bubblePatterns: [(BubbleLevel, [String])] = [
        // No bubble
        (.none, [
            // English
            "no boba", "no pearl", "no tapioca", "no topping", "without boba", "without pearl",
            // Simplified Chinese
            "不加珍珠", "去珍珠", "无珍珠", "不要珍珠", "不加波霸", "去波霸",
            // Traditional Chinese
            "不加珍珠", "去珍珠", "無珍珠", "不要珍珠"
        ]),
        // Regular bubble
        (.regular, [
            // English
            "boba", "pearl", "tapioca", "bubble", "with boba", "with pearl", "add boba", "add pearl",
            // Simplified Chinese
            "珍珠", "波霸", "加珍珠", "加波霸",
            // Traditional Chinese
            "珍珠", "波霸", "加珍珠"
        ]),
        // Extra bubble
        (.extra, [
            // English
            "extra boba", "extra pearl", "double boba", "double pearl", "more boba", "more pearl",
            // Simplified Chinese
            "多珍珠", "双倍珍珠", "加倍珍珠", "多波霸", "双倍波霸",
            // Traditional Chinese
            "多珍珠", "雙倍珍珠", "加倍珍珠", "多波霸"
        ])
    ]
    
    // MARK: - Price Patterns
    
    // English/USD price patterns
    private let usdPricePattern = #"\$\s*(\d{1,3}(?:\.\d{1,2})?)"#
    
    // Chinese/CNY price patterns
    private let cnyPricePattern = #"[¥￥]\s*(\d{1,3}(?:\.\d{1,2})?)"#
    private let yuanPricePattern = #"(\d{1,3}(?:\.\d{1,2})?)\s*元"#
    
    // Generic price pattern (number with decimal)
    private let genericPricePattern = #"(\d{1,3}\.\d{2})"#
    
    // Price context keywords for total
    private let totalKeywordsEN = ["total", "subtotal", "amount due", "grand total", "balance"]
    private let totalKeywordsZH = ["合计", "总计", "小计", "金额", "总价", "應付", "应付", "總計"]
    
    // MARK: - Drink Name Patterns
    
    private let drinkKeywordsEN = [
        "milk tea", "boba", "pearl", "bubble tea", "taro", "matcha", "brown sugar",
        "oolong", "jasmine", "green tea", "black tea", "latte", "smoothie", "slush",
        "fruit tea", "cheese", "cream", "tiger", "tea", "coffee", "fresh", "juice",
        "peach", "grape", "strawberry", "mango", "passion fruit", "lychee", "honeydew",
        "wintermelon", "thai", "yakult", "yogurt", "pudding", "jelly", "almond",
        "coconut", "caramel", "vanilla", "chocolate", "cocoa", "mocha"
    ]
    
    private let drinkKeywordsZH = [
        "奶茶", "珍珠", "波霸", "芋头", "芋頭", "抹茶", "黑糖", "乌龙", "烏龍",
        "茉莉", "绿茶", "綠茶", "红茶", "紅茶", "拿铁", "拿鐵", "冰沙", "水果茶",
        "芝士", "奶盖", "奶蓋", "虎纹", "虎紋", "鲜奶", "鮮奶", "椰", "芒果", "草莓",
        "蜜瓜", "冬瓜", "百香", "荔枝", "葡萄", "桃", "柠檬", "檸檬", "养乐多", "養樂多",
        "布丁", "果冻", "果凍", "杏仁", "可可", "焦糖", "香草"
    ]
    
    // Percentage pattern for sugar levels
    private let percentagePattern = #"(\d{1,3})\s*%"#
    
    // MARK: - Public API
    
    /// Parse receipt text and extract drink information
    func parse(_ text: String) -> ParsedReceipt {
        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let lowercasedText = text.lowercased()
        
        // Extract brand
        let brandName = extractBrand(from: lowercasedText, originalText: text)
        
        // Extract all drink items
        let items = extractDrinkItems(from: lines)
        
        // Extract total price
        let totalPrice = extractTotalPrice(from: lines)
        
        return ParsedReceipt(
            brandName: brandName,
            matchedBrandName: brandName, // Will be matched to actual brand in the view
            items: items,
            totalPrice: totalPrice,
            rawText: text
        )
    }
    
    // MARK: - Brand Extraction
    
    private func extractBrand(from lowercasedText: String, originalText: String) -> String? {
        for (keywords, brandName) in brandPatterns {
            for keyword in keywords {
                // For Chinese characters, search in original text
                if keyword.containsChineseCharacters {
                    if originalText.contains(keyword) {
                        return brandName
                    }
                } else {
                    // For English, search in lowercased text
                    if lowercasedText.contains(keyword.lowercased()) {
                        return brandName
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: - Multi-Drink Extraction
    
    private func extractDrinkItems(from lines: [String]) -> [ParsedReceiptItem] {
        var items: [ParsedReceiptItem] = []
        var currentDrinkName: String?
        var currentPrice: Double?
        var currentSize: DrinkSize?
        var currentSugarLevel: SugarLevel?
        var currentIceLevel: IceLevel?
        var currentBubbleLevel: BubbleLevel?
        
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            
            // Check if this line contains a drink name
            if let drinkName = extractDrinkNameFromLine(line) {
                // If we have a previous drink, save it with defaults
                if let name = currentDrinkName {
                    items.append(ParsedReceiptItem(
                        drinkName: name,
                        price: currentPrice,
                        size: currentSize ?? .medium,             // Default: medium
                        sugarLevel: currentSugarLevel ?? .less,   // Default: half sugar
                        iceLevel: currentIceLevel ?? .less,       // Default: less ice
                        bubbleLevel: currentBubbleLevel ?? .none // Default: no bubble
                    ))
                }
                
                // Start new drink
                currentDrinkName = drinkName
                currentPrice = extractPriceFromLine(line)
                currentSize = extractSizeFromLine(lowercased, originalLine: line)
                currentSugarLevel = extractSugarLevelFromLine(lowercased, originalLine: line)
                currentIceLevel = extractIceLevelFromLine(lowercased, originalLine: line)
                currentBubbleLevel = extractBubbleLevelFromLine(lowercased, originalLine: line)
                
                // Look at next few lines for modifiers
                let lookAheadRange = min(index + 1, lines.count)..<min(index + 6, lines.count)
                for nextIndex in lookAheadRange {
                    let nextLine = lines[nextIndex]
                    let nextLowercased = nextLine.lowercased()
                    
                    // Stop if we hit another drink
                    if extractDrinkNameFromLine(nextLine) != nil && nextIndex > index + 1 {
                        break
                    }
                    
                    // Extract modifiers from subsequent lines
                    if currentSize == nil {
                        currentSize = extractSizeFromLine(nextLowercased, originalLine: nextLine)
                    }
                    if currentSugarLevel == nil {
                        currentSugarLevel = extractSugarLevelFromLine(nextLowercased, originalLine: nextLine)
                    }
                    if currentIceLevel == nil {
                        currentIceLevel = extractIceLevelFromLine(nextLowercased, originalLine: nextLine)
                    }
                    if currentBubbleLevel == nil {
                        currentBubbleLevel = extractBubbleLevelFromLine(nextLowercased, originalLine: nextLine)
                    }
                    if currentPrice == nil {
                        currentPrice = extractPriceFromLine(nextLine)
                    }
                }
            }
        }
        
        // Don't forget the last drink - apply defaults
        if let name = currentDrinkName {
            items.append(ParsedReceiptItem(
                drinkName: name,
                price: currentPrice,
                size: currentSize ?? .medium,             // Default: medium
                sugarLevel: currentSugarLevel ?? .less,   // Default: half sugar
                iceLevel: currentIceLevel ?? .less,       // Default: less ice
                bubbleLevel: currentBubbleLevel ?? .none // Default: no bubble
            ))
        }
        
        // If no items found, try extracting from the entire text as a fallback
        if items.isEmpty {
            let fullText = lines.joined(separator: "\n")
            let lowercased = fullText.lowercased()
            
            let size = extractSizeFromLine(lowercased, originalLine: fullText)
            let sugarLevel = extractSugarLevelFromLine(lowercased, originalLine: fullText)
            let iceLevel = extractIceLevelFromLine(lowercased, originalLine: fullText)
            let bubbleLevel = extractBubbleLevelFromLine(lowercased, originalLine: fullText)
            let price = extractTotalPrice(from: lines)
            
            // Only add if we found at least something
            if size != nil || sugarLevel != nil || iceLevel != nil || bubbleLevel != nil || price != nil {
                items.append(ParsedReceiptItem(
                    drinkName: "Unknown Drink",
                    price: price,
                    size: size ?? .medium,             // Default: medium
                    sugarLevel: sugarLevel ?? .less,   // Default: half sugar
                    iceLevel: iceLevel ?? .less,       // Default: less ice
                    bubbleLevel: bubbleLevel ?? .none // Default: no bubble
                ))
            }
        }
        
        return items
    }
    
    // MARK: - Line-Level Extraction
    
    private func extractDrinkNameFromLine(_ line: String) -> String? {
        let lowercased = line.lowercased()
        
        // Check English keywords
        for keyword in drinkKeywordsEN {
            if lowercased.contains(keyword) {
                return cleanDrinkName(line)
            }
        }
        
        // Check Chinese keywords
        for keyword in drinkKeywordsZH {
            if line.contains(keyword) {
                return cleanDrinkName(line)
            }
        }
        
        return nil
    }
    
    private func extractSugarLevelFromLine(_ lowercasedLine: String, originalLine: String) -> SugarLevel? {
        // First, try to match explicit patterns
        for (level, patterns) in sugarPatterns {
            for pattern in patterns {
                if pattern.containsChineseCharacters {
                    if originalLine.contains(pattern) {
                        return level
                    }
                } else {
                    if lowercasedLine.contains(pattern.lowercased()) {
                        return level
                    }
                }
            }
        }
        
        // If no explicit pattern, try percentage matching
        if let percentageLevel = extractSugarFromPercentage(lowercasedLine) {
            return percentageLevel
        }
        
        return nil
    }
    
    private func extractSugarFromPercentage(_ text: String) -> SugarLevel? {
        guard let regex = try? NSRegularExpression(pattern: percentagePattern, options: []) else {
            return nil
        }
        
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        
        guard let percentage = Int(text[range]) else {
            return nil
        }
        
        // Map percentage to sugar level with tolerance
        switch percentage {
        case 0...10:
            return .none
        case 11...40:
            return .light
        case 41...60:
            return .less
        case 61...85:
            return .regular
        case 86...100:
            return .extra
        default:
            return nil
        }
    }
    
    private func extractIceLevelFromLine(_ lowercasedLine: String, originalLine: String) -> IceLevel? {
        for (level, patterns) in icePatterns {
            for pattern in patterns {
                if pattern.containsChineseCharacters {
                    if originalLine.contains(pattern) {
                        return level
                    }
                } else {
                    if lowercasedLine.contains(pattern.lowercased()) {
                        return level
                    }
                }
            }
        }
        return nil
    }
    
    private func extractSizeFromLine(_ lowercasedLine: String, originalLine: String) -> DrinkSize? {
        for (size, patterns) in sizePatterns {
            for pattern in patterns {
                if pattern.containsChineseCharacters {
                    if originalLine.contains(pattern) {
                        return size
                    }
                } else {
                    if lowercasedLine.contains(pattern.lowercased()) {
                        return size
                    }
                }
            }
        }
        return nil
    }
    
    private func extractBubbleLevelFromLine(_ lowercasedLine: String, originalLine: String) -> BubbleLevel? {
        for (level, patterns) in bubblePatterns {
            for pattern in patterns {
                if pattern.containsChineseCharacters {
                    if originalLine.contains(pattern) {
                        return level
                    }
                } else {
                    if lowercasedLine.contains(pattern.lowercased()) {
                        return level
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: - Price Extraction
    
    private func extractTotalPrice(from lines: [String]) -> Double? {
        // First, look for lines with total keywords
        for line in lines {
            let lowercased = line.lowercased()
            
            let hasKeyword = totalKeywordsEN.contains { lowercased.contains($0) } ||
                           totalKeywordsZH.contains { line.contains($0) }
            
            if hasKeyword {
                if let price = extractPriceFromLine(line) {
                    return price
                }
            }
        }
        
        // If no total found, return nil (individual item prices are handled separately)
        return nil
    }
    
    private func extractPriceFromLine(_ line: String) -> Double? {
        // Try USD pattern first ($X.XX)
        if let match = line.range(of: usdPricePattern, options: .regularExpression) {
            let matchedString = String(line[match])
            let numberString = matchedString.replacingOccurrences(of: "$", with: "")
                                           .replacingOccurrences(of: " ", with: "")
            if let price = Double(numberString) {
                return price
            }
        }
        
        // Try CNY pattern (¥X.XX or ￥X.XX)
        if let match = line.range(of: cnyPricePattern, options: .regularExpression) {
            let matchedString = String(line[match])
            let numberString = matchedString.replacingOccurrences(of: "¥", with: "")
                                           .replacingOccurrences(of: "￥", with: "")
                                           .replacingOccurrences(of: " ", with: "")
            if let price = Double(numberString) {
                return price
            }
        }
        
        // Try Yuan pattern (X.XX元)
        if let match = line.range(of: yuanPricePattern, options: .regularExpression) {
            let matchedString = String(line[match])
            let numberString = matchedString.replacingOccurrences(of: "元", with: "")
                                           .replacingOccurrences(of: " ", with: "")
            if let price = Double(numberString) {
                return price
            }
        }
        
        // Try generic price pattern (X.XX - likely a price if formatted this way)
        if let match = line.range(of: genericPricePattern, options: .regularExpression) {
            let matchedString = String(line[match])
            if let price = Double(matchedString) {
                return price
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func cleanDrinkName(_ name: String) -> String {
        var cleaned = name
        
        // Remove price patterns
        let pricePatterns = [usdPricePattern, cnyPricePattern, yuanPricePattern, genericPricePattern]
        for pattern in pricePatterns {
            while let range = cleaned.range(of: pattern, options: .regularExpression) {
                cleaned.removeSubrange(range)
            }
        }
        
        // Remove common receipt artifacts
        let artifacts = ["x1", "x2", "x3", "×1", "×2", "×3", "qty:", "qty", "#", "1x", "2x", "3x"]
        for artifact in artifacts {
            cleaned = cleaned.replacingOccurrences(of: artifact, with: "", options: .caseInsensitive)
        }
        
        // Clean up whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
        
        // Remove leading/trailing punctuation
        cleaned = cleaned.trimmingCharacters(in: CharacterSet.punctuationCharacters.union(.whitespaces))
        
        return cleaned
    }
}

// MARK: - String Extension for Chinese Detection

private extension String {
    var containsChineseCharacters: Bool {
        for scalar in unicodeScalars {
            if (0x4E00...0x9FFF).contains(scalar.value) ||  // CJK Unified Ideographs
               (0x3400...0x4DBF).contains(scalar.value) ||  // CJK Extension A
               (0x20000...0x2A6DF).contains(scalar.value) { // CJK Extension B
                return true
            }
        }
        return false
    }
}
