import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatViewModel>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _sendExample(String text) {
    context.read<ChatViewModel>().sendMessage(text);
    _scrollToBottom();
  }

  final Map<String, List<Map<String, dynamic>>> _faqByLang = {
    'ko': [
      {
        'category': '🏥 의료/약국',
        'questions': [
          '종로구에서 야간 진료하는 병원 정보를 알려줘.',
          '지금 문 연 약국이나 야간까지 여는 약국에 대한 정보를 알려줘.',
          '병원 방문 전에 확인해야하는 정보에 대해 알려줘.',
          '외국인이 병원이나 약국 이용할 때의 유의사항을 알려줘.',
        ],
      },
      {
        'category': '🍽️ 맛집/생활',
        'questions': [
          '종로구에서 후기 좋은 맛집 알려줘.',
          '혼자 밥 먹기 좋은 종로구 식당 추천해줘.',
          '광장시장 근처에서 유명 먹거리에 대해 알려줘.',
          '새로 이사 온 사람이 이용하면 좋은 생활 편의 시설에 대해 알려줘.',
        ],
      },
      {
        'category': '🏛️ 공공기관',
        'questions': [
          '전입신고는 어디서 어떻게 하면 돼?',
          '주민센터에서 처리할 수 있는 민원들을 알려줘.',
          '외국인이 주민센터나 구청에 갈 때 준비할 것을 알려줘.',
        ],
      },
    ],
    'en': [
      {
        'category': '🏥 Medical/Pharmacy',
        'questions': [
          'Tell me about hospitals in Jongno-gu that offer night treatment.',
          'Tell me about pharmacies that are open now or open late at night.',
          'What should I check before visiting a hospital?',
          'What should foreigners know when using hospitals or pharmacies in Korea?',
        ],
      },
      {
        'category': '🍽️ Food/Living',
        'questions': [
          'Tell me about restaurants with good reviews in Jongno-gu.',
          'Recommend restaurants in Jongno-gu that are good for eating alone.',
          'Tell me about famous foods near Gwangjang Market.',
          'Tell me about convenient facilities that are useful for someone who just moved here.',
        ],
      },
      {
        'category': '🏛️ Public Offices',
        'questions': [
          'Where and how can I report a change of address?',
          'What civil services can I handle at a community service center?',
          'What should foreigners prepare when visiting a community service center or district office?',
        ],
      },
    ],
    'zh': [
      {
        'category': '🏥 医疗/药店',
        'questions': [
          '请告诉我钟路区夜间诊疗医院的信息。',
          '请告诉我现在营业或营业到夜间的药店信息。',
          '去医院之前需要确认哪些信息？',
          '外国人在韩国使用医院或药店时需要注意什么？',
        ],
      },
      {
        'category': '🍽️ 美食/生活',
        'questions': [
          '请告诉我钟路区评价好的餐厅。',
          '请推荐适合一个人吃饭的钟路区餐厅。',
          '请告诉我广藏市场附近有名的小吃。',
          '请告诉我刚搬来的人适合使用的生活便利设施。',
        ],
      },
      {
        'category': '🏛️ 公共机构',
        'questions': [
          '迁入申报应该在哪里、怎么办理？',
          '居民中心可以办理哪些行政服务？',
          '外国人去居民中心或区政府时需要准备什么？',
        ],
      },
    ],
    'ja': [
      {
        'category': '🏥 医療・薬局',
        'questions': [
          '鍾路区で夜間診療を行っている病院の情報を教えてください。',
          '今開いている薬局や夜遅くまで営業している薬局について教えてください。',
          '病院に行く前に確認すべき情報を教えてください。',
          '外国人が韓国で病院や薬局を利用するときの注意点を教えてください。',
        ],
      },
      {
        'category': '🍽️ グルメ・生活',
        'questions': [
          '鍾路区で口コミの良い飲食店を教えてください。',
          '一人でも入りやすい鍾路区の食堂をおすすめしてください。',
          '広蔵市場周辺の有名な食べ物について教えてください。',
          '引っ越してきたばかりの人が利用すると便利な生活施設を教えてください。',
        ],
      },
      {
        'category': '🏛️ 公共機関',
        'questions': [
          '転入届はどこで、どのように手続きすればいいですか？',
          '住民センターで処理できる行政サービスを教えてください。',
          '外国人が住民センターや区役所に行くときに準備するものを教えてください。',
        ],
      },
    ],
  };

  String _faqTitle(String lang) {
    switch (lang) {
      case 'en':
        return 'Frequently Asked Questions';
      case 'zh':
        return '常见问题';
      case 'ja':
        return 'よくある質問';
      default:
        return '자주 묻는 질문';
    }
  }

  String _todayText() {
    final now = DateTime.now();
    return '${now.year}년 ${now.month}월 ${now.day}일';
  }

  String _loadingText(String lang) {
    switch (lang) {
      case 'en':
        return 'AI is writing a response...';
      case 'zh':
        return 'AI 正在生成回答...';
      case 'ja':
        return 'AIが回答を作成しています...';
      default:
        return 'AI가 답변을 작성 중입니다...';
    }
  }

  String _copyTooltip(String lang) {
    switch (lang) {
      case 'en':
        return 'Copy';
      case 'zh':
        return '复制';
      case 'ja':
        return 'コピー';
      default:
        return '복사';
    }
  }

  String _copiedMessage(String lang) {
    switch (lang) {
      case 'en':
        return 'Answer copied.';
      case 'zh':
        return '回答已复制。';
      case 'ja':
        return '回答をコピーしました。';
      default:
        return '답변이 복사되었습니다.';
    }
  }

  void _showFaqBottomSheet(String category, List<String> questions) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...questions.map((question) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(question),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      _sendExample(question);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(radius: 16, child: Icon(Icons.smart_toy, size: 18)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 도우미', style: TextStyle(fontSize: 16)),
                Text(
                  '온라인',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<ChatViewModel>(
            builder: (context, vm, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: vm.selectedLang,
                    items: const [
                      DropdownMenuItem(value: 'ko', child: Text('한국어')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'zh', child: Text('中文')),
                      DropdownMenuItem(value: 'ja', child: Text('日本語')),
                    ],
                    onChanged: vm.isLoading
                        ? null
                        : (value) {
                            if (value == null) return;
                            context.read<ChatViewModel>().changeLang(value);
                          },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: vm.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _todayText(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                final messageIndex = index - 1;
                final msg = vm.messages[messageIndex];
                final isUser = msg['role'] == 'user';
                final canCopy = !isUser && messageIndex != 0;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (canCopy)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: IconButton(
                            tooltip: _copyTooltip(vm.selectedLang),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: msg['text'] ?? ''),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _copiedMessage(vm.selectedLang),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.content_copy, size: 16),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // AI 응답 대기 중일 때 안내 문구 표시
          // AI 응답 대기 중일 때 안내 문구 표시
          if (vm.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_loadingText(vm.selectedLang)),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Center(
              child: Text(
                _faqTitle(vm.selectedLang),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (_faqByLang[vm.selectedLang] ?? _faqByLang['ko']!)
                    .map((faqCategory) {
                      final category = faqCategory['category'] as String;
                      final questions = List<String>.from(
                        faqCategory['questions'] as List,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () =>
                              _showFaqBottomSheet(category, questions),
                          child: Text(category),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _send,
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
