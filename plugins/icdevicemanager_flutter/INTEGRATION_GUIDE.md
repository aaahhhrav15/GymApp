# ICDeviceManager Flutter Plugin Integration Guide

## Current Issue
The plugin currently has stub implementations to prevent linker errors. To use the actual ICDeviceManager functionality, you need to integrate the real framework.

## Steps to Fix the Linker Errors

### Option 1: Add the Actual ICDeviceManager Framework (Recommended)

1. **Obtain the ICDeviceManager Framework**
   - Contact the IoT device manufacturer to get the official `ICDeviceManager.framework`
   - Or download it from their developer portal/SDK

2. **Add the Framework to the Plugin**
   ```bash
   # Create the Assets directory if it doesn't exist
   mkdir -p plugins/icdevicemanager_flutter/ios/Assets
   
   # Copy the framework to the Assets directory
   cp /path/to/ICDeviceManager.framework plugins/icdevicemanager_flutter/ios/Assets/
   ```

3. **Update the Podspec**
   - Uncomment the `s.vendored_frameworks` line in the podspec
   - Comment out or remove the stub implementation

4. **Clean and Rebuild**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter clean
   flutter pub get
   flutter build ios
   ```

### Option 2: Use Static Library (Alternative)

If you have a static library instead of a framework:

1. **Add the Static Library**
   ```bash
   # Copy the static library to Assets
   cp /path/to/libICDeviceManager.a plugins/icdevicemanager_flutter/ios/Assets/
   ```

2. **Update the Podspec**
   - Uncomment the `s.vendored_libraries` line
   - Comment out the `s.vendored_frameworks` line

### Option 3: Manual Framework Integration

If you need to manually add the framework to your iOS project:

1. **Open your iOS project in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add the Framework**
   - Select the Runner target
   - Go to "Build Phases" → "Link Binary With Libraries"
   - Click "+" and add the ICDeviceManager.framework

3. **Update Framework Search Paths**
   - Go to "Build Settings" → "Framework Search Paths"
   - Add the path to your framework

## Current Stub Implementation

The plugin currently includes stub implementations in `ICDeviceManagerStub.m` to prevent linker errors. These stubs provide empty implementations of all the required methods.

**Important**: The stub implementations will not provide actual IoT device functionality. They only prevent build errors.

## Verification

After integrating the actual framework:

1. **Remove the stub file** (if using actual framework)
2. **Test the build**:
   ```bash
   flutter build ios --no-codesign
   ```
3. **Verify functionality** by testing actual device connections

## Troubleshooting

### If you still get linker errors:
1. Ensure the framework is compatible with your iOS deployment target
2. Check that the framework supports the required architectures (arm64, armv7)
3. Verify that all required system frameworks are linked (CoreBluetooth, Foundation)

### If the framework is not found:
1. Check the framework path in the podspec
2. Ensure the framework is in the correct Assets directory
3. Run `pod install` after adding the framework

## Next Steps

1. Obtain the official ICDeviceManager framework from your IoT device manufacturer
2. Follow the integration steps above
3. Test the integration with actual IoT devices
4. Remove the stub implementation once the real framework is working
