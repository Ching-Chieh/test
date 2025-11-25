#include <iostream>

using std::cout;
using std::endl;

class Node {
public:
    int value;
    Node* next;

    Node(int value, Node* next) {   // Node(int v, Node* n): value(v), next(n) {}
        this->value = value;
        this->next = next;
    }
};

void print(Node* current) {
	while (current) {
        cout << current->value;
		if (current->next) cout << " → ";
        current = current->next;
    }
	cout << endl;
}

void cleanup(Node* current) {
	while (current) {
        Node* next = current->next;
        delete current;
        current = next;
    }
}

int main() {
    Node* node5 = new Node(5, nullptr);
    Node* node4 = new Node(4, node5);
    Node* node3 = new Node(3, node4);
    Node* node2 = new Node(2, node3);
    Node* node1 = new Node(1, node2);

    print(node1);
	cleanup(node1);
    
    return 0;
}
