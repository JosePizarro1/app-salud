import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/services/sfx_manager.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => const ForumPage(),
    );
  }

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _posts = [];
  Map<int, List<Map<String, dynamic>>> _replies = {};
  Set<int> _likedPostIds = {};
  final Set<int> _expandedPostIds = {};
  bool _isLoading = true;
  bool _showOnboarding = false;
  String _currentUserName = 'Estudiante';

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndName();
    _loadForumData();
  }

  Future<void> _checkUserRoleAndName() async {
    final user = _supabase.auth.currentUser;
    setState(() {
      final metaName = user?.userMetadata?['full_name'] as String?;
      if (metaName != null && metaName.trim().isNotEmpty) {
        _currentUserName = metaName.trim();
      } else if (user?.email != null) {
        // Fallback to generating a friendly name based on email prefix
        final prefix = user!.email!.split('@')[0];
        _currentUserName = prefix[0].toUpperCase() + prefix.substring(1);
      }
    });
  }

  Future<void> _loadForumData() async {
    setState(() => _isLoading = true);
    
    // Load local likes cache first
    final prefs = await SharedPreferences.getInstance();
    final likedList = prefs.getStringList('my_liked_post_ids') ?? [];
    _likedPostIds = likedList.map((id) => int.parse(id)).toSet();

    // Check onboarding status
    final onboardingCompleted = prefs.getBool('forum_onboarding_completed') ?? false;
    setState(() {
      _showOnboarding = !onboardingCompleted;
    });

    try {
      // 1. Fetch posts from Supabase
      final List<dynamic> postsData = await _supabase
          .from('forum_posts')
          .select()
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> fetchedPosts = List<Map<String, dynamic>>.from(
        postsData.map((p) {
          final map = Map<String, dynamic>.from(p);
          final likes = map['likes_count'] as int? ?? 0;
          map['likes_count'] = likes.clamp(0, 999999);
          return map;
        }),
      );

      // 2. Fetch replies from Supabase
      final List<dynamic> repliesData = await _supabase
          .from('forum_replies')
          .select()
          .order('created_at', ascending: true);

      final Map<int, List<Map<String, dynamic>>> fetchedReplies = {};
      for (var rep in repliesData) {
        final postId = rep['post_id'] as int;
        if (!fetchedReplies.containsKey(postId)) {
          fetchedReplies[postId] = [];
        }
        final replyMap = Map<String, dynamic>.from(rep);
        if (replyMap['author_name'] == 'Titi (Maestro)') {
          replyMap['author_name'] = 'Titi';
        }
        fetchedReplies[postId]!.add(replyMap);
      }

      setState(() {
        _posts = fetchedPosts;
        _replies = fetchedReplies;
        _isLoading = false;
      });

      // Save to cache for offline availability
      await prefs.setString('offline_forum_posts', jsonEncode(fetchedPosts));
      await prefs.setString('offline_forum_replies', jsonEncode(fetchedReplies.map((k, v) => MapEntry(k.toString(), v))));

    } catch (e) {
      debugPrint('⚠️ Forum loading failed, using offline fallback: $e');
      // Offline Fallback
      final cachedPosts = prefs.getString('offline_forum_posts');
      final cachedReplies = prefs.getString('offline_forum_replies');
      
      setState(() {
        if (cachedPosts != null) {
          _posts = List<Map<String, dynamic>>.from(
            (jsonDecode(cachedPosts) as List).map((p) {
              final map = Map<String, dynamic>.from(p);
              final likes = map['likes_count'] as int? ?? 0;
              map['likes_count'] = likes.clamp(0, 999999);
              return map;
            }),
          );
        } else {
          // Default mock data if no cache exists
          _posts = [
            {
              'id': 101,
              'author_name': 'Lorena M.',
              'content': '¡Esta app realmente me ha ayudado a comer mejor y a ser más activa! Me encantan los recordatorios personalizados.',
              'likes_count': 23,
              'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            },
            {
              'id': 102,
              'author_name': 'Diego R.',
              'content': 'Los recursos y consejos en VitaliApp han sido muy útiles para reducir el estrés y dormir mejor. ¡Muy recomendable!',
              'likes_count': 19,
              'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
            },
            {
              'id': 103,
              'author_name': 'Esther L.',
              'content': 'Gracias a VitaliApp he logrado establecer rutinas saludables de ejercicio y meditación. ¡Me siento increíblemente bien!',
              'likes_count': 28,
              'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            }
          ];
        }

        if (cachedReplies != null) {
          final Map<String, dynamic> decoded = jsonDecode(cachedReplies);
          _replies = decoded.map((k, v) => MapEntry(
            int.parse(k),
            List<Map<String, dynamic>>.from((v as List).map((r) {
              final replyMap = Map<String, dynamic>.from(r);
              if (replyMap['author_name'] == 'Titi (Maestro)') {
                replyMap['author_name'] = 'Titi';
              }
              return replyMap;
            })),
          ));
        } else {
          _replies = {
            101: [
              {
                'id': 1,
                'post_id': 101,
                'author_name': 'Titi',
                'content': '¡Excelente Lorena! Sigue así, paso a paso se logran grandes hábitos.',
                'is_admin': true,
                'created_at': DateTime.now().subtract(const Duration(minutes: 90)).toIso8601String(),
              }
            ]
          };
        }
        _isLoading = false;
      });
    }
  }



  void _showNewPostDialog() {
    final contentController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : AppColors.surfaceLight, width: 2),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo Mensaje',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '¿Qué quieres compartir hoy?',
                  labelStyle: GoogleFonts.outfit(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.outfit(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (contentController.text.trim().isEmpty) return;
                      Navigator.pop(context);
                      await _submitPost(_currentUserName, contentController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Publicar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost(String author, String content) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final newPost = {
      'id': tempId,
      'author_name': author.isEmpty ? 'Estudiante' : author,
      'content': content,
      'likes_count': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Insert locally to UI first (Optimistic update)
    setState(() {
      _posts.insert(0, newPost);
    });

    try {
      final user = _supabase.auth.currentUser;
      final inserted = await _supabase.from('forum_posts').insert({
        'user_id': user?.id,
        'author_name': author.isEmpty ? 'Estudiante' : author,
        'content': content,
        'likes_count': 0,
      }).select().single();

      // Update the local post with the real DB post (with real ID)
      setState(() {
        final idx = _posts.indexWhere((p) => p['id'] == tempId);
        if (idx != -1) {
          _posts[idx] = Map<String, dynamic>.from(inserted);
        }
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('⚠️ Offline post queued: $e');
      // Keep optimistic post in list, save state to local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_forum_posts', jsonEncode(_posts));
    }
  }

  String _formatTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 60) {
        return 'Hace ${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'}';
      } else if (diff.inHours < 24) {
        return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
      } else {
        return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
      }
    } catch (_) {
      return 'Hace unos momentos';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Stack(
          children: [
            // 🌸 Wellness Decorative Background Blobs
            if (!isDark) ...[
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                right: -90,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 280,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],

            if (_showOnboarding)
              FadeIn(
                duration: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Drag bar
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const Spacer(),
                    // Illustration of Titi
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 3,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/gato1.png'), // Kitten image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '¡Te damos la bienvenida al Foro de la Comunidad! 🐻✨',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        'Este es un espacio de bienestar y acompañamiento seguro para compartir tus experiencias, reflexiones y dudas del día con todos.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Continue button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          SfxManager().playClick();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('forum_onboarding_completed', true);
                          setState(() {
                            _showOnboarding = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Continuar',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                const SizedBox(height: 10),
                // Pull bar / Drag indicator
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 15),

                // Header: Title and Close / Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.forum_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Foro de la Comunidad',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 20, thickness: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),

                // Main Forum View
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Button (Aligned to the Right)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              SfxManager().playClick();
                              _showNewPostDialog();
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: (MediaQuery.of(context).size.width * 0.42) / 1.5,
                              child: Image.asset(
                                'assets/images/boton_postear.webp',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Posts List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : ListView.builder(
                                padding: EdgeInsets.only(left: 20, right: 20, bottom: 40 + bottomInset),
                                itemCount: _posts.length,
                                itemBuilder: (context, index) {
                                  final post = _posts[index];
                                  final postId = post['id'] as int;
                                  final isLiked = _likedPostIds.contains(postId);
                                  final postReplies = _replies[postId] ?? [];

                                  return _buildPostCard(post, postId, isLiked, postReplies);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
    Map<String, dynamic> post,
    int postId,
    bool isLiked,
    List<Map<String, dynamic>> postReplies,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        gradient: isDark ? null : const LinearGradient(
          colors: [Color(0xFFFFFDF9), Color(0xFFFFF5EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF3E5D8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              // Double concentric ring avatar
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.primary.withValues(alpha: 0.5) : const Color(0xFFE6AD75),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: isDark ? Colors.white10 : AppColors.surfaceLight,
                    backgroundImage: (post['author_name'] == 'Titi') ? const AssetImage('assets/images/gato1.png') : null,
                    child: (post['author_name'] == 'Titi') ? null : Text(
                      post['author_name'][0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        post['author_name'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Soft Green Student "Miembro" badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3520) : const Color(0xFFE2F0D9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF385723).withValues(alpha: 0.4) : const Color(0xFFC5E0B4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 10,
                              color: isDark ? const Color(0xFF8CD37B) : const Color(0xFF385723),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Miembro',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF8CD37B) : const Color(0xFF385723),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatTimeAgo(post['created_at']),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            post['content'],
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: const Color(0xFF4A3B32),
              height: 1.4,
            ),
          ),


          // Premium Titi Reply Toggle Button
          if (postReplies.any((r) => r['is_admin'] == true)) () {
            final isExpanded = _expandedPostIds.contains(postId);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                SfxManager().playClick();
                setState(() {
                  if (isExpanded) {
                    _expandedPostIds.remove(postId);
                  } else {
                    _expandedPostIds.add(postId);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332B1A) : const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF8A6B1A) : const Color(0xFFFFD966),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFFFFD966) : const Color(0xFF8A6D00),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isExpanded ? 'Ocultar respuesta' : 'Ver respuesta de Titi ✨',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFFFD966) : const Color(0xFF8A6D00),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }(),

          // Render Replies Animadamente
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: (_expandedPostIds.contains(postId) && postReplies.isNotEmpty)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Divider(color: isDark ? Colors.white10 : AppColors.surfaceLight),
                      ...postReplies.map((reply) => _buildReplyTile(reply)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyTile(Map<String, dynamic> reply) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdminReply = reply['is_admin'] == true;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdminReply 
            ? (isDark ? const Color(0xFF2C2415) : const Color(0xFFFCF8F2)) 
            : (isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFFFFBF7)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdminReply
              ? (isDark ? const Color(0xFF8A6B1A).withValues(alpha: 0.4) : const Color(0xFFFFD966))
              : (isDark ? Colors.white10 : const Color(0xFFF3E5D8)),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Double concentric ring avatar
          Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isAdminReply
                    ? (isDark ? const Color(0xFFFFD966) : const Color(0xFFE6AD75))
                    : (isDark ? Colors.white10 : const Color(0xFFE6AD75)),
                width: 1.2,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.white,
                  width: 1.2,
                ),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: isDark ? Colors.white10 : AppColors.surfaceLight,
                backgroundImage: isAdminReply ? const AssetImage('assets/images/gato1.png') : null,
                child: isAdminReply ? null : Text(
                  reply['author_name'][0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right Column: Header & Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply['author_name'],
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isAdminReply 
                            ? (isDark ? const Color(0xFFFFD966) : const Color(0xFF8C7355))
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge: Maestro / Miembro
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAdminReply
                            ? (isDark ? const Color(0xFF3B2E15) : const Color(0xFFFFF9E6))
                            : (isDark ? const Color(0xFF1E3520) : const Color(0xFFE2F0D9)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isAdminReply
                              ? (isDark ? const Color(0xFF8A6B1A).withValues(alpha: 0.4) : const Color(0xFFFFD966))
                              : (isDark ? const Color(0xFF385723).withValues(alpha: 0.4) : const Color(0xFFC5E0B4)),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAdminReply ? Icons.stars_rounded : Icons.eco_rounded,
                            size: 8,
                            color: isAdminReply
                                ? (isDark ? const Color(0xFFFFD966) : const Color(0xFFD6A000))
                                : (isDark ? const Color(0xFF8CD37B) : const Color(0xFF385723)),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isAdminReply ? 'Maestro' : 'Miembro',
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isAdminReply
                                  ? (isDark ? const Color(0xFFFFD966) : const Color(0xFFD6A000))
                                  : (isDark ? const Color(0xFF8CD37B) : const Color(0xFF385723)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(reply['created_at']),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reply['content'],
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.9) : AppColors.textPrimaryLight.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
