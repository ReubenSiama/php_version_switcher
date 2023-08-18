import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:process_run/process_run.dart';
import 'package:switcher/action_button.dart';
import 'package:switcher/constants.dart';
import 'package:switcher/snackbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var shell = Shell();

  List<FileSystemEntity> installedPhp = [];
  List<String> availableInSystem = [];
  Color closeButtonColor = const Color.fromARGB(255, 209, 158, 5);

  String currentVersion = '';

  bool isLoading = true;

  void getListOfPhp() async {
    List<String> available = [];
    var list = await shell.run('update-alternatives --list php');
    List<String> newList = list.outText.split('\n').toList();
    newList.map(
      (e) {
        available.add(e.substring(12));
      },
    ).toList();
    setState(() {
      availableInSystem = available;
      isLoading = false;
    });
  }

  void getCurrentVersion() async {
    var version = await shell.run('php -v');
    setState(() {
      currentVersion = version.outText.substring(0, 7);
    });
  }

  void switchVersion(String version) async {
    try {
      await shell
          .run(
            'pkexec update-alternatives --set php /usr/bin/php$version',
          )
          .then((value) => getCurrentVersion())
          .then(
            (value) => ScaffoldMessenger.of(context)
                .showSnackBar(mySnackbar('PHP version switched successfully')),
          );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(mySnackbar('Something went wrong!'));
    }
  }

  void installNew(String version) async {
    setState(() {
      isLoading = true;
    });

    try {
      await shell
          .run("pkexec apt install php$version -y")
          .then((value) => getListOfPhp())
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(mySnackbar("PHP$version installed successfully")));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(mySnackbar('Something went wrong!'));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uninstall(String version) async {
    setState(() {
      isLoading = true;
    });
    try {
      shell
          .run('''
        pkexec apt purge php$version* -y
        pkexec apt autoremove -y
      ''')
          .then(
            (value) => getListOfPhp(),
          )
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              mySnackbar("PHP$version uninstalled successfully")));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(mySnackbar('Something went wrong!'));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteAlert(BuildContext context, String version) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 93, 66, 53),
            actionsAlignment: MainAxisAlignment.spaceAround,
            title: Text(
              'Are you sure you want to uninstall\nPHP $version?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0XFFD5CEA3),
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0XFFD5CEA3),
                      ),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: Color(0XFFD5CEA3),
                  ),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0XFFD5CEA3)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0XFFD5CEA3),
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  await uninstall(version)
                      .then((value) => Navigator.pop(context));
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Color.fromARGB(255, 93, 66, 53)),
                ),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    getCurrentVersion();
    getListOfPhp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: const LinearProgressIndicator(
        color: Color(0XFF704F4F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            decoration: const BoxDecoration(
              color: Color(0XFF3C2A21),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MouseRegion(
                  onHover: (event) => setState(() {
                    closeButtonColor = const Color.fromARGB(255, 239, 181, 6);
                  }),
                  onExit: (event) => setState(() {
                    closeButtonColor = const Color.fromARGB(255, 209, 158, 5);
                  }),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => exit(0),
                    child: Icon(
                      Icons.power_settings_new_outlined,
                      color: closeButtonColor,
                      size: 35,
                    ),
                  ),
                ),
                const Text(
                  "SWITCHER",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(4.0, 4.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      Shadow(
                        offset: Offset(4.0, 4.0),
                        blurRadius: 8.0,
                        color: Color.fromARGB(124, 32, 32, 34),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Select the version you want to use',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0XFFE5E5CB),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(
              availableInSystem.length,
              (index) {
                return Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: currentVersion.substring(4) ==
                                availableInSystem[index]
                            ? const Color(0XFF3C2A21)
                            : const Color(0XFFD5CEA3)),
                    borderRadius: BorderRadius.circular(10),
                    color:
                        currentVersion.substring(4) == availableInSystem[index]
                            ? const Color(0XFF3C2A21)
                            : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "PHP ${availableInSystem[index]}",
                        style: TextStyle(
                          color: currentVersion.substring(4) ==
                                  availableInSystem[index]
                              ? const Color.fromARGB(255, 93, 66, 53)
                              : const Color(0XFFE5E5CB),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ActionButton(
                            onTap: currentVersion.substring(4) ==
                                    availableInSystem[index]
                                ? null
                                : () async {
                                    deleteAlert(
                                        context, availableInSystem[index]);
                                  },
                            icon: Icons.delete,
                          ),
                          ActionButton(
                            onTap: currentVersion.substring(4) ==
                                    availableInSystem[index]
                                ? null
                                : () => switchVersion(availableInSystem[index]),
                            icon: Icons.change_circle,
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Install Other Version',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0XFFE5E5CB),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(
              installable.length,
              (index) {
                return MaterialButton(
                  disabledColor: const Color.fromARGB(255, 34, 24, 19),
                  padding: const EdgeInsets.all(20),
                  color: const Color(0XFF3C2A21),
                  textColor: Colors.white,
                  onPressed: !availableInSystem.contains(installable[index])
                      ? () => installNew(installable[index])
                      : null,
                  child: Text(
                    "PHP ${installable[index]}",
                    style: TextStyle(
                        color: availableInSystem.contains(installable[index])
                            ? const Color.fromARGB(255, 93, 66, 53)
                            : const Color(0XFFE5E5CB)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
