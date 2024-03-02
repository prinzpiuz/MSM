// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';

// Project imports:
import 'package:msm/providers/app_provider.dart';

class LiveTerminalPage extends StatelessWidget {
  final AppService appService;
  const LiveTerminalPage({super.key, required this.appService});

  @override
  Widget build(BuildContext context) {
    return LiveTerminal(appService: appService);
  }
}

class LiveTerminal extends StatefulWidget {
  final AppService appService;

  const LiveTerminal({super.key, required this.appService});
  @override
  LiveTerminalState createState() => LiveTerminalState();
}

class LiveTerminalState extends State<LiveTerminal> {
  final terminal = Terminal(
    platform: TerminalTargetPlatform.linux,
    maxLines: 10000,
  );

  Future<void> initTerminal() async {
    terminal.write('Connecting...\r\n');
    SSHClient? client = await widget.appService.server.connect();
    if (client != null) {
      terminal.write('Connected\r\n');
      final session = await client.shell(
        pty: SSHPtyConfig(
          width: terminal.viewWidth,
          height: terminal.viewHeight,
        ),
      );

      terminal.buffer.clear();
      terminal.buffer.setCursor(0, 0);

      terminal.onOutput = (data) {
        session.write(utf8.encode(data));
      };

      _listen(session.stdout);
      _listen(session.stderr);

      await session.done;
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      terminal.write('Connection Failed\r\n');
    }
  }

  void _listen(Stream<Uint8List> stream) {
    stream
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);
  }

  final terminalController = TerminalController();

  @override
  void initState() {
    super.initState();
    initTerminal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: TerminalView(
          terminal,
          controller: terminalController,
          autofocus: true,
          onSecondaryTapDown: (details, offset) async {
            final selection = terminalController.selection;
            if (selection != null) {
              final text = terminal.buffer.getText(selection);
              terminalController.clearSelection();
              await Clipboard.setData(ClipboardData(text: text));
            } else {
              final data = await Clipboard.getData('text/plain');
              final text = data?.text;
              if (text != null) {
                terminal.paste(text);
              }
            }
          },
        ),
      ),
    );
  }
}
