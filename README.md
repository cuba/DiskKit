[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-ios-lightgray.svg?style=flat)](https://dashboard.buddybuild.com/apps/592348f0b74ee700016fbbe6/build/latest?branch=master)

DiskKit
============

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)
- [License](#license)


## Features

- [x] Store any file type
- [x] Easy integration
- [x] Suppports [Document Packages](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#)
- [x] Suppports [Codable](https://developer.apple.com/documentation/swift/codable) protocol


## Installation

### Carthage

[Carthage](https://github.com/cuba/NetworkKit) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate DiskKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "cuba/DiskKit"
```

Run `carthage update` to build the framework and drag the built `DiskKit.framework` into your Xcode project.


## Usage

### Supported files

#### Codable

```swift
struct TestCodable: Codable {
    var id = UUID().uuidString
    
    init(id: String) {
        self.id = id
    }
}
```

#### DiskCodable

DiskCodable gives you some extra flexability with the types of files you can store.

```swift
struct TestDiskCodable: DiskCodable {
    var id = UUID().uuidString
    
    init(id: String) {
        self.id = id
    }
    
    init(_ data: Data) throws {
        id = String(data: data, encoding: .utf8)!
    }
    
    func encode() throws -> Data {
        return id.data(using: .utf8)!
    }
}
```

#### File

`File` is just a wrapper around a file. It allows you to easily save and load objects of a specific type.  It also is a great way to support polimorphyc file types useful when saving and getting data from a directly that contains mixed file types.

It supports the files above plus some convenient extras such as `String`.

### Storing files

Store a single file like this:

```swift
let filename = "example.json"
let testFile = TestCodable(id: "ABC")

do {
  EncodableDisk.store(testFile, to: .documents, as: filename)
} catch {
  // Handle error
}
```


### Loading files

You can load a single file like this:

```swift
do {
  let loadedFile: TestCodable = try EncodableDisk.file(withName: filename, in: .documents)
} catch {
  // Handle error
}
```

or you can load all the files in the directory like this:

```swift
do {
  let loadedFiles: [TestCodable] = try EncodableDisk.files(in: .documents)
} catch {
  // Handle error
}
```


### Document Packages

You may also store [Document Packages](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html).  You just need to implement the Directory protocol:

Packages also support nested packages which need to extend the `Directory` protocol.

```swift
struct TestPackage: Package {
    static let typeIdentifier = "com.example.myproject.package"
    
    var codable: TestCodable
    var diskCodable: TestDiskCodable
    
    init(codable: TestCodable, diskCodable: TestDiskCodable) {
        self.codable = codable
        self.diskCodable = diskCodable
    }
    
    init(directory: Directory) throws {
        self.codable = try map.file("codable.json")
        self.diskCodable = try map.file("disk_codable.json")
    }
    
    func fill(directory: Directory) throws {
        try map.add(codable, name: "codable.json")
        try map.add(diskCodable, name: "disk_codable.json")
    }
}
```

#### Saving Packages

```swift
let testFile = TestPackage(
  codable: TestCodable(id: "CODABLE_ABC"),
  diskCodable: TestDiskCodable(id: "DISK_CODABLE_ABC")
)

let filename = "example.package"

do {
  try PackagableDisk.store(testFile, to: .documents, as: filename)
} catch {
  // Handle error
}
```

##### Loading packages

```swift

do {
    let url = Disk.Directory.documents.baseUrl
    let directory: TestPackage = try PackagableDisk.package(in .documents, withName: filename)
} catch {
    // Handle error
}
```

**Note:**
You need to provide additional information about your directory type (and extension) in your applications Info.plist file.
You can get more information about Document Packages [here](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html).

Without this additional information, your directory will not be found.


### Directories

You can query entire directories with all of its contents

```swift

```

#### Directory supported types

Directory supports the following types:
* `Directory` class
* `Codable` types
* `Codable` arrays (i.e. `[T] where T: Codable`) *These will be stored in auto-generated file names*
* `DiskCodable` types
* `DiskCodable` arrays (i.e. `[T] where T: DiskCodable`) *These will be stored in auto-generated file names*
* `File` class
* `File` arrays (i.e. `[File]`) *These will be stored in auto-generated file names*
* `UIImage` types
* `String` types
* `Data` types

### Using File

File is a helper class that lets you parse your files after retrieving them. This is useful when you're not sure what kind of file you are expected to recieve.  It is also used inside packages as it may contain a variety of different file types.

**Creating File objects**

```swift
let filename = "example.json"
let testFile = TestCodable(id: "ABC")
let file = try File(file: testFile, name: filename)
```

`File` supports both `Codable` and `DiskCodable` files.

**Storing File objects:**

```swift
try Disk.create(path: "some_folder", in: .documents)
try Disk.store(file, to: .documents, path: "some_folder")
```

**Loading File objects:**

```swift
let loadedDiskData = try Disk.file(withName: filename, in: .documents, path: "some_folder")
```

**Loading multiple File objects:**

```swift
let loadedDiskDataArray = try Disk.filesArray(in: .documents, path: "some_folder")
```

**Parsing a file from a File object:**

```swift
let loadedFile: TestCodable = try loadedDiskData.decode()
```


### Subdirectories

You may also provide a subdirectory (path) for your file.  Ensure that your path does not begin with a `/`

First you will have to create your subdirectory like this:

```swift
try Disk.create(path: "some_folder", in: .documents)
```

```swift
try EncodableDisk.store(testFile, to: .documents, as: "example.json", path: "some_folder")
```

### Other useful functionality

In addition to the standard storing and loading methods on files and packages, you may also do the following:

Clear the contents of a directory

```swift
try Disk.clear(.documents)
```

**Create a subdirectory**

```swift
try Disk.create(path: "some_folder", in: .documents)
```

**Delete a subdirectory**

```swift
try Disk.remove(path: "some_folder", in: .documents)
```


## Dependencies

DiskKit has no dependencies


## Credits

DiskKit is owned and maintained by Jacob Sikorski.


## License

DiskKit is released under the MIT license. [See LICENSE](https://github.com/cuba/DiskKit/blob/master/LICENSE) for details
