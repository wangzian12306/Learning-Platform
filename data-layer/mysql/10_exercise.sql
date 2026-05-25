-- 模块: 习题
-- 负责人: 李卓优
-- 日期: 2026-05-06

DROP TABLE IF EXISTS `exercise`;
CREATE TABLE `exercise` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `knowledge_point_id` bigint NOT NULL COMMENT '知识点ID',
  `title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题目',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题型：CHOICE, FILL, PROGRAMMING',
  `difficulty` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '难度：EASY, MEDIUM, HARD',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类别：基础题, 考研题, 面试题',
  `options` json DEFAULT NULL COMMENT '选择题选项',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '答案',
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '解析',
  `time_limit` int DEFAULT 60 COMMENT '时间限制(秒)',
  `sort_order` int DEFAULT 0 COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` int DEFAULT 0 COMMENT '逻辑删除标识',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '题目描述',
  `initial_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '编程题初始代码',
  `test_cases` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '测试用例(JSON格式)',
  `pass_rate` double DEFAULT 0 COMMENT '通过率',
  `total_attempts` int DEFAULT 0 COMMENT '总尝试次数',
  `correct_attempts` int DEFAULT 0 COMMENT '正确次数',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_knowledge_point_id`(`knowledge_point_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty` ASC) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='练习题表';

