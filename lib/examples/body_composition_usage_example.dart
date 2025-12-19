import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/providers/body_composition_provider.dart';
import 'package:gym_app_2/providers/profile_provider.dart';

/// Example of how to use the updated BodyCompositionProvider with ProfileProvider
class BodyCompositionUsageExample extends StatelessWidget {
  const BodyCompositionUsageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Composition Usage Example'),
      ),
      body: Consumer2<ProfileProvider, BodyCompositionProvider>(
        builder: (context, profileProvider, bodyCompProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Data Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Data Used by Body Composition',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text('Name: ${bodyCompProvider.userName}'),
                        Text('Age: ${bodyCompProvider.userAge}'),
                        Text('Height: ${bodyCompProvider.userHeight} cm'),
                        Text('Weight: ${bodyCompProvider.userWeight} kg'),
                        Text('Has Profile: ${bodyCompProvider.hasUserProfile}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Update body composition provider with latest profile data
                            bodyCompProvider.updateFromProfileProvider();
                            // ScaffoldMessenger.of(context).showSnackBar(

                            //                               const SnackBar(

                            //                                   content: Text(

                            //                                       'Profile data synced to body composition provider')),
                            );
                          },
                          child: const Text('Sync Profile Data'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Body Composition Status Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Composition Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                            'SDK Initialized: ${bodyCompProvider.isInitialized}'),
                        Text(
                            'Device Connected: ${bodyCompProvider.isConnected}'),
                        Text('Scanning: ${bodyCompProvider.isScanning}'),
                        Text(
                            'Has Measurement Data: ${bodyCompProvider.hasData}'),
                        if (bodyCompProvider.error != null)
                          Text(
                            'Error: ${bodyCompProvider.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: bodyCompProvider.isScanning
                                  ? null
                                  : () => bodyCompProvider.startScan(),
                              child: Text(bodyCompProvider.isScanning
                                  ? 'Scanning...'
                                  : 'Start Scan'),
                            ),
                            const SizedBox(width: 8),
                            if (bodyCompProvider.isScanning)
                              ElevatedButton(
                                onPressed: () => bodyCompProvider.stopScan(),
                                child: const Text('Stop Scan'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Latest Measurement Data Section
                if (bodyCompProvider.hasData)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Measurement',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                              'Weight: ${bodyCompProvider.getFormattedWeight()}'),
                          Text(
                              'Body Fat: ${bodyCompProvider.getFormattedBodyFat()}'),
                          Text(
                              'Muscle: ${bodyCompProvider.getFormattedMuscle()}'),
                          Text(
                              'Water: ${bodyCompProvider.getFormattedWater()}'),
                          Text(
                              'BMI: ${bodyCompProvider.bmi.toStringAsFixed(1)}'),
                          Text(
                              'BMR: ${bodyCompProvider.bmr.toStringAsFixed(0)} kcal'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bodyCompProvider
                                  .getHealthStatusColor()
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Status: ${bodyCompProvider.measurementStatus}',
                              style: TextStyle(
                                color: bodyCompProvider.getHealthStatusColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Discovered Devices Section
                if (bodyCompProvider.devices.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discovered Devices (${bodyCompProvider.devices.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...bodyCompProvider.devices.map(
                            (device) => ListTile(
                              leading: const Icon(Icons.bluetooth),
                              title: Text(device.macAddr ?? 'Unknown Device'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Connect to this device
                                  // ScaffoldMessenger.of(context).showSnackBar(

                                  //                                     SnackBar(

                                  //                                         content: Text(

                                  //                                             'Connecting to ${device.macAddr}...')),
                                  );
                                },
                                child: const Text('Connect'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example of how to set up providers in main.dart or in a MultiProvider
class ProviderSetupExample extends StatelessWidget {
  const ProviderSetupExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // First initialize ProfileProvider
        ChangeNotifierProvider(
          create: (context) => ProfileProvider()..loadFromLocalStorage(),
        ),

        // Then initialize BodyCompositionProvider with ProfileProvider reference
        ChangeNotifierProxyProvider<ProfileProvider, BodyCompositionProvider>(
          create: (context) => BodyCompositionProvider(),
          update: (context, profileProvider, bodyCompositionProvider) {
            // Update the body composition provider when profile data changes
            if (bodyCompositionProvider != null) {
              bodyCompositionProvider.updateFromProfileProvider();
              return bodyCompositionProvider;
            }
            return BodyCompositionProvider(profileProvider: profileProvider);
          },
        ),
      ],
      child: MaterialApp(
        home: const BodyCompositionUsageExample(),
      ),
    );
  }
}
