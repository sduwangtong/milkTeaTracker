/**
 * Simple Drink Logger - Google Apps Script
 * 
 * A lightweight endpoint that appends drink log data directly to a Google Sheet.
 * Protected by API key authentication.
 * 
 * SETUP:
 * 1. Create a new Google Sheet
 * 2. Create a sheet tab named "drink_logs"
 * 3. Add this header row:
 *    email | name | brandName | brandNameZH | drinkName | drinkNameZH | size | sugarLevel | iceLevel | bubbleLevel | calories | sugarGrams | price | timestamp | isCustomDrink | latitude | longitude | syncedAt | isDeleted
 * 4. Extensions > Apps Script > Paste this code
 * 5. Set your API key below (change API_KEY to a secure random string)
 * 6. Deploy > New deployment > Web app
 *    - Execute as: Me
 *    - Who has access: Anyone
 * 7. Copy the deployment URL to AuthConfig.swift (simpleSheetsURL)
 * 8. Copy the API key to AuthConfig.swift (sheetsAPIKey)
 */

const SHEET_NAME = 'drink_logs';

// ⚠️ CHANGE THIS TO YOUR OWN SECRET KEY - use a long random string
// Generate one at: https://randomkeygen.com/ (use "CodeIgniter Encryption Keys")
const API_KEY = 'P,sp9[2TLxa82*G)';

/**
 * Validate API key from request
 */
function validateApiKey(data) {
  if (!data.apiKey) {
    return false;
  }
  return data.apiKey === API_KEY;
}

/**
 * Handle HTTP POST requests - append drink log to sheet
 */
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    // Validate API key first
    if (!validateApiKey(data)) {
      return errorResponse('Unauthorized: Invalid or missing API key', 401);
    }
    
    // Validate required fields
    if (!data.email || !data.brandName || !data.drinkName) {
      return errorResponse('Missing required fields: email, brandName, drinkName');
    }
    
    const sheet = getSheet();
    const syncedAt = new Date().toISOString();
    
    // Append the row
    sheet.appendRow([
      data.email || '',
      data.name || '',
      data.brandName || '',
      data.brandNameZH || '',
      data.drinkName || '',
      data.drinkNameZH || '',
      data.size || 'medium',
      data.sugarLevel || 'regular',
      data.iceLevel || 'regular',
      data.bubbleLevel || 'none',
      data.calories || 0,
      data.sugarGrams || 0,
      data.price || '',
      data.timestamp || new Date().toISOString(),
      data.isCustomDrink || false,
      data.latitude || '',
      data.longitude || '',
      syncedAt,
      false // isDeleted
    ]);
    
    return jsonResponse({ 
      success: true, 
      message: 'Drink logged successfully',
      syncedAt: syncedAt
    });
    
  } catch (error) {
    console.error('Error in doPost:', error);
    return errorResponse('Server error: ' + error.message);
  }
}

/**
 * Handle HTTP GET requests (for testing)
 */
function doGet(e) {
  // Check for ping action
  if (e && e.parameter && e.parameter.action === 'ping') {
    return jsonResponse({ 
      success: true, 
      message: 'Simple Drink Logger is running',
      timestamp: new Date().toISOString()
    });
  }
  
  return jsonResponse({ 
    success: true, 
    message: 'Simple Drink Logger API. Use POST to log drinks.',
    endpoints: {
      'POST /': 'Log a drink (JSON body with email, name, brandName, drinkName, etc.)',
      'GET /?action=ping': 'Health check'
    }
  });
}

/**
 * Batch log multiple drinks at once
 */
function doPostBatch(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    if (!data.drinks || !Array.isArray(data.drinks)) {
      return errorResponse('Missing drinks array');
    }
    
    const sheet = getSheet();
    const syncedAt = new Date().toISOString();
    const results = [];
    
    for (const drink of data.drinks) {
      try {
        sheet.appendRow([
          drink.email || data.email || '',
          drink.name || data.name || '',
          drink.brandName || '',
          drink.brandNameZH || '',
          drink.drinkName || '',
          drink.drinkNameZH || '',
          drink.size || 'medium',
          drink.sugarLevel || 'regular',
          drink.iceLevel || 'regular',
          drink.bubbleLevel || 'none',
          drink.calories || 0,
          drink.sugarGrams || 0,
          drink.price || '',
          drink.timestamp || new Date().toISOString(),
          drink.isCustomDrink || false,
          drink.latitude || '',
          drink.longitude || '',
          syncedAt,
          false
        ]);
        results.push({ success: true, drinkName: drink.drinkName });
      } catch (err) {
        results.push({ success: false, drinkName: drink.drinkName, error: err.message });
      }
    }
    
    return jsonResponse({
      success: true,
      message: `Logged ${results.filter(r => r.success).length} of ${data.drinks.length} drinks`,
      results: results,
      syncedAt: syncedAt
    });
    
  } catch (error) {
    console.error('Error in batch logging:', error);
    return errorResponse('Server error: ' + error.message);
  }
}

/**
 * Get or create the drink_logs sheet
 */
function getSheet() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = spreadsheet.getSheetByName(SHEET_NAME);
  
  if (!sheet) {
    // Create the sheet with headers
    sheet = spreadsheet.insertSheet(SHEET_NAME);
    sheet.appendRow([
      'email', 'name', 'brandName', 'brandNameZH', 'drinkName', 'drinkNameZH',
      'size', 'sugarLevel', 'iceLevel', 'bubbleLevel', 'calories', 'sugarGrams',
      'price', 'timestamp', 'isCustomDrink', 'latitude', 'longitude', 'syncedAt', 'isDeleted'
    ]);
    
    // Format header row
    const headerRange = sheet.getRange(1, 1, 1, 19);
    headerRange.setFontWeight('bold');
    headerRange.setBackground('#f3f3f3');
    
    // Freeze header row
    sheet.setFrozenRows(1);
  }
  
  return sheet;
}

/**
 * Create a JSON response
 */
function jsonResponse(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * Create an error response
 */
function errorResponse(message, statusCode) {
  return ContentService.createTextOutput(JSON.stringify({
    success: false,
    error: message,
    statusCode: statusCode || 400
  })).setMimeType(ContentService.MimeType.JSON);
}

/**
 * Test function - run this to verify setup
 */
function testSetup() {
  const sheet = getSheet();
  console.log('Sheet found/created: ' + sheet.getName());
  console.log('Number of rows: ' + sheet.getLastRow());
  console.log('Setup complete!');
}
