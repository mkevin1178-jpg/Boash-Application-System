1.  **DEVELOPMENT BASIC BOASH APPLICATION SYSTEM (BAS)**

Berikut adalah struktur proyek Flutter dengan file main.dart,
login.dart, welcome.dart, home.dart, info.dart, profile.dart, dan
news.dart, serta tab menu pada welcome.dart yang terdiri dari empat tab:
Home, Info, Profile, dan News.

![image1.png](media/media/image1.png)

1.  main.dart

```dart
import 'package:flutter/material.dart';
import 'login.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
```

2.  login.dart

```dart
import 'package:flutter/material.dart';
import 'welcome.dart';
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
```

3.  welcome.dart

```dart
import 'package:flutter/material.dart';
import 'home.dart';
import 'info.dart';
import 'profile.dart';
import 'news.dart';
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}
class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    InfoScreen(),
    ProfileScreen(),
    NewsScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student App',
          style: TextStyle(
            color: Color.fromARGB(255, 246, 246, 248), // Warna teks
            fontWeight: FontWeight.bold, // Memberikan gaya tebal pada teks
            fontSize: 24, // Ukuran teks
          ),
        ),
        centerTitle: true, // Untuk memusatkan teks judul
        backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar
        elevation: 4, // Memberikan bayangan pada AppBar
      shadowColor: Colors.black.withOpacity(0.5), // Warna bayangan
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}
```

4.  home.dart

```dart
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab'),
    );
  }
}
```

5.  info.dart

```dart
import 'package:flutter/material.dart';
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Info Tab'),
    );
  }
}
```

6.  profile.dart

```dart
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Tab'),
    );
  }
}
```

7.  news.dart

```dart
import 'package:flutter/material.dart';
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('News Tab'),
    );
  }
}
```

Penjelasan:

- **main.dart** berfungsi sebagai entry point aplikasi.

- **login.dart** adalah halaman login, setelah login akan menuju
  WelcomeScreen.

- **Cara Run Adalah** *flutter run -d chrome*

- **welcome.dart** memiliki empat tab: Home, Info, Profile, dan News.
  Setiap tab menampilkan konten berbeda sesuai dengan file
  home.dart,info.dart, profile.dart, dan news.dart.

- Tab-tab diatur menggunakan BottomNavigationBar pada home.dart, dengan
  setiap tab merujuk ke halaman masing-masing.

- Hasilnya Adalah :

![image2.png](media/media/image2.png)

2.  **DEVELOPMENT ADVANCED STUDENT APP**

1.  home.dart

1)  Blok code yang ada di home.dart lalu cut (ctrl + x)

2)  Masuk kedalam chat gpt lalu masukan format keyword seperti dibawah
    ini

```text
buatkan code di file home.dart untuk membuat contoh 12 menu icon warna seperti code dibawah ini
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Center(
child: Text('Home Tab'),
);
}
}
```

3)  Selanjutnya copy paste code dari chat GPT kedalam file home.dart

4)  Tampilan output

![image3.png](media/media/image3.png)

2.  Lanjutkan desain info.dart, profile.dart, dan news.dart yang anda
    inginkan berdasarkan teknik penyelesaian seperti no.1 mengenai
    home.dart

3.  Lakukan desain sebaik mungkin, tugasnya adalah screenshoot hasil
    dari aplikasi tersebut baik dari login, home, Informasi, Profile dan
    News.

4.  Buatlah link google drive yang berisikan folder-folder dengan nama
    siswa, didalam folder tersebut terdapat hasil screenshoot

5.  Batas pengumpulan jam 12:00 WIB.

6.  Link Google Drive kirim ke No. WhatsApp
