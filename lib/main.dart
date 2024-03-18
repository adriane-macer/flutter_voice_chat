import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';




Future<void> main() async {
  // Ensure Flutter is able to communicate with Plugins
  WidgetsFlutterBinding.ensureInitialized();


  await dotenv.load(fileName: '.env.secret');

  runApp(MaterialApp(home: MyApp()));
}

const String userId = "1";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamVideo client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Chat'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Create Call'),
            onPressed: () {
              try {
                final call =
                    client.makeCall(callType: StreamCallType(), id: userId);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CallScreen(call: call)));
              } catch (e) {
                debugPrint('Error joining or creating call: $e');
                debugPrint(e.toString());
              }
            },
          ),
        ));
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    
    final apiKey = dotenv.env['API_KEY'] ?? '';
    final userToken = dotenv.env['USER_TOKEN'] ?? '';   // TODO (AE 3/18/2024) : temporary

    // Initialize Stream video and set the API key along with the user for our app.
    client = StreamVideo(
      apiKey,
      user: User.regular(userId: userId, name: 'Test User'),
      userToken:
          userToken,
      options: const StreamVideoOptions(
        logPriority: Priority.info,
      ),
    );
  }
}

class CallScreen extends StatefulWidget {
  final Call call;

  const CallScreen({
    super.key,
    required this.call,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: widget.call,
      ),
    );
  }

  @override
  void initState() {
    widget.call.join();
    super.initState();
  }

  @override
  void dispose() {
    widget.call.end();
    super.dispose();
  }
}

class DemoAppHome extends StatelessWidget {
  const DemoAppHome({super.key, required this.call});

  final Call call;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        // Stream's pre-made component
        call: call,
      ),
    );
  }
}
