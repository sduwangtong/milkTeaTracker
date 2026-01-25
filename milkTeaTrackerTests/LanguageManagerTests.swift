//
//  LanguageManagerTests.swift
//  milkTeaTrackerTests
//
//  Tests for LanguageManager to ensure language toggle and localization work correctly.
//

import XCTest
@testable import milkTeaTracker

final class LanguageManagerTests: XCTestCase {
    
    var manager: LanguageManager!
    
    override func setUp() {
        super.setUp()
        // Create a fresh instance for each test
        manager = LanguageManager()
    }
    
    override func tearDown() {
        // Reset to English after each test
        manager.currentLanguage = "en"
        super.tearDown()
    }
    
    // MARK: - Toggle Language Tests
    
    func testToggleLanguageFromEnglishToChinese() {
        // Given
        manager.currentLanguage = "en"
        XCTAssertEqual(manager.currentLanguage, "en")
        
        // When
        manager.toggleLanguage()
        
        // Then
        XCTAssertEqual(manager.currentLanguage, "zh-Hans", "Toggle from English should switch to Chinese")
    }
    
    func testToggleLanguageFromChineseToEnglish() {
        // Given
        manager.currentLanguage = "zh-Hans"
        XCTAssertEqual(manager.currentLanguage, "zh-Hans")
        
        // When
        manager.toggleLanguage()
        
        // Then
        XCTAssertEqual(manager.currentLanguage, "en", "Toggle from Chinese should switch to English")
    }
    
    func testToggleLanguageTwiceReturnsToOriginal() {
        // Given
        manager.currentLanguage = "en"
        
        // When
        manager.toggleLanguage()
        manager.toggleLanguage()
        
        // Then
        XCTAssertEqual(manager.currentLanguage, "en", "Toggle twice should return to original language")
    }
    
    // MARK: - Boolean Properties Tests
    
    func testIsEnglishWhenLanguageIsEnglish() {
        // Given
        manager.currentLanguage = "en"
        
        // Then
        XCTAssertTrue(manager.isEnglish, "isEnglish should be true when language is 'en'")
        XCTAssertFalse(manager.isChinese, "isChinese should be false when language is 'en'")
    }
    
    func testIsChineseWhenLanguageIsChinese() {
        // Given
        manager.currentLanguage = "zh-Hans"
        
        // Then
        XCTAssertTrue(manager.isChinese, "isChinese should be true when language is 'zh-Hans'")
        XCTAssertFalse(manager.isEnglish, "isEnglish should be false when language is 'zh-Hans'")
    }
    
    // MARK: - Locale Tests
    
    func testLocaleMatchesCurrentLanguage() {
        // Given
        manager.currentLanguage = "en"
        
        // Then
        XCTAssertEqual(manager.locale.identifier, "en", "Locale should match English identifier")
        
        // Given
        manager.currentLanguage = "zh-Hans"
        
        // Then
        XCTAssertEqual(manager.locale.identifier, "zh-Hans", "Locale should match Chinese identifier")
    }
    
    // MARK: - Localized String Tests
    
    func testLocalizedStringReturnsNonEmptyValue() {
        // Given
        manager.currentLanguage = "en"
        
        // When
        let result = manager.localizedString("drink_log")
        
        // Then
        XCTAssertFalse(result.isEmpty, "localizedString should return a non-empty value for valid key")
    }
    
    func testLocalizedStringReturnsDifferentValuesForDifferentLanguages() {
        // This test verifies the language actually changes the output
        // Note: This depends on having translations in both .lproj bundles
        
        // Given English
        manager.currentLanguage = "en"
        let englishTitle = manager.localizedString("drink_log")
        
        // Given Chinese
        manager.currentLanguage = "zh-Hans"
        let chineseTitle = manager.localizedString("drink_log")
        
        // Then - at minimum, we should get non-empty strings
        // If translations exist, they should be different
        XCTAssertFalse(englishTitle.isEmpty, "English translation should not be empty")
        XCTAssertFalse(chineseTitle.isEmpty, "Chinese translation should not be empty")
        
        // If both bundles exist with translations, titles should differ
        // (Skip assertion if bundles are missing in test environment)
        if englishTitle != "drink_log" && chineseTitle != "drink_log" {
            XCTAssertNotEqual(englishTitle, chineseTitle, "Translations should be different for different languages")
        }
    }
    
    func testLocalizedStringWithFormatArguments() {
        // Given
        manager.currentLanguage = "en"
        
        // When - test the format variant with arguments
        // Note: This uses the free_scans_format key which has format specifiers
        let result = manager.localizedString("free_scans_format", args: 3, 5)
        
        // Then - should contain the formatted values
        XCTAssertFalse(result.isEmpty, "Formatted string should not be empty")
        XCTAssertTrue(result.contains("3") || result.contains("5"), "Formatted string should contain the argument values")
    }
    
    // MARK: - UserDefaults Persistence Tests
    
    func testLanguageIsSavedToUserDefaults() {
        // Given
        let testLanguage = "zh-Hans"
        
        // When
        manager.currentLanguage = testLanguage
        
        // Then
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language")
        XCTAssertEqual(savedLanguage, testLanguage, "Language should be saved to UserDefaults")
    }
    
    func testAppleLanguagesIsUpdatedOnLanguageChange() {
        // Given
        let testLanguage = "zh-Hans"
        
        // When
        manager.currentLanguage = testLanguage
        
        // Then
        let appleLanguages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        XCTAssertNotNil(appleLanguages, "AppleLanguages should be set")
        XCTAssertEqual(appleLanguages?.first, testLanguage, "AppleLanguages should contain the current language")
    }
}
