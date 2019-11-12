# FlickrFrame
A photo frame which displays photos from Flickr in three column

## Requirements
- Xcode 10.3
- Support iOS 10 or later
    
## Architecture 
This demo is built by teh concept of the *MVVM* pattern, but without binding. In my opinion, it's a good balance between trade-offs in terms of testability, readability, and speed for development.

`Model` - The pure logic components 
`View` - The instance that handles the UI and user interaction.
`ViewModel` - The instance that handles business logic and communication between view and service.

*protocol-oriented programming* as a key concept in Swift, it has a vital role in our program. `Presentable` is the contract between view and viewModel. Consequently, the view knows nothing about the actual classes of the ViewModel (and models). With this separation, developers can easily mock the objects and decouple the dependencies.

## Cache 
By default, `URLCache` provides a composite in-memory and on-disk caching mechanism for URL requests, and any request loaded through `URLSession` will e handled.

The ViewModel also implements its in-memory cache by NSCache, because to decode data to uiimage is also an expensive operation.

## Tests
### UnitTest
There are examples of service and presenter by using `MockURLSession`.

One thing to note is that since the ViewController only needs an instance that conforms to Presentable, we can also have unit tests on viewController for verifying the localization strings, button actions, the integrity of the listView, etc. This is essential in my experience because UITesting is expensive in terms of time and resources.

### UITest

It's a pity that I don't have time left to implement any UITests. But each custom UI elements on the screen should have its *accessibilityIdentifier* assigned. In theory, we can mock an `URLSession` and query the element by its identifier for the testing locally.

## Improvements
    
- Although the test-coverage is **61%**, there are still quite some test cases like errors and loading images that need to be covered.
- The application needs to handle the error state and empty state on the photo list.