DROP TABLE IF EXISTS `user_exercise_record`;
CREATE TABLE `user_exercise_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `exercise_id` BIGINT NOT NULL COMMENT '题目ID',
    `user_answer` TEXT COMMENT '用户答案',
    `is_correct` TINYINT COMMENT '是否正确：0-否，1-是',
    `score` INT COMMENT '得分',
    `submit_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_user_id (`user_id`),
    INDEX idx_exercise_id (`exercise_id`),
    INDEX idx_submit_time (`submit_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户做题记录表';

INSERT INTO `exercise` VALUES (1, 1, '数组的时间复杂度', 'SINGLE_CHOICE', 'EASY', 'BASIC', '[\"A. O(1)\", \"B. O(n)\", \"C. O(log n)\", \"D. O(n²)\"]', 'A', '数组支持随机访问，访问任意元素的时间复杂度是常数O(1)。', 30, 1, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '在数组中访问第i个元素的时间复杂度是：', NULL, NULL, 85.5, 200, 171);
INSERT INTO `exercise` VALUES (2, 1, '数据结构分类', 'MULTIPLE_CHOICE', 'MEDIUM', 'BASIC', '[\"A. 树\", \"B. 图\", \"C. 栈\", \"D. 队列\", \"E. 集合\", \"F. 字典\"]', 'A,B', '非线性数据结构中元素之间存在一对多或多对多的关系，包括树、图等。栈和队列是线性结构。', 45, 2, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '以下哪些属于非线性数据结构？', NULL, NULL, 70.3, 150, 105);
INSERT INTO `exercise` VALUES (3, 2, '链表插入操作', 'SINGLE_CHOICE', 'MEDIUM', 'BASIC', '[\"A. O(1)\", \"B. O(n)\", \"C. O(log n)\", \"D. O(n²)\"]', 'B', '需要先遍历找到第k个节点，所以平均时间复杂度是O(n)。', 40, 3, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '在单链表的第k个节点后插入新节点，平均时间复杂度是：', NULL, NULL, 65.2, 180, 117);
INSERT INTO `exercise` VALUES (4, 2, '双向链表优点', 'MULTIPLE_CHOICE', 'MEDIUM', 'INTERVIEW', '[\"A. 可以从后向前遍历\", \"B. 删除节点更方便\", \"C. 占用内存更少\", \"D. 插入速度更快\"]', 'A,B', '双向链表可以从两个方向遍历，删除节点时不需要前驱节点的指针，但占用更多内存。', 50, 4, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '相比单向链表，双向链表的优势包括：', NULL, NULL, 60.8, 120, 73);
INSERT INTO `exercise` VALUES (5, 3, '栈的应用场景', 'MULTIPLE_CHOICE', 'EASY', 'BASIC', '[\"A. 函数调用栈\", \"B. 表达式求值\", \"C. 浏览器历史记录\", \"D. 消息队列\"]', 'A,B,C', '栈的LIFO特性适合函数调用、表达式求值、浏览器后退等场景，消息队列使用队列结构。', 35, 5, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '以下哪些场景适合使用栈数据结构？', NULL, NULL, 82.4, 160, 132);
INSERT INTO `exercise` VALUES (6, 3, '栈的溢出', 'SINGLE_CHOICE', 'EASY', 'BASIC', '[\"A. 栈溢出\", \"B. 内存泄漏\", \"C. 数组越界\", \"D. 空指针异常\"]', 'A', '栈空间不足时继续压栈会导致栈溢出（Stack Overflow）。', 30, 6, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '当栈空间不足时继续压栈会导致：', NULL, NULL, 88.9, 90, 80);
INSERT INTO `exercise` VALUES (7, 4, '队列的特性', 'SINGLE_CHOICE', 'EASY', 'BASIC', '[\"A. 先进先出\", \"B. 后进先出\", \"C. 随机访问\", \"D. 优先级访问\"]', 'A', '队列是先进先出（FIFO）的数据结构。', 25, 7, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '队列遵循的原则是：', NULL, NULL, 92.1, 110, 101);
INSERT INTO `exercise` VALUES (8, 4, '循环队列', 'SINGLE_CHOICE', 'MEDIUM', 'INTERVIEW', '[\"A. (rear+1)%size == front\", \"B. rear == front\", \"C. rear == size-1\", \"D. front == 0\"]', 'A', '循环队列中，队满的条件是(rear+1)%size == front，空队的条件是rear == front。', 40, 8, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '循环队列判断队满的条件是：', NULL, NULL, 55.6, 90, 50);
INSERT INTO `exercise` VALUES (9, 5, '二叉树性质', 'SINGLE_CHOICE', 'MEDIUM', 'BASIC', '[\"A. 2^h - 1\", \"B. 2^h\", \"C. h^2\", \"D. 2^(h+1)-1\"]', 'A', '高度为h的满二叉树有2^h - 1个节点。', 35, 9, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '高度为h的满二叉树的节点数是：', NULL, NULL, 72.3, 130, 94);
INSERT INTO `exercise` VALUES (10, 5, '二叉搜索树查找', 'SINGLE_CHOICE', 'MEDIUM', 'INTERVIEW', '[\"A. O(log n)\", \"B. O(n)\", \"C. O(n log n)\", \"D. O(1)\"]', 'A', '平衡二叉搜索树的查找时间复杂度是O(log n)。', 30, 10, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '在平衡二叉搜索树中查找一个元素的时间复杂度是：', NULL, NULL, 68.9, 140, 96);
INSERT INTO `exercise` VALUES (11, 6, '图的遍历', 'MULTIPLE_CHOICE', 'MEDIUM', 'BASIC', '[\"A. 深度优先搜索\", \"B. 广度优先搜索\", \"C. 迪杰斯特拉算法\", \"D. 克鲁斯卡尔算法\"]', 'A,B', '图的遍历算法主要有深度优先搜索（DFS）和广度优先搜索（BFS）。', 40, 11, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '以下哪些是图的遍历算法？', NULL, NULL, 76.5, 100, 77);
INSERT INTO `exercise` VALUES (12, 6, '最小生成树', 'MULTIPLE_CHOICE', 'HARD', 'INTERVIEW', '[\"A. Prim算法\", \"B. Kruskal算法\", \"C. Dijkstra算法\", \"D. Floyd算法\"]', 'A,B', 'Prim算法和Kruskal算法用于求最小生成树，Dijkstra和Floyd用于最短路径。', 60, 12, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '求最小生成树的算法包括：', NULL, NULL, 45.2, 80, 36);
INSERT INTO `exercise` VALUES (13, 1, '算法三要素', 'FILL_BLANK', 'EASY', 'BASIC', NULL, '输入|输出|确定性', '算法必须具有明确的输入、输出，并且每个步骤都是确定的。', 30, 13, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '算法的三要素是：___、___ 和 ___。', NULL, NULL, 85, 120, 102);
INSERT INTO `exercise` VALUES (14, 2, '链表节点组成', 'FILL_BLANK', 'EASY', 'BASIC', NULL, '数据域|指针域', '链表节点包含数据域存储数据，指针域存储下一个节点的地址。', 25, 14, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '链表节点通常包含两个部分：___ 和 ___。', NULL, NULL, 90.2, 110, 99);
INSERT INTO `exercise` VALUES (15, 5, '二叉树遍历', 'FILL_BLANK', 'MEDIUM', 'BASIC', NULL, '中序|层序', '二叉树的四种遍历：前序、中序、后序、层序。', 35, 15, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '二叉树的四种基本遍历是：前序、___、后序和 ___。', NULL, NULL, 78.4, 100, 78);
INSERT INTO `exercise` VALUES (16, 2, '两数之和', 'PROGRAMMING', 'EASY', 'BASIC', NULL, '可以使用哈希表优化查找', '暴力解法时间复杂度O(n²)，使用哈希表可以将时间复杂度降到O(n)。', 90, 16, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出和为目标值 target 的那两个整数，并返回它们的数组下标。', 'class Solution {\r\n    public int[] twoSum(int[] nums, int target) {\r\n        // 请在此处编写代码\r\n        \r\n    }\r\n}', '[{\"input\": \"nums = [2,7,11,15], target = 9\", \"output\": \"[0,1]\"}, {\"input\": \"nums = [3,2,4], target = 6\", \"output\": \"[1,2]\"}, {\"input\": \"nums = [3,3], target = 6\", \"output\": \"[0,1]\"}', 70.3, 200, 141);
INSERT INTO `exercise` VALUES (17, 3, '有效的括号', 'PROGRAMMING', 'EASY', 'BASIC', NULL, '使用栈进行匹配', '遍历字符串，左括号入栈，右括号时检查栈顶是否匹配。', 75, 17, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '给定一个只包括\"(\"，\")\"，\"{\"，\"}\"，\"[\"，\"]\"的字符串 s ，判断字符串是否有效。', 'import java.util.*;\r\n\r\nclass Solution {\r\n    public boolean isValid(String s) {\r\n        // 请在此处编写代码\r\n        \r\n    }\r\n}', '[{\"input\": \"s = \"()\"\", \"output\": \"true\"}, {\"input\": \"s = \"()[]{}\"\", \"output\": \"true\"}, {\"input\": \"s = \"(]\"\", \"output\": \"false\"}, {\"input\": \"s = \"([)]\"\", \"output\": \"false\"}', 82.6, 180, 149);
INSERT INTO `exercise` VALUES (18, 5, '二叉树的最大深度', 'PROGRAMMING', 'EASY', 'BASIC', NULL, '递归求解', '二叉树深度 = max(左子树深度, 右子树深度) + 1。', 80, 18, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '给定一个二叉树，找出其最大深度。', 'class TreeNode {\r\n    int val;\r\n    TreeNode left;\r\n    TreeNode right;\r\n    TreeNode() {}\r\n    TreeNode(int val) { this.val = val; }\r\n    TreeNode(int val, TreeNode left, TreeNode right) {\r\n        this.val = val;\r\n        this.left = left;\r\n        this.right = right;\r\n    }\r\n}\r\n\r\nclass Solution {\r\n    public int maxDepth(TreeNode root) {\r\n        // 请在此处编写代码\r\n        \r\n    }\r\n}', '[{\"input\": \"root = [3,9,20,null,null,15,7]\", \"output\": \"3\"}, {\"input\": \"root = [1,null,2]\", \"output\": \"2\"}, {\"input\": \"root = []\", \"output\": \"0\"}', 76.8, 150, 115);
INSERT INTO `exercise` VALUES (19, 2, '反转链表', 'PROGRAMMING', 'MEDIUM', 'INTERVIEW', NULL, '迭代或递归', '使用三个指针prev、curr、next逐个反转。', 100, 19, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '给你单链表的头节点 head ，请你反转链表，并返回反转后的链表。', 'class ListNode {\r\n    int val;\r\n    ListNode next;\r\n    ListNode() {}\r\n    ListNode(int val) { this.val = val; }\r\n    ListNode(int val, ListNode next) { this.val = val; this.next = next; }\r\n}\r\n\r\nclass Solution {\r\n    public ListNode reverseList(ListNode head) {\r\n        // 请在此处编写代码\r\n        \r\n    }\r\n}', '[{\"input\": \"head = [1,2,3,4,5]\", \"output\": \"[5,4,3,2,1]\"}, {\"input\": \"head = [1,2]\", \"output\": \"[2,1]\"}, {\"input\": \"head = []\", \"output\": \"[]\"}', 58.4, 120, 70);
INSERT INTO `exercise` VALUES (20, 6, '图的DFS遍历', 'PROGRAMMING', 'MEDIUM', 'INTERVIEW', NULL, '使用递归或栈', '从起始节点开始，访问节点后递归访问未访问的邻接节点。', 120, 20, '2026-05-05 02:58:46', '2026-05-05 02:58:46', 0, '实现图的深度优先搜索遍历。', 'import java.util.*;\r\n\r\nclass Graph {\r\n    private int V; // 顶点数\r\n    private LinkedList<Integer> adj[]; // 邻接表\r\n    \r\n    Graph(int v) {\r\n        V = v;\r\n        adj = new LinkedList[v];\r\n        for (int i = 0; i < v; ++i)\r\n            adj[i] = new LinkedList();\r\n    }\r\n    \r\n    void addEdge(int v, int w) {\r\n        adj[v].add(w);\r\n    }\r\n    \r\n    void DFS(int v) {\r\n        // 请在此处编写代码\r\n        \r\n    }\r\n}', '[{\"input\": \"V=4, edges=[[0,1],[0,2],[1,2],[2,0],[2,3],[3,3]], start=2\", \"output\": \"2 0 1 3\"}', 42.8, 70, 30);
INSERT INTO `knowledge_point` VALUES (1, NULL, '数据结构基础', 'DS_BASIC', NULL, '数据结构', 1, 'EASY', '数据结构基本概念、分类和特点', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
INSERT INTO `knowledge_point` VALUES (2, NULL, '链表', 'LINKED_LIST', NULL, '数据结构', 2, 'MEDIUM', '单链表、双向链表、循环链表的基本操作', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
INSERT INTO `knowledge_point` VALUES (3, NULL, '栈', 'STACK', NULL, '数据结构', 2, 'MEDIUM', '栈的基本操作和应用场景', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
INSERT INTO `knowledge_point` VALUES (4, NULL, '队列', 'QUEUE', NULL, '数据结构', 2, 'MEDIUM', '队列的基本操作和应用场景', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
INSERT INTO `knowledge_point` VALUES (5, NULL, '树', 'TREE', NULL, '数据结构', 3, 'HARD', '二叉树、二叉搜索树、平衡树', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
INSERT INTO `knowledge_point` VALUES (6, NULL, '图', 'GRAPH', NULL, '数据结构', 3, 'HARD', '图的表示、遍历和算法', NULL, '2026-05-05 03:25:08', '2026-05-05 03:25:08', 0);
