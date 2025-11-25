// Huffman Tree (unordered_map, deque) ----------------------------------------------------------------------------------------------------------------------------------
#include <iostream>
#include <string>
#include <deque>
#include <unordered_map>
#include <algorithm>

using namespace std;

class Node {
public:
    int val; // 有存-1和char對應的int
    int freq;
    Node* lchild;
    Node* rchild;

    Node(char _val, int _freq, Node* _lchild, Node* _rchild) {
        val = _val;
        freq = _freq;
        lchild = _lchild;
        rchild = _rchild;
    }
};

unordered_map<char, int> freq;  // 用來統計各個字元的出現次數
deque<Node*> forest;            // 用來儲存各個節點之指標

// 提供給sort函數使用
bool comp(Node* a, Node* b) {
    return a->freq < b->freq; // 頻率小的節點，排在前面
}

// s.c_str() 把 string 轉成 C-style 字串
void printCode(Node* ptr, string s) {
    if(ptr->lchild == nullptr && ptr->rchild == nullptr) {
        cout << "'" << static_cast<char>(ptr->val) << "'"
             << " (freq = " << freq[static_cast<char>(ptr->val)] << ") --> "
             << s << endl;
        return;
    }
    if(ptr->lchild) printCode(ptr->lchild, string(s + "0"));
    if(ptr->rchild) printCode(ptr->rchild, string(s + "1"));
}
// to be or not to be
int main() {
	cout << "----------------------------------------------------" << endl;
    string input;
	cout << "請輸入字串: ";
	getline(cin, input);
	for(char c : input) freq[c]++;

    // 新增節點，並儲存到forest之中，每個節點都還沒有child
    for(auto it = freq.begin(); it != freq.end(); it++)
        forest.push_back(new Node((*it).first, (*it).second, nullptr, nullptr));

    // 1. 排序，頻率小的節點，排在前面
	// 2. 取出最小的兩個節點指標，將這2個節點從 forest 裡 pop 掉
	// 3. 建立父節點，頻率為兩者之和
	// 4. 父節點再放回 forest

	// 從 forest 裡 pop 出來，Node 物件還存在記憶體中，指標仍然有效，可以取出freq
    for(int i = 0; i < freq.size()-1; i++) {
        sort(forest.begin(), forest.end(), comp);
        Node* ptr1 = forest.front(); forest.pop_front();
        Node* ptr2 = forest.front(); forest.pop_front();
        Node* parentNode = new Node(-1, ptr1->freq + ptr2->freq, ptr1, ptr2);
        forest.push_back(parentNode);
    }
    printCode(forest.front(), string(""));
	cout << "----------------------------------------------------" << endl;
    return 0;
}

// Huffman Tree (unordered_map, priority_queue) 不需要手動 sort ----------------------------------------------------------------------------------------------------------------------------------
#include <iostream>
#include <string>
#include <unordered_map>
#include <queue>

using namespace std;

class Node {
public:
    char val;
    int freq;
    Node* lchild;
    Node* rchild;

    Node(char _val, int _freq, Node* _lchild = nullptr, Node* _rchild = nullptr) {
        val = _val;
        freq = _freq;
        lchild = _lchild;
        rchild = _rchild;
    }
};

struct Compare {
    bool operator()(Node* a, Node* b) {
        return a->freq > b->freq; // 頻率小的優先
    }
};

void printCode(Node* ptr, const string& s, const unordered_map<char,int>& freq_map) {
    if(ptr->lchild == nullptr && ptr->rchild == nullptr) {
        cout << "'" << ptr->val << "' (freq = " << freq_map.at(ptr->val) << ") --> " << s << endl; // 用 .at() 而不是 []
		// .at(): key 不存在會丟出 std::out_of_range
		// []: key 不存在會自動建立一個預設值（對 int 是 0）
        return;
    }
    if(ptr->lchild) printCode(ptr->lchild, s + "0", freq_map);
    if(ptr->rchild) printCode(ptr->rchild, s + "1", freq_map);
}

// to be or not to be
int main() {
    cout << "----------------------------------------------------" << endl;
	cout << "請輸入字串: ";
    string input;
    getline(cin, input);
    unordered_map<char,int> freq;
    for(char c : input) freq[c]++;

    // 頻率小的在前面
    priority_queue<Node*, vector<Node*>, Compare> pq;
    for(auto& p : freq) {
        pq.push(new Node(p.first, p.second));
    }

    while(pq.size() > 1) {
        Node* left = pq.top(); pq.pop();
        Node* right = pq.top(); pq.pop();
        Node* parent = new Node('\0', left->freq + right->freq, left, right);
        pq.push(parent);
    }

    Node* root = pq.top();
    printCode(root, "", freq);

    cout << "----------------------------------------------------" << endl;
    return 0;
}
