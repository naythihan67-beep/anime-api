import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';

const String baseUrl = 'https://anime-api-iota-three.vercel.app';
const String loginUrl = 'https://www.melivecode.com/api/login';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ── LOGIN SCREEN ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() { loading = true; errorMessage = ''; });
    try {
      final res = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'ok') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(user: data['user']),
          ),
        );
      } else {
        setState(() { errorMessage = data['message'] ?? 'Login failed'; });
      }
    } catch (e) {
      setState(() { errorMessage = 'Connection error'; });
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_fill, size: 64, color: Colors.deepPurple),
                  const SizedBox(height: 8),
                  const Text('Anime App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Use: karn.yong@melivecode.com / melivecode',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── MAIN SCREEN (with bottom nav) ────────────────────────────
class MainScreen extends StatefulWidget {
  final Map user;
  const MainScreen({super.key, required this.user});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const AnimeListScreen(),
      ProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Anime'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── PROFILE SCREEN ───────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  final Map user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user['avatar'] ?? ''),
              ),
              const SizedBox(height: 24),
              Text('${user['fname']} ${user['lname']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(user['email'] ?? user['username'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.deepPurple),
                        title: const Text('Username'),
                        subtitle: Text(user['username'] ?? ''),
                      ),
                      ListTile(
                        leading: const Icon(Icons.badge, color: Colors.deepPurple),
                        title: const Text('ID'),
                        subtitle: Text(user['id'].toString()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── LIST SCREEN ──────────────────────────────────────────────
class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});
  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List animeList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnime();
  }

  Future<void> fetchAnime() async {
    final res = await http.get(Uri.parse('$baseUrl/anime'));
    setState(() {
      animeList = jsonDecode(res.body);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime List'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                final anime = animeList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: anime['image_url'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(anime['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${anime['genre']} · ${anime['year']}\n⭐ ${anime['rating']}'),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimeDetailScreen(anime: anime),
                        ),
                      ).then((_) => fetchAnime());
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ── DETAIL SCREEN ────────────────────────────────────────────
class AnimeDetailScreen extends StatefulWidget {
  final Map anime;
  const AnimeDetailScreen({super.key, required this.anime});
  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late Map anime;
  final commentController = TextEditingController();
  final authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    anime = widget.anime;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final res = await http.get(Uri.parse('$baseUrl/anime/${anime['id']}'));
    setState(() { anime = jsonDecode(res.body); });
  }

  Future<void> updateRating(double rating) async {
    await http.patch(
      Uri.parse('$baseUrl/anime/${anime['id']}/rating'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rating': rating}),
    );
    fetchDetail();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating updated to $rating!')),
    );
  }

  Future<void> addComment() async {
    if (commentController.text.isEmpty) return;
    await http.post(
      Uri.parse('$baseUrl/anime/${anime['id']}/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'author': authorController.text.isEmpty ? 'Anonymous' : authorController.text,
        'body': commentController.text,
      }),
    );
    commentController.clear();
    authorController.clear();
    fetchDetail();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comments = anime['comments'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(anime['title']),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: anime['image_url'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(anime['title'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${anime['genre']} · ${anime['year']}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text(anime['synopsis'] ?? '', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 24),
                  const Text('Update Rating',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Current rating: ⭐ ${anime['rating']}'),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: double.tryParse(anime['rating'].toString()) ?? 0,
                    minRating: 1,
                    maxRating: 10,
                    itemCount: 10,
                    itemSize: 30,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: updateRating,
                  ),
                  const SizedBox(height: 24),
                  const Text('Comments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      labelText: 'Your name (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Post Comment'),
                  ),
                  const SizedBox(height: 16),
                  ...comments.map((c) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(c['author'] ?? 'Anonymous'),
                          subtitle: Text(c['body']),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}