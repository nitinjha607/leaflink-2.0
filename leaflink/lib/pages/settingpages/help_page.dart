import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = 'help_page';

  const HelpPage({super.key});

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.075,
        title: Text(
          "Help & Support",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => back(context),
          color: const Color.fromRGBO(16, 25, 22, 1),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(246, 245, 235, 1),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.all(15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(204, 221, 221, 1),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("How to Use the App:"),
                      _buildQuestion(
                          "1. How do I scan an item for disposal guidance?"),
                      _buildAnswer(
                          "   To scan an item, open the app and navigate to the Home page and click on the camera icon. Align the item within the camera view, and the app will automatically detect and provide information on proper disposal methods.\n\n"),
                      _buildQuestion(
                          "2. What information does the app provide about recycling, reducing, or reusing items?"),
                      _buildAnswer(
                          "   The app provides detailed information on how to recycle, reduce, or reuse each item. It includes local recycling facilities, tips for reducing waste, and suggestions for reuse.\n\n"),
                      _buildQuestion(
                          "3. Can I manually input items instead of scanning?"),
                      _buildAnswer(
                        "   Yes, you can manually input items by using the search bar option on the Home page beside the camera icon. Enter the item details, and the app will provide disposal guidance.\n\n",
                      ),
                      _buildSectionTitle("Engaging with the Community:"),
                      _buildQuestion(
                          "1. What is the Connect Page, and how can I use it?"),
                      _buildAnswer(
                          "   The Connect Page allows users to share their eco-friendly efforts, achievements, and tips. You can post your contributions, view others' posts, and engage with the community by liking and commenting.\n\n"),
                      _buildQuestion(
                          "2. How do I post contributions on the Connect Page?"),
                      _buildAnswer(
                          "   To post on the Connect Page, tap the 'Post' button, select the type of contribution, add details and images, and click 'Share.' Your post will be visible to the community.\n\n"),
                      _buildQuestion(
                          "3. Can I comment on or like other users' contributions?"),
                      _buildAnswer(
                        "   Yes, you can engage with other users' contributions by liking and commenting on their posts.\n\n",
                      ),
                      _buildSectionTitle("Events Calendar:"),
                      _buildQuestion(
                          "1. How can I find local eco-friendly events on the Events Calendar?"),
                      _buildAnswer(
                          "   Explore the Events Calendar to discover local eco-friendly events. Filter events based on location and interests, and click on an event for more details.\n\n"),
                      _buildQuestion(
                          "2. Can I add my own events to the calendar?"),
                      _buildAnswer(
                          "  Yes you can attend as well as host events and add them to the calender simply by clicking on host event on the selected date then filling simple details about the event you want to host.\n\n"),
                      _buildQuestion(
                          "3. How do I get notifications for upcoming events?"),
                      _buildAnswer(
                          "   Enable event notifications in your Notification settings to receive timely alerts and add reminders for the events you wish to attend.\n\n"),
                      _buildSectionTitle("Leaderboard:"),
                      _buildQuestion(
                          "1. What is the Leaderboard, and how are points calculated?"),
                      _buildAnswer(
                          "   The Leaderboard showcases top contributors based on points earned through eco-friendly activities. Points are awarded for various actions, such as posting on the Connect Page and attending events.\n\n"),
                      _buildQuestion(
                          "2. Can I see how my contributions compare to others?"),
                      _buildAnswer(
                          "   Yes, the Leaderboard allows you to compare your points and contributions with other users.\n\n"),
                      _buildQuestion(
                          "3. Are there rewards for achieving certain milestones?"),
                      _buildAnswer(
                        "   The app may introduce rewards for achieving specific milestones in the future.",
                      ),
                      _buildSectionTitle("Notification Settings:"),
                      _buildQuestion(
                          "1. How can I customize my notification preferences?"),
                      _buildAnswer(
                          "   Navigate to 'Settings' and then 'Notifications.' Adjust preferences for different activities, such as new posts, comments, and event updates.\n\n"),
                      _buildQuestion(
                          "2. Can I turn off notifications for specific activities?"),
                      _buildAnswer(
                          "   Yes, you can customize notification settings for each activity. Toggle on/off based on your preferences.\n\n"),
                      _buildQuestion(
                          "3. What options are available for customizing notification sounds and vibrations?"),
                      _buildAnswer(
                        "   Customize notification sounds and vibrations in your device settings.",
                      ),
                      _buildSectionTitle("FAQ"),
                      _buildQuestion(" How do I delete my account?"),
                      _buildAnswer(
                          "   Open the settings tab and you will see the delete account option, simply click on it confirm deletion and logout of the application.\n\n"),
                      _buildQuestion(
                          " How is the graphical data calculated and what are the sources used?"),
                      _buildAnswer(
                          "   The graphical data is calculated based on estimates and averages from reputable sources for each waste category. Sources include Environmental Paper Network, Waste Management, Alcoa, Glass Packaging Institute, EPA, Steel Recycling Institute, World Wildlife Fund, and the U.S. EPA. Specific units to save one tree vary by material and are obtained from respective sources or recycling institutes.")
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color.fromRGBO(16, 25, 22, 1),
          fontFamily: GoogleFonts.comfortaa().fontFamily,
        ),
      ),
    );
  }

  Widget _buildQuestion(String question) {
    return Text(
      question,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: const Color.fromRGBO(16, 25, 22, 1),
        fontFamily: GoogleFonts.comfortaa().fontFamily,
      ),
    );
  }

  Widget _buildAnswer(String answer) {
    return Text(
      answer,
      style: TextStyle(
        fontSize: 15,
        color: const Color.fromRGBO(16, 25, 22, 1),
        fontFamily: GoogleFonts.kohSantepheap().fontFamily,
      ),
    );
  }
}
