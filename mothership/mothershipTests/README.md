# mothership Tests

This directory contains unit tests for the mothership app.

## Adding Tests to Xcode

To run these tests in Xcode, you need to add a test target to your project:

### Option 1: Using Xcode GUI

1. Open `mothership.xcodeproj` in Xcode
2. Select the project in the Project Navigator
3. Click the **+** button at the bottom of the targets list
4. Choose **Unit Testing Bundle**
5. Name it `mothershipTests`
6. Make sure the target is set to test `mothership`
7. In the Project Navigator, right-click on `mothershipTests` folder
8. Choose **Add Files to "mothership"...**
9. Select the test files (`CharterTests.swift` and `CharterStoreTests.swift`)
10. Make sure they are added to the `mothershipTests` target

### Option 2: Using Command Line (Swift Package Manager)

If your project uses SPM, add the test target to your `Package.swift`:

```swift
.testTarget(
    name: "mothershipTests",
    dependencies: ["mothership"]
)
```

## Running Tests

### In Xcode
- Press `⌘U` (Command + U) to run all tests
- Click the diamond icon next to any test method to run a single test
- Use the Test Navigator (`⌘6`) to view all tests

### From Command Line
```bash
# Using xcodebuild
xcodebuild test -scheme mothership -destination 'platform=iOS Simulator,name=iPhone 15'

# If using SPM
swift test
```

## Test Structure

### CharterTests.swift
Tests for the `Charter` model:
- `isActive` property logic (date-based active status)
- Charter initialization
- Codable conformance (JSON encoding/decoding)

### CharterStoreTests.swift
Tests for the `CharterStore`:
- Adding charters
- Updating charters
- Deleting charters
- Date-based active charter detection
- Persistence (UserDefaults)
- Sorting by start date

## Writing New Tests

Follow these patterns when adding new tests:

1. **Arrange-Act-Assert**: Structure tests with Given-When-Then comments
2. **Test naming**: Use descriptive names like `test<MethodName>_<Condition>_<ExpectedResult>`
3. **One assertion per concept**: Keep tests focused on a single behavior
4. **Setup and teardown**: Use `setUp()` and `tearDown()` for common initialization

### Example:

```swift
func testAddCharter_AddsCharterToStore() {
    // Given: An empty store
    XCTAssertTrue(sut.charters.isEmpty)
    
    // When: Adding a charter
    let charter = Charter(name: "Test", startDate: Date())
    sut.addCharter(charter)
    
    // Then: Charter should be in the store
    XCTAssertEqual(sut.charters.count, 1)
}
```

## Test Coverage

Current test coverage includes:
- ✅ Charter model initialization
- ✅ Date-based active charter logic
- ✅ Charter encoding/decoding
- ✅ CharterStore CRUD operations
- ✅ CharterStore automatic active charter detection
- ✅ CharterStore persistence

## Notes

- Tests use the main app target (`@testable import mothership`)
- Persistence tests interact with UserDefaults and clean up after themselves
- Date-based tests use relative dates to avoid time-dependent failures

