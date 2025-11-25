#include <iostream>
#include <vector>

class List {
private:
    struct Node {
        int data;
        Node* next;
        Node(int val) : data(val), next(nullptr) {}
    };

    Node* head;

public:
    List() : head(nullptr) {}

    ~List() {
        while (head) {
            Node* temp = head;
            head = head->next;
            delete temp;
        }
    }

    void insertFront(int value) {
        Node* newNode = new Node(value);
        newNode->next = head;
        head = newNode;
    }

    void buildFromVector(const std::vector<int>& v) {
        // 先清空目前list（如果有）
        while (head) {
            Node* temp = head;
            head = head->next;
            delete temp;
        }

        for (auto it = v.rbegin(); it != v.rend(); ++it) {
            insertFront(*it);
        }
    }
	
    void removeFront() {
        if (head) {
            Node* temp = head;
            head = head->next;
            delete temp;
        } else {
            std::cout << "List is empty!" << std::endl;
        }
    }

    int front() const {
        if (head) {
            return head->data;
        } else {
            throw std::out_of_range("List is empty");
        }
    }

    bool isEmpty() const {
        return head == nullptr;
    }

    void print() const {
        Node* current = head;
        while (current) {
            std::cout << current->data << " -> ";
            current = current->next;
        }
        std::cout << "nullptr" << std::endl;
    }
};

int main() {
    List myList;
    myList.insertFront(10);
    myList.insertFront(20);
	myList.insertFront(30);
    myList.print();  // 30 -> 20 -> 10 -> nullptr

	std::vector<int> v = {40, 50, 60};
	myList.buildFromVector(v);
	myList.print();  // 40 -> 50 -> 60 -> nullptr
    return 0;
}
/*
解釋 destructor
~List() {
	while (head) {
		Node* temp = head;
		head = head->next;
		delete temp;
	}
}

30 (head) -> 20 -> 10 -> nullptr
#第一次迴圈
1. 目前head指向30，所以temp指向30
2. head改指向20
3. delete temp
結果: 20 (head) -> 10 -> nullptr

...
10 (head) -> nullptr
#第三次迴圈
1. 目前head指向10，所以temp指向10
2. head改指向 nullptr
3. delete temp
結果: nullptr(head)



解釋 insertFront
void insertFront(int value) {
	Node* newNode = new Node(value);
	newNode->next = head;
	head = newNode;
}
一開始: nullptr(head)
myList.insertFront(10);
1. 建立新節點 Node(10)
2. newNode->next = head，此時 head == nullptr，所以 newNode->next = nullptr
3. head = newNode，head 指向10
結果: 10 (head) -> nullptr

myList.insertFront(20);
1. 建立新節點 Node(20)
2. newNode->next = head，此時 head指向10，所以 newNode->next指向10
3. head = newNode，head 指向20
結果: 20 (head) -> 10 -> nullptr
*/