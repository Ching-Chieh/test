#include <iostream>
#include <vector>

using std::cout;
using std::endl;
using std::vector;

struct ListNode {
    int val;
    ListNode *next;
    ListNode(int x) : val(x), next(nullptr) {}
};

ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
    ListNode* dummyHead = new ListNode(0);
    ListNode* current = dummyHead;
    int carry = 0;

    while (l1 || l2 || carry) {
        int val1 = l1 ? l1->val : 0;
        int val2 = l2 ? l2->val : 0;

        int sum = val1 + val2 + carry;
        carry = sum / 10;
        current->next = new ListNode(sum % 10);
        current = current->next;

        if (l1) l1 = l1->next;
        if (l2) l2 = l2->next;
    }

    return dummyHead->next;
}

ListNode* createList(const vector<int>& nums) {
    ListNode* dummyHead = new ListNode(0);
    ListNode* current = dummyHead;
    for (int num : nums) {
        current->next = new ListNode(num);
        current = current->next;
    }
    return dummyHead->next;
}

void printList(ListNode* head) {
    while (head) {
        cout << head->val;
        if (head->next) cout << " -> ";
        head = head->next;
    }
    cout << endl;
}

int main() {
    ListNode* l1 = createList(vector<int> {2, 4, 3});
    ListNode* l2 = createList(vector<int> {5, 6, 4});
    ListNode* result = addTwoNumbers(l1, l2);
    printList(result);
    return 0;
}
/*
example [9,9] + [1]
carrry	0	1	1
val1	9	9	0
val2	1	0	0
sum	   10  10	1
carry	1	1	0
			
result: [0, 0, 1]
*/